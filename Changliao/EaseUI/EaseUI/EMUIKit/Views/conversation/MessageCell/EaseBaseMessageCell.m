/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseBaseMessageCell.h"

#import "UIImageView+WebCache.h"
#import "Public.h"
#import "EaseBubbleView+Text.h"
#import "EaseBubbleView+Voice.h"
#include <Masonry.h>
#import "Chaangliao-Swift.h"
#import "EaseBubbleView+IDCard.h"
#import <SDWebImage/SDWebImage.h>

@interface EaseBaseMessageCell()

@property (strong, nonatomic) UILabel *nameLabel;

@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarRightConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarRightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithHeightConstraint;

@end

@implementation EaseBaseMessageCell

@synthesize nameLabel = _nameLabel;

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseBaseMessageCell *cell = [self appearance];
    cell.avatarSize = 30;
    cell.avatarCornerRadius = 0;
    
    cell.messageNameColor = [UIColor grayColor];
    cell.messageNameFont = [UIFont systemFontOfSize:10];
    cell.messageNameHeight = 15;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        cell.messageNameIsHidden = NO;
    }
    
//    cell.bubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!model.isSender) {
            if (model.message.chatType == EMChatTypeGroupChat) {
                _nameLabel = [[UILabel alloc] init];
                _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
                _nameLabel.backgroundColor = [UIColor clearColor];
                _nameLabel.font = _messageNameFont;
                _nameLabel.textColor = _messageNameColor;
                [self.contentView addSubview:_nameLabel];
            }else{
                _nameLabel = nil;
            }
        }else{
            _nameLabel = nil;
        }
        
        [self configureLayoutConstraintsWithModel:model];
        
        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
            self.messageNameHeight = 15;
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bubbleView.backgroundImageView.image = nil;
    _bubbleView.backgroundImageView.backgroundColor = [UIColor whiteColor];
    [_bubbleView.layer setCornerRadius:5];
    [_bubbleView.layer setMasksToBounds:YES];
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            BoxinMessageModel* bm = (BoxinMessageModel*)self.model;
            if (bm) {
                if (bm.isIDCard) {
                    _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
                    [self removeConstraint:self.bubbleWithImageConstraint];
                    self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:kSCRATIO(225)];
                    self.bubbleWithHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(110)];
                    [self addConstraint:self.bubbleWithImageConstraint];
                    [self addConstraint:self.bubbleWithHeightConstraint];
                }else{
                    if (self.model.message.chatType == EMChatTypeGroupChat && !self.model.isSender) {
                        [_bubbleView updateTextMargin:UIEdgeInsetsMake(6, 12, 6, 12)];
                    }else{
                        [_bubbleView updateTextMargin:UIEdgeInsetsMake(12, 12, 12, 12)];
                    }
                }
            }else{
                if (self.model.message.chatType == EMChatTypeGroupChat && !self.model.isSender) {
                    [_bubbleView updateTextMargin:UIEdgeInsetsMake(6, 12, 6, 12)];
                }else{
                    [_bubbleView updateTextMargin:UIEdgeInsetsMake(12, 12, 12, 12)];
                }
            }
        }
            break;
        case EMMessageBodyTypeImage:
        {
            CGSize retSize = self.model.imageSize.width==0 || self.model.imageSize.height == 0 ? self.model.thumbnailImageSize:self.model.imageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                UIImage* img = _bubbleView.imageView.image;
                retSize = img.size;
                if (retSize.width == 0 || retSize.height == 0) {
                    UIImage* img = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.model.thumbnailFileURLPath];
                    if (img) {
                        retSize = img.size;
                        if (retSize.width > retSize.height) {
                            CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                            retSize.height = height;
                            retSize.width = kEMMessageImageSizeWidth;
                        }
                        else {
                            CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                            retSize.width = width;
                            retSize.height = kEMMessageImageSizeHeight;
                        }
                    }else{
                        retSize.width = kEMMessageImageSizeWidth;
                        retSize.height = kEMMessageImageSizeHeight;
                        self.needReload = YES;
                    }
                }
                else if (retSize.width > retSize.height) {
                    CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                    retSize.height = height;
                    retSize.width = kEMMessageImageSizeWidth;
                }
                else {
                    CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                    retSize.width = width;
                    retSize.height = kEMMessageImageSizeHeight;
                }
            }
            else if (retSize.width > retSize.height) {
                CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kEMMessageImageSizeWidth;
            }
            else {
                CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kEMMessageImageSizeHeight;
            }
            [self removeConstraint:self.bubbleWithImageConstraint];
            
            CGFloat margin = [EaseMessageCell appearance].leftBubbleMargin.left + [EaseMessageCell appearance].leftBubbleMargin.right;
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
            _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self removeConstraint:self.bubbleWithImageConstraint];
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[EaseMessageCell appearance].voiceCellWidth];
            [self addConstraint:self.bubbleWithImageConstraint];
            [_bubbleView updateVoiceMargin:UIEdgeInsetsMake(12, 12, 12, 12)];
            [_bubbleView.layer setMasksToBounds:NO];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _bubbleView.backgroundImageView.backgroundColor = [UIColor whiteColor];
        }
            break;
        default:
            break;
    }
}

