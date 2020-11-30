//
//  MGAvatarImageView.h
//  MGAvatarImageView
//
//  Created by mango on 2017/6/15.
//  Copyright © 2017年 mango. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MGAvatarImageViewType) {
    MGAvatarImageViewTypeAvatar,        //将图片裁剪成正方形
    MGAvatarImageViewTypeOriginScale,   //保持图片的原始尺寸
};

@class MGAvatarImageView;
@protocol MGAvatarImageViewDelegate <NSObject>

- (void)imageView:(MGAvatarImageView *)imageView didSelectImage:(UIImage*)image;


@end
@interface MGAvatarImageView : UIImageView
@property(nonatomic, weak)id<MGAvatarImageViewDelegate> delegate;
/** 图片是否直接使用原始图片的宽高比例，默认是NO*/
@property(nonatomic, assign)MGAvatarImageViewType imageType;
/** 导航栏上的Item文字颜色，默认是blackColor*/
@property(nonatomic, strong)UIColor *navItemColor;
/** 导航栏上图片(返回箭头)的颜色，默认是blackColor*/
@property(nonatomic, strong)UIColor *navImageColor;
/** 设置navigationBar的背景颜色，默认是whiteColor*/
@property(nonatomic, strong)UIColor *navBarBackgroundColor;
/** 设置UIActionSheet\UIAlertViewController 的文字颜色 默认是blackColor*/
@property(nonatomic, strong)UIColor *sheetTitleColor;
/** 默认是UIStatusBarStyleDefault*/
@property(nonatomic, assign)UIStatusBarStyle statusBarStyle;


/** 调用该方法也可以弹出选择列表，用于点击控件所在的父控件比如Cell的时候有弹出头像选择的需求的时候 */
- (void)show;
@end
