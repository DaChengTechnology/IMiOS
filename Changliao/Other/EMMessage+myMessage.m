//
//  EMMessage+myMessage.m
//  boxin
//
//  Created by guduzhonglao on 7/13/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "EMMessage+myMessage.h"

@implementation EMMessage (myMessage)
- (id)copyWithZone:(nullable NSZone *)zone {
    EMMessage* m = [[[self class] allocWithZone:zone] init];
    m.messageId = self.messageId;
    m.conversationId = self.conversationId;
    m.body = self.body;
    m.direction = self.direction;
    m.from = self.from;
    m.to = self.to;
    m.timestamp = self.timestamp;
    m.localTime = self.localTime;
    m.chatType = self.chatType;
    m.status = self.status;
    m.isReadAcked = self.isReadAcked;
    m.isDeliverAcked = self.isDeliverAcked;
    m.isRead = self.isRead;
    m.body = self.body;
    m.ext = self.ext;
    return m;
}
@end
