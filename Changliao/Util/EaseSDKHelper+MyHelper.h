//
//  EaseSDKHelper+MyHelper.h
//  boxin
//
//  Created by guduzhonglao on 7/6/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "EaseUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseSDKHelper (MyHelper)

+ (EMMessage *)sendFileMessageWithURL:(NSURL *)url
                          displayName:(NSString*)displayName
                                   to:(NSString *)to
                          messageType:(EMChatType)messageType
                           messageExt:(NSDictionary *)messageExt;

@end

NS_ASSUME_NONNULL_END
