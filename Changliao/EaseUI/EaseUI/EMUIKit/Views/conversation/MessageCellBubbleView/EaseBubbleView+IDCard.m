//
//  EaseBubbleView+IDCard.m
//  HappyChat
//
//  Created by Stn on 2019/9/13.
//  Copyright © 2019 onlysea. All rights reserved.
//

#import "EaseBubbleView+IDCard.h"
#import "Public.h"

@implementation EaseBubbleView (IDCard)

-(void)setupIDCardBubbleView{
    self.cardBackImg = [[UIImageView alloc]init];
    self.cardBackImg.image=[UIImage imageNamed:@"messageIDCard"];
    
    self.cardBackImg.translatesAutoresizingMaskIntoConstraints = NO;

    [self.backgroundImageView addSubview:self.cardBackImg];
    
    self.userIMg=[[UIImageView alloc]init];
    self.userIMg.translatesAutoresizingMaskIntoConstraints = NO;
    ViewRadius(self.userIMg, kSCRATIO(25));

    [self.cardBackImg addSubview:self.userIMg];
    
    self.userNameLab= [UILabel new];
    self.userNameLab.font = kFONT(15);
    self.userNameLab.textColor = kColorFromRGBHex(0xEC582E);
    self.userNameLab.textAlignment = NSTextAlignmentCenter;
    self.userNameLab.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cardBackImg addSubview:self.userNameLab];
    
    self.userIDCardLab=[UILabel new];
    self.userIDCardLab.font = kFONT(13);
    self.userIDCardLab.textColor = kColorFromRGBHex(0xEC582E);
    self.userIDCardLab.textAlignment = NSTextAlignmentCenter;
    self.userIDCardLab.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cardBackImg addSubview:self.userIDCardLab];
    
    self.cardLineView=[[UIView alloc]init];
    self.cardLineView.backgroundColor = kColorFromRGBHex(0xEC582E);
    self.cardLineView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cardBackImg addSubview:self.cardLineView];
    
    UILabel * placerHoder = [UILabel new];
    placerHoder.font = kFONT(13);
    placerHoder.textColor = kColorFromRGBHex(0xEC582E);
    placerHoder.textAlignment = NSTextAlignmentCenter;
    placerHoder.text = @"个人名片";
    self.placerHoderLab = placerHoder;
    [self.cardBackImg addSubview:self.placerHoderLab];
    self.placerHoderLab.translatesAutoresizingMaskIntoConstraints = NO;

    self.cardBackImg.userInteractionEnabled=YES;
    
    
}
-(void)setIDCardBubbleView{
    [self.marginConstraints removeAllObjects];
    //背景图片
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:kSCRATIO(225)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(110)]];
    
    //用户头像
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(20)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(20)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:kSCRATIO(50)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(50)]];
    //用户名字
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(27)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-10)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userIMg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(10)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(15)]];
    
    //用户开心聊账号
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameLab attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kSCRATIO(9)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userIMg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(13)]];
    
    //placeHodel
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kSCRATIO(-12)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(13)]];
    
    //分割线
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.placerHoderLab attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(-6)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(30)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-30)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1]];
}
-(void)setIDCardReciveBubbleView{
    [self.marginConstraints removeAllObjects];
    //背景图片
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:kSCRATIO(225)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardBackImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(110)]];
    
    //用户头像
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(20)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(20)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:kSCRATIO(50)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIMg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(50)]];
    //用户名字
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(27)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-10)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userIMg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(10)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userNameLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(15)]];
    
    //用户开心聊账号
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameLab attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kSCRATIO(9)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userIMg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.userIDCardLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(13)]];
    
    //placeHodel
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kSCRATIO(-12)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(0)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.placerHoderLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kSCRATIO(13)]];
    
    //分割线
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.placerHoderLab attribute:NSLayoutAttributeTop multiplier:1.0 constant:kSCRATIO(-6)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kSCRATIO(30)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.cardBackImg attribute:NSLayoutAttributeRight multiplier:1.0 constant:kSCRATIO(-30)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.cardLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1]];
    
    
    
}

-(void)updateIDCardMargin:(UIEdgeInsets)margin{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
}

@end
