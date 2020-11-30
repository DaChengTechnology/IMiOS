//
//  ZZQAvatarPicker.h
//  ZZQAvatarPicker
//
//  Created by 郑志强 on 2018/10/31.
//  Copyright © 2018 郑志强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ZZQAvatarPicker : NSObject

+ (void)startSelected:(void(^)(UIImage *image))compleiton;

- (void)startSelected:(void (^)(UIImage * _Nonnull))compleiton;

@property (nonatomic,assign) BOOL onlyPic;

@end

NS_ASSUME_NONNULL_END
