//
//  UIButton+YLY.h
//  EastOffice2.0
//
//  Created by YLY on 2017/12/9.
//  Copyright © 2017年 EO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ButtonEdgeInsetsStyle) {
    ButtonEdgeInsetsStyle_Top,
    ButtonEdgeInsetsStyle_Left,
    ButtonEdgeInsetsStyle_Right,
    ButtonEdgeInsetsStyle_Bottom
};

@interface UIButton (YLY)

+(UIButton *)CreatButtontext:(NSString *)text image:(UIImage *)image Font:(UIFont *)font Textcolor:(UIColor *)color ;

- (void)layoutWithEdgeInsetsStyle:(ButtonEdgeInsetsStyle)style
                  imageTitleSpace:(CGFloat)space;

@end
