//
//  LongTapFunction.h
//  boxin
//
//  Created by Sea on 2019/7/11.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LongTapFunction : NSObject
-(void)setLongTapWithImage:(UIImage *)image;
@property (nonatomic,strong) UIImageView *sentImg;
@end

NS_ASSUME_NONNULL_END
