//
//  EaseMessageViewController+MyChat.h
//  boxin
//
//  Created by guduzhonglao on 6/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "EaseUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseMessageViewController (MyChat)<UIDocumentPickerDelegate>

- (void)_recallWithMessage:(EMMessage *)msg text:(NSString *)text isSave:(BOOL)isSave;
- (void)_DeleteWithMessage:(EMMessage *)msg text:(NSString *)text isDelete:(BOOL)isDetele;
-(void)moreViewFileTransferAction:(EaseChatBarMoreView *)moreView;
- (EMChatType)_messageTypeFromConversationType;
-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress;
- (void)_DeleteWithMessageID:(NSString *)msgID text:(NSString *)text isDelete:(BOOL)isDetele;
@end

NS_ASSUME_NONNULL_END
