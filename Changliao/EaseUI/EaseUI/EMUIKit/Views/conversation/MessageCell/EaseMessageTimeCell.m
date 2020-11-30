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

#import "EaseMessageTimeCell.h"
#import "Public.h"
#import "DIYCustomLabel.h"

CGFloat const EaseMessageTimeCellPadding = 5;

@interface EaseMessageTimeCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView*bkView;

@end

@implementation EaseMessageTimeCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseMessageTimeCell *cell = [self appearance];
    cell.titleLabelColor = [UIColor blackColor];
    cell.titleLabelFont = [UIFont systemFontOfSize:12];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self _setupSubview];
    }
    
    return self;
}

#pragma mark - setup subviews

- (void)_setupSubview
{
//    _bkView = [UIView new];
//    _bkView.backgroundColor = kColorFromARGBHex(0xffffff, 0.8);
//    _bkView.layer.cornerRadius = 5;
//    [self.contentView addSubview:_bkView];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = kColorFromARGBHex(0xffffff, 0.8);
    _titleLabel.textColor = _titleLabelColor;
    _titleLabel.font = _titleLabelFont;
    _titleLabel.layer.cornerRadius = kSCRATIO(5);
    _titleLabel.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_titleLabel];
    
    [self _setupTitleLabelConstraints];
}

#pragma mark - Setup Constraints

- (void)_setupTitleLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kSCRATIO(18)]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(15)]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-EaseMessageTimeCellPadding]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-EaseMessageTimeCellPadding]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:EaseMessageTimeCellPadding]];
}

#pragma mark - setter

- (void)setTitle:(NSString *)title
{
    if (title) {
        if ([title isEqualToString:@""]) {
            _title = @"";
            _titleLabel.backgroundColor = [UIColor clearColor];
        }else{
            _title = [NSString stringWithFormat:@" %@   ",title];
            _titleLabel.backgroundColor = kColorFromARGBHex(0xffffff, 0.8);
        }
    }else{
        _title = @"";
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    _titleLabel.text = _title;
//    [self needsUpdateConstraints];
//    [self.bkView needsUpdateConstraints];
//    [_titleLabel sizeToFit];
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont
{
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = _titleLabelFont;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor
{
    _titleLabelColor = titleLabelColor;
    _titleLabel.textColor = _titleLabelColor;
}

#pragma mark - public

+ (NSString *)cellIdentifier
{
    return @"MessageTimeCell";
}

@end
