//
//  EaseSDKHelper+MyHelper.m
//  boxin
//
//  Created by guduzhonglao on 7/6/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "EaseSDKHelper+MyHelper.h"

@implementation EaseSDKHelper (MyHelper)

+ (EMMessage *)sendFileMessageWithURL:(NSURL *)url
                          displayName:(NSString*)displayName
                                   to:(NSString *)to
                          messageType:(EMChatType)messageType
                           messageExt:(NSDictionary *)messageExt
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithData:data displayName:displayName];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

@end
