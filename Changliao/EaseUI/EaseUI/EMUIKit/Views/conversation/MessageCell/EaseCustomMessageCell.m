/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseCustomMessageCell.h"

#import <SDWebImage/SDWebImage.h>
#import "UIImage+GIF.h"
#import "Chaangliao-Swift.h"
#import "EaseBubbleView+Gif.h"
#import "IMessageModel.h"
#import "UIImageView+ASGif.h"

@interface EaseCustomMessageCell ()

@property (nonatomic, strong) NSLayoutConstraint* bubbleWidth;

@end

@implementation EaseCustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    [EaseCustomMessageCell appearance].maxBubbleWidth = 255;
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    UIImage *image = model.image;
    if (image) {
        _bubbleView.imageView.image = image;
    }else{
        __block __weak typeof(self) weakSelf = self;
        [_bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            CGFloat w = image.size.width/image.size.height*200 + weakSelf.bubbleMargin.left + weakSelf.bubbleMargin.right;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    if (w <= kEMMessageImageSizeWidth) {
                        [weakSelf updateBubbleWidth:w];
                    }else{
                        [weakSelf updateBubbleWidth:kEMMessageImageSizeWidth];
                    }
                    weakSelf.bubbleView.imageView.image = image;
                }
            });
        }];
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setupGifBubbleView];
//    self.bubbleWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
//    [self addConstraint:self.bubbleWidth];
    _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    bubbleMargin = UIEdgeInsetsMake(0, bubbleMargin.left, 0, bubbleMargin.right);
    [_bubbleView updateGifMargin:bubbleMargin];
}

-(void)updateBubbleWidth:(CGFloat)width {
    if (self.bubbleWidth) {
        [self removeConstraint:self.bubbleWidth];
    }
    self.bubbleWidth = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    [self addConstraint:self.bubbleWidth];
    if ([self needsUpdateConstraints]) {
        [self updateConstraints];
    }
}

/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model   消息model
 @return 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
}

/*!
 @method
 @brief 获取cell的高度
 @discussion
 @param model   消息model
 @return  返回cell的高度
 */
+ (CGFloat)cellHeight:(id<IMessageModel>)model
{
    CGFloat h =200;
    EaseBaseMessageCell *cell = [EaseBaseMessageCell appearance];
    CGFloat maxWidth = kEMMessageImageSizeWidth - cell.bubbleMargin.left -cell.bubbleMargin.right;
    BoxinMessageModel* bm = (BoxinMessageModel*)model;
    CGFloat mw = 0;
    CGFloat mh = 0;
    if (bm) {
        mw=bm.faceW;
        mh=bm.faceH;
    }
    if (mh != 0 && mw != 0) {
        CGFloat wt = mw/mh*(200+cell.bubbleMargin.top + cell.bubbleMargin.bottom);
        if (wt >maxWidth) {
            h = mh/mw*maxWidth;
        }
    }else{
        UIImage* t = [[SDImageCache sharedImageCache] imageFromCacheForKey:model.fileURLPath];
         if (t) {
            CGFloat wt = t.size.width/t.size.height*(200+cell.bubbleMargin.top + cell.bubbleMargin.bottom);
            if (wt > maxWidth) {
                CGFloat ht = t.size.height/t.size.width*maxWidth;
                h=ht;
            }
        }
    }
    
    CGFloat minHeight = cell.avatarSize + 10 * 2;
    CGFloat height = 0;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height +=h;
    if (!model.isSender && model.message.chatType == EMChatTypeGroupChat) {
        height += [EaseBaseMessageCell appearance].messageNameHeight;
    }
    height = height > minHeight ? height : minHeight;
    
    return height;
}

@end
