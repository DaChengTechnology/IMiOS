//
//  MessageFunctionExtension.m
//  boxin
//
//  Created by Sea on 2019/7/10.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "MessageFunctionExtension.h"



static NSString *kConversation_IsRead = @"kHaveAtMessage";
static int kConversation_AtYou = 1;
static int kConversation_AtAll = 2;
@implementation MessageFunctionExtension
//发送
-(void)SendMessage:(EMMessage *)messages withsendArr:(NSArray *)arr
{
 
    
    // @某些人
    messages.ext = @{@"em_at_list":arr};
}
//接收
-(void)didReceiveMessages:(NSArray *)messages withUserId:(NSString *)UserId withmsg:(EMMessage *)mes
{
    
    // 获取当前登录用户环信ID
    NSString *currentUserId = UserId;
    
    /*  NSString *currentUserId = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey: kSDKUsername];  */
    // 被@用户环信ID
    for(EMMessage *msg in messages){
        NSArray *atList = [msg.ext objectForKey:@"em_at_list"];
        for (NSString *atName in atList) {
            if ([atName isEqualToString:currentUserId]) {
                // 当前用户被@，需要单独处理UI
            }
        }
    }
}

@end
