//
//  MessageFunctionExtension.h
//  boxin
//
//  Created by Sea on 2019/7/10.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageFunctionExtension : NSObject
//发送时
-(void)SendMessage:(EMMessage *)messages withsendArr:(NSArray *)arr;
//接收时
-(void)didReceiveMessages:(NSArray *)messages withUserId:(NSString *)UserId withmsg:(EMMessage *)mes;
@end

NS_ASSUME_NONNULL_END
