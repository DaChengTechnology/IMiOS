//
//  EaseMessageViewController+MyChat.m
//  boxin
//
//  Created by guduzhonglao on 6/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "EaseMessageViewController+MyChat.h"
#import "EaseSDKHelper+MyHelper.h"

@implementation EaseMessageViewController (MyChat)

- (void)_recallWithMessage:(EMMessage *)msg text:(NSString *)text isSave:(BOOL)isSave
{
    dispatch_async(self.messageQueue, ^{
        EMMessage *message = [EaseSDKHelper getTextMessage:text to:msg.conversationId messageType:msg.chatType messageExt:@{@"em_recall":@(YES)}];
        message.isRead = YES;
        [message setTimestamp:msg.timestamp];
        [message setLocalTime:msg.localTime];
        id<IMessageModel> newModel = [[EaseMessageModel alloc] initWithMessage:message];
        __block NSUInteger index = NSNotFound;
        [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
            if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                if ([msg.messageId isEqualToString:model.message.messageId])
                {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        if (index != NSNotFound) {
            __block NSUInteger sourceIndex = NSNotFound;
            [self.messsagesSource enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL *stop){
                if ([message isKindOfClass:[EMMessage class]]) {
                    if ([msg.messageId isEqualToString:message.messageId])
                    {
                        sourceIndex = idx;
                        *stop = YES;
                    }
                }
            }];
            if (sourceIndex != NSNotFound) {
                [self.messsagesSource replaceObjectAtIndex:sourceIndex withObject:newModel.message];
            }
            [self.dataArray replaceObjectAtIndex:index withObject:newModel];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        if (isSave) {
            [self.conversation insertMessage:message error:nil];
        }
    });
}
- (void)_DeleteWithMessage:(EMMessage *)msg text:(NSString *)text isDelete:(BOOL)isDetele
{
    __block __weak typeof(self) weakSelf = self;
    dispatch_async(self.messageQueue, ^{
        __block NSUInteger index = NSNotFound;
            [weakSelf.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                    if ([msg.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            if (index != NSNotFound) {
                __block NSUInteger sourceIndex = NSNotFound;
                [weakSelf.messsagesSource enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL *stop){
                    if ([message isKindOfClass:[EMMessage class]]) {
                        if ([msg.messageId isEqualToString:message.messageId])
                        {
                            sourceIndex = idx;
                            *stop = YES;
                        }
                    }
                }];
                if (sourceIndex != NSNotFound) {
        //            [self.messsagesSource replaceObjectAtIndex:sourceIndex withObject:newModel.message];
                    [self.messsagesSource removeObjectAtIndex:sourceIndex];
                }
                if (index > 0 && [[weakSelf.dataArray objectAtIndex:index - 1] isKindOfClass:[NSString class]]) {
                    if ((index == [weakSelf.dataArray count] - 1) && (index > 0)) {
                        if ([weakSelf.dataArray count] > index) {
                            [weakSelf.dataArray removeObjectAtIndex:index];
                        }
                        [weakSelf.dataArray removeObjectAtIndex:index-1];
                    }
                    if ((index + 1 < [weakSelf.dataArray count]) && (index > 0)) {
                        if ([[weakSelf.dataArray objectAtIndex:index + 1] isKindOfClass:[NSString class]]) {
                            if ([weakSelf.dataArray count] > index) {
                                [weakSelf.dataArray removeObjectAtIndex:index];
                            }
                            [weakSelf.dataArray removeObjectAtIndex:index-1];
                        }
                    }
                }
                if ([weakSelf.dataArray count] > index) {
                    [weakSelf.dataArray removeObjectAtIndex:index];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
    });
    
    if (isDetele) {
//        [self.conversation insertMessage:message error:nil];
        [self.conversation deleteMessageWithId:msg.messageId error:nil];
    }
}

- (void)_DeleteWithMessageID:(NSString *)msgID text:(NSString *)text isDelete:(BOOL)isDetele
{
    __block __weak typeof(self) weakSelf = self;
    dispatch_async(self.messageQueue, ^{
        __block NSUInteger index = NSNotFound;
        [weakSelf.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
            if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                if ([msgID isEqualToString:model.message.messageId])
                {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        if (index != NSNotFound) {
            __block NSUInteger sourceIndex = NSNotFound;
            [weakSelf.messsagesSource enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL *stop){
                if ([message isKindOfClass:[EMMessage class]]) {
                    if ([msgID isEqualToString:message.messageId])
                    {
                        sourceIndex = idx;
                        *stop = YES;
                    }
                }
            }];
            if (sourceIndex != NSNotFound) {
                //            [self.messsagesSource replaceObjectAtIndex:sourceIndex withObject:newModel.message];
                [weakSelf.messsagesSource removeObjectAtIndex:sourceIndex];
            }
            if (index > 0 && [[weakSelf.dataArray objectAtIndex:index - 1] isKindOfClass:[NSString class]]) {
                if ((index == [weakSelf.dataArray count] - 1) && (index > 0)) {
                    if ([weakSelf.dataArray count] > index) {
                        [weakSelf.dataArray removeObjectAtIndex:index];
                    }
                    [weakSelf.dataArray removeObjectAtIndex:index-1];
                }
                if ((index + 1 < [weakSelf.dataArray count]) && (index > 0)) {
                    if ([[weakSelf.dataArray objectAtIndex:index + 1] isKindOfClass:[NSString class]]) {
                        if ([weakSelf.dataArray count] > index) {
                            [weakSelf.dataArray removeObjectAtIndex:index];
                        }
                        [weakSelf.dataArray removeObjectAtIndex:index-1];
                    }
                }
            }
            if ([weakSelf.dataArray count] > index) {
                [weakSelf.dataArray removeObjectAtIndex:index];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    });
    
    if (isDetele) {
        //        [self.conversation insertMessage:message error:nil];
        [self.conversation deleteMessageWithId:msgID error:nil];
    }
}
// 第1435行
-(void)moreViewFileTransferAction:(EaseChatBarMoreView *)moreView{
    
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    // ios8+才支持icloud drive功能
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        //older than iOS 8 code here
        NSLog(@"IOS8以上才支持icloud drive.");
    } else {
        //iOS 8 specific code here
        NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
        
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}

// 选中icloud里的pdf文件
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self sendFileMessageWithURL:newURL displayName:[[url path] lastPathComponent]];
        }];
        [url stopAccessingSecurityScopedResource];
    }else{
        //Error handling
        
    }
}
// 第2083行
- (void)sendFileMessageWithURL:(NSURL *)url displayName:(NSString*)displayName
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[url path]]){
        long long lenth = [[manager attributesOfItemAtPath:[url path] error:nil] fileSize];
        if (lenth > 10 * 1024 * 1024) {
            [SVProgressHUD showErrorWithStatus:@"大于10M不能发送"];
            return;
        }
    }
    id progress = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [self.dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeFile];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendFileMessageWithURL:url
                                                   displayName:displayName
                                                            to:self.conversation.conversationId
                                                   messageType:[self _messageTypeFromConversationType]
                                                    messageExt:nil];

    [self sendFileMessageWith:message];
    
}

@end
