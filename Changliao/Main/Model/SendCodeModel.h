//
//  SendCodeModel.h
//  boxin
//
//  Created by Sea on 2019/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendCodeModel : NSObject
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSString *data;
@property (nonatomic,strong) NSString *message;
@end

NS_ASSUME_NONNULL_END
