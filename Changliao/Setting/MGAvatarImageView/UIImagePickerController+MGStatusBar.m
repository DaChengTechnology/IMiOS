//
//  UIImagePickerController+MGStatusBar.m
//  MGAvatarImageView
//
//  Created by mango on 2017/6/16.
//  Copyright © 2017年 mango. All rights reserved.
//

#import "UIImagePickerController+MGStatusBar.h"
#import <objc/runtime.h>

static void *mg_statusBarStyleKey = &mg_statusBarStyleKey;

@implementation UIImagePickerController (MGStatusBar)

- (UIStatusBarStyle)mg_statusBarStyle {
    return [objc_getAssociatedObject(self, &mg_statusBarStyleKey) integerValue];
}

- (void)setMg_statusBarStyle:(UIStatusBarStyle)mg_statusBarStyle {
    objc_setAssociatedObject(self, &mg_statusBarStyleKey, @(mg_statusBarStyle), OBJC_ASSOCIATION_ASSIGN);
}

// 状态栏设置
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.mg_statusBarStyle;
}
@end