/*!
 @method
 @brief 根据传入的消息对象，设置头像、昵称、气泡的约束
 @discussion
 @param model   消息对象
 @result
 */
- (void)configureLayoutConstraintsWithModel:(id<IMessageModel>)model
{
    if (model.isSender) {
        BoxinMessageModel* bm = (BoxinMessageModel*)model;
        if (bm.isIDCard) {
            [self configIDCardLayoutConstraints];
        }else{
            [self configureSendLayoutConstraints];
        }
    } else {
        [self configureRecvLayoutConstraints:model.message.chatType];
    }
}

-(void)configIDCardLayoutConstraints{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(8)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-15)]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    //    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    //
    //    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
    //
    //    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
    //    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(9)]];
    
    //status button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    
    //activity
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    
    //hasRead
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
}

/*!
 @method
 @brief 发送方控件约束
 @discussion  当前登录用户为消息发送方时，设置控件约束，在cell的右侧排列显示
 @result
 */
- (void)configureSendLayoutConstraints
{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(8)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-15)]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
//
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
//
//    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
//    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(9)]];
    
    //status button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    
    //activity
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
    
    //hasRead
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(-10)]];
}

/*!
 @method
 @brief 接收方控件约束
 @discussion  当前登录用户为消息接收方时，设置控件约束，在cell的左侧排列显示
 @result
 */
- (void)configureRecvLayoutConstraints:(EMChatType) type
{
    //avatar view
    if (type == EMChatTypeChat) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(8)]];
    }else{
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(4)]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(13)]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    if (type == EMChatTypeGroupChat) {
        if (self.nameLabel) {
//            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.contentView);
//                make.left.equalTo(self.avatarView.mas_right).offset(kSCRATIO(10));
//                make.height.mas_equalTo(self.messageNameHeight);
//            }];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(10)]];

            self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
            [self addConstraint:self.nameHeightConstraint];
        }
    }
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(10)]];
    if (type == EMChatTypeGroupChat) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kSCRATIO(6)]];
    }else{
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(9)]];
    }
}

#pragma mark - Update Constraint

/*!
 @method
 @brief 更新头像宽度的约束
 @discussion
 @result
 */
- (void)_updateAvatarViewWidthConstraint
{
    if (self.avatarView) {
        [self removeConstraint:self.avatarWidthConstraint];
        
        self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.avatarSize];
        [self addConstraint:self.avatarWidthConstraint];
    }
}

/*!
 @method
 @brief 更新昵称高度的约束
 @discussion
 @result
 */
- (void)_updateNameHeightConstraint
{
    if (_nameLabel) {
        [self removeConstraint:self.nameHeightConstraint];

        self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
        [self addConstraint:self.nameHeightConstraint];
    }
}

#pragma mark - setter

- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
    _nameLabel.text = model.nickname;
    
    if (self.model.isSender) {
        _hasRead.hidden = YES;
        switch (self.model.messageStatus) {
            case EMMessageStatusDelivering:
            {
                _statusButton.hidden = YES;
                [_activity setHidden:NO];
                [_activity startAnimating];
            }
                break;
            case EMMessageStatusSucceed:
            {
                _statusButton.hidden = YES;
                [_activity stopAnimating];
                if (self.model.isDing) {
                    _hasRead.hidden = NO;
                    _hasRead.text = [NSString stringWithFormat:@"%@ 已读", @(self.model.dingReadCount)];
                } else if (self.model.isMessageRead) {
                    if (self.model.message.chatType == EMChatTypeChat) {
                        _hasRead.hidden = NO;
                        _hasRead.text = @"已读";
                    }
                } else if (self.model.isDing) {
                    _hasRead.hidden = NO;
                    _hasRead.text = [NSString stringWithFormat:@"%@ %@", @(self.model.dingReadCount), NSLocalizedString(@"hasRead", @"Read")];
                }
            }
                break;
            case EMMessageStatusPending:
            case EMMessageStatusFailed:
            {
                [_activity stopAnimating];
                [_activity setHidden:YES];
                _statusButton.hidden = NO;
            }
                break;
            default:
                break;
        }
    }
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            BoxinMessageModel* bm = (BoxinMessageModel*)self.model;
            if (bm.isIDCard) {
                [_bubbleView updateIDCardMargin:UIEdgeInsetsMake(6, 6, 6, 6)];
            }else{
                [_bubbleView updateTextMargin:UIEdgeInsetsMake(12, 12, 12, 12)];
            }
        }
            break;
        case EMMessageBodyTypeImage:
        {
            CGSize retSize = self.model.imageSize.width==0 || self.model.imageSize.height == 0 ? self.model.thumbnailImageSize:self.model.imageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                UIImage* img = _bubbleView.imageView.image;
                retSize = img.size;
                if (retSize.width == 0 || retSize.height == 0) {
                    UIImage* img = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.model.thumbnailFileURLPath];
                    if (img) {
                        retSize = img.size;
                        if (retSize.width > retSize.height) {
                            CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                            retSize.height = height;
                            retSize.width = kEMMessageImageSizeWidth;
                        }
                        else {
                            CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                            retSize.width = width;
                            retSize.height = kEMMessageImageSizeHeight;
                        }
                    }else{
                        retSize.width = kEMMessageImageSizeWidth;
                        retSize.height = kEMMessageImageSizeHeight;
                        self.needReload = YES;
                    }
                }
                else if (retSize.width > retSize.height) {
                    CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                    retSize.height = height;
                    retSize.width = kEMMessageImageSizeWidth;
                }
                else {
                    CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                    retSize.width = width;
                    retSize.height = kEMMessageImageSizeHeight;
                }
            }
            else if (retSize.width > retSize.height) {
                CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kEMMessageImageSizeWidth;
            }
            else {
                CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kEMMessageImageSizeHeight;
            }
            [self removeConstraint:self.bubbleWithImageConstraint];
            
            CGFloat margin = self.leftBubbleMargin.left + self.leftBubbleMargin.right;
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
            _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self removeConstraint:self.bubbleWithImageConstraint];
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[EaseMessageCell appearance].voiceCellWidth];
            [self addConstraint:self.bubbleWithImageConstraint];
            [_bubbleView updateVoiceMargin:UIEdgeInsetsMake(12, 12, 12, 12)];
            [_bubbleView.backgroundImageView.layer setCornerRadius:6];
            
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            CGSize retSize = self.model.thumbnailImageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                retSize.width = kEMMessageImageSizeWidth;
                retSize.height = kEMMessageImageSizeHeight;
            }
            else if (retSize.width > retSize.height) {
                CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kEMMessageImageSizeWidth;
            }
            else {
                CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kEMMessageImageSizeHeight;
            }
            [self removeConstraint:self.bubbleWithImageConstraint];
            
            CGFloat margin = [EaseMessageCell appearance].leftBubbleMargin.left + [EaseMessageCell appearance].leftBubbleMargin.right;
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
            _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _bubbleView.backgroundImageView.backgroundColor = [UIColor whiteColor];
        }
            break;
        default:
            break;
    }
}

- (void)setMessageNameFont:(UIFont *)messageNameFont
{
    _messageNameFont = messageNameFont;
    if (_nameLabel) {
        _nameLabel.font = _messageNameFont;
    }
}

- (void)setMessageNameColor:(UIColor *)messageNameColor
{
    _messageNameColor = messageNameColor;
    if (_nameLabel) {
        _nameLabel.textColor = _messageNameColor;
    }
}

- (void)setMessageNameHeight:(CGFloat)messageNameHeight
{
    _messageNameHeight = messageNameHeight;
    if (_nameLabel) {
        [self _updateNameHeightConstraint];
    }
}

- (void)setAvatarSize:(CGFloat)avatarSize
{
    _avatarSize = avatarSize;
    if (self.avatarView) {
        [self _updateAvatarViewWidthConstraint];
    }
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius
{
    _avatarCornerRadius = avatarCornerRadius;
    if (self.avatarView){
        self.avatarView.layer.cornerRadius = avatarCornerRadius;
    }
}

- (void)setMessageNameIsHidden:(BOOL)messageNameIsHidden
{
    _messageNameIsHidden = messageNameIsHidden;
    if (_nameLabel) {
        _nameLabel.hidden = messageNameIsHidden;
    }
}

- (UITableView *)tableView{

    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (UITableView *)tableView;
}

#pragma mark - public

/*!
 @method
 @brief 获取当前cell的高度
 @discussion  
 @result
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    EaseBaseMessageCell *cell = [self appearance];
    
    CGFloat minHeight = cell.avatarSize + 10 * 2;
    CGFloat height = 0;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height += [EaseMessageCell cellHeightWithModel:model];
    if (!model.isSender && model.message.chatType == EMChatTypeGroupChat) {
        height += [EaseBaseMessageCell appearance].messageNameHeight;
    }
    height = height > minHeight ? height : minHeight;
    
    return height;
}

@end
