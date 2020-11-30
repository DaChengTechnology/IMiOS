/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseMessageViewController.h"

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+GIF.h"
#import "UIImageView+ASGif.h"

#import "NSDate+Category.h"
#import "EaseUsersListViewController.h"
#import "EaseMessageReadManager.h"
#import "EaseEmotionManager.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseCustomMessageCell.h"
#import "EaseLocalDefine.h"
#import "EaseSDKHelper.h"
#import "MWPhotoBrowser.h"
#import <Masonry/Masonry.h>
#import "Public.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "Chaangliao-Swift.h"

#define KHintAdjustY    50

#define IOS_VERSION [[UIDevice currentDevice] systemVersion]>=9.0

typedef enum : NSUInteger {
    EMRequestRecord,
    EMCanRecord,
    EMCanNotRecord,
} EMRecordResponse;


@implementation EaseAtTarget
- (instancetype)initWithUserId:(NSString*)userId andNickname:(NSString*)nickname
{
    if (self = [super init]) {
        _userId = [userId copy];
        _nickname = [nickname copy];
    }
    return self;
}
@end

@interface EaseMessageViewController ()<EaseMessageCellDelegate,MWPhotoBrowserDelegate,SaveButtonDelegete>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    NSMutableArray *_atTargets;
    
    BOOL _isRecording;
    NSMutableArray *ImageArray;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isBottom;
@property (nonatomic, strong) NSMutableArray *atTargets;
@property (nonatomic,strong) NSMutableArray *ImageMArr;
@end

@implementation EaseMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        
        _messageCountOfPage = 10;
        _timeCellHeight = kSCRATIO(35);
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        
        [_conversation markAllMessagesAsRead:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isBottom = NO;
    // Do any additional setup after loading the view.
    _ImageMArr = [NSMutableArray array];
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImagePicker) name:@"hideImagePicker" object:nil];
    
    //Initialization
    CGFloat chatbarHeight = [EaseChatToolbar defaultHeight];
    EMChatToolbarType barType = self.conversation.type == EMConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup;
    self.chatToolbar = [[EaseChatToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - chatbarHeight - iPhoneX_BOTTOM_HEIGHT, self.view.frame.size.width, chatbarHeight) type:barType];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //Initializa the gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    _messageQueue = dispatch_queue_create("hyphenate.com", NULL);
    _EMQueue=dispatch_queue_create("em.recive.com", DISPATCH_QUEUE_CONCURRENT);
    
    //Register the delegate
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:self.EMQueue];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:self.EMQueue];
    
    if (self.conversation.type == EMConversationTypeChatRoom)
    {
        [self joinChatroom:self.conversation.conversationId];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"], [UIImage imageNamed:@"chat_sender_audio_playing_000"], [UIImage imageNamed:@"chat_sender_audio_playing_001"], [UIImage imageNamed:@"chat_sender_audio_playing_002"]]];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_reciver_audio_playing_full"],[UIImage imageNamed:@"chat_reciver_audio_playing_000"], [UIImage imageNamed:@"chat_reciver_audio_playing_001"], [UIImage imageNamed:@"chat_reciver_audio_playing_002"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self setupEmotion];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offset = self.tableView.contentOffset.y;
        CGFloat ofSize = self.tableView.contentSize.height;
        CGFloat delta =   ofSize - offset ;
        NSLog(@"%f",delta);
        if (delta <= self.tableView.frame.size.height + 400) {
            _isBottom = YES ;
        }else
        {
            _isBottom = NO;
        }
        
        
        
        NSLog(@"%@",change);
        
//        if (self.isBottom == YES) {
//
//        }
    }
    
}

/*!
 @method
 @brief 设置表情
 @discussion 加载默认表情，如果子类实现了dataSource的自定义表情回调，同时会加载自定义表情
 @result
 */
- (void)setupEmotion
{
    if ([self.dataSource respondsToSelector:@selector(emotionFormessageViewController:)]) {
        NSArray* emotionManagers = [self.dataSource emotionFormessageViewController:self];
        [self.faceView setEmotionManagers:emotionManagers];
    } else {
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSString *name in [EaseEmoji allEmoji]) {
            EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
            [emotions addObject:emotion];
        }
        EaseEmotion *emotion = [emotions objectAtIndex:0];
        EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
        [self.faceView setEmotionManagers:@[manager]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    [self.tableView removeObserver:self
                        forKeyPath:@"contentOffset"
                           context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"   " style:UIBarButtonItemStylePlain target:nil action:nil];

    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
    [self _sendHasReadResponseForMessages:self.messsagesSource
    isRead:NO];
    if (self.scrollToBottomWhenAppear) {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewDidAppear = NO;
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - chatroom

- (void)saveChatroom:(EMChatroom *)chatroom
{
    NSString *chatroomName = chatroom.subject ? chatroom.subject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId])
    {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

/*!
 @method
 @brief 加入聊天室
 @discussion
 @result
 */
- (void)joinChatroom:(NSString *)chatroomId
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:@"正在加入..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMChatroom *chatroom = [[EMClient sharedClient].roomManager joinChatroom:chatroomId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                EaseMessageViewController *strongSelf = weakSelf;
                [strongSelf hideHud];
                if (error != nil) {
                    [strongSelf showHint:[NSString stringWithFormat:@"加入聊天室\'%@\'失败", chatroomId]];
                } else {
                    strongSelf.isJoinedChatroom = YES;
                    [strongSelf saveChatroom:chatroom];
                }
            }  else {
                if (!error || (error.code == EMErrorChatroomAlreadyJoined)) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        EMError *leaveError;
                        [[EMClient sharedClient].roomManager leaveChatroom:chatroomId error:&leaveError];
                        [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:nil];
                    });
                }
            }
        });
    });
}

#pragma mark - EMChatManagerChatroomDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    CGRect frame = self.chatToolbar.frame;
    [self showHint:[NSString stringWithFormat:@"\'%@\'加入聊天室\'%@\'", aUsername, aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    CGRect frame = self.chatToolbar.frame;
    [self showHint:[NSString stringWithFormat:@"\'%@\'离开聊天室\'%@\'", aUsername, aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason
{
    if ([_conversation.conversationId isEqualToString:aChatroom.chatroomId])
    {
        _isKicked = YES;
        __weak typeof(self) weakself = self;
        if (aReason == EMChatroomBeKickedReasonOffline) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(ಥ_ಥ)" message:[NSString stringWithFormat:@"离开聊天室\'%@\', 原因：账号离线. 是否重新加入聊天室？", aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"chatroom.join", @"Join") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakself joinChatroom:weakself.conversation.conversationId];
            }];
            [alertController addAction:okAction];
            
            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"alert.cancel", @"Cancel") style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakself.navigationController popToViewController:self animated:NO];
                [weakself.navigationController popViewControllerAnimated:YES];
            }]];
            [alertController setModalPresentationStyle:UIModalPresentationOverFullScreen];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            CGRect frame = self.chatToolbar.frame;
            [self showHint:[NSString stringWithFormat:@"被踢出聊天室\'%@\'", aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
            [self.navigationController popToViewController:self animated:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (NSMutableArray*)atTargets
{
    if (!_atTargets) {
        _atTargets = [NSMutableArray array];
    }
    return _atTargets;
}

#pragma mark - setter

//- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
//{
//    _isViewDidAppear =isViewDidAppear;
//    if (_isViewDidAppear)
//    {
//        NSMutableArray *unreadMessages = [NSMutableArray array];
//        for (EMMessage *message in self.messsagesSource)
//        {
//            if ([self shouldSendHasReadAckForMessage:message read:NO])
//            {
//                [unreadMessages addObject:message];
//            }
//        }
//        if ([unreadMessages count])
//        {
//            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
//        }
//        
//        [_conversation markAllMessagesAsRead:nil];
//    }
//}

- (void)setChatToolbar:(EaseChatToolbar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height - iPhoneX_BOTTOM_HEIGHT;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        [(EaseChatToolbar *)self.chatToolbar setDelegate:self];
        self.chatBarMoreView = (EaseChatBarMoreView*)[(EaseChatToolbar *)self.chatToolbar moreView];
        self.faceView = (EaseFaceView*)[(EaseChatToolbar *)self.chatToolbar faceView];
        self.recordView = (EaseRecordView*)[(EaseChatToolbar *)self.chatToolbar recordView];
    }
}

- (void)setDataSource:(id<EaseMessageViewControllerDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self setupEmotion];
}

- (void)setDelegate:(id<EaseMessageViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - private helper

/*!
 @method
 @brief tableView滑动到底部
 @discussion
 @result
 */
- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.subviews) {
        if (self.tableView.contentSize.height > self.tableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:animated];
        }
    }
}

/*!
 @method
 @brief 当前设备是否可以录音
 @discussion
 @param aCompletion 判断结果
 @result
 */
- (void)_canRecordCompletion:(void(^)(EMRecordResponse))aCompletion
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        }];
        if (aCompletion) {
            aCompletion(EMRequestRecord);
        }
    }
    else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        aCompletion(EMCanNotRecord);
    }
    else{
        aCompletion(EMCanRecord);
    }
}

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyMenuAction:)];
    }
    
    if (messageType == EMMessageBodyTypeText) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    //    MessageModel *playingModel = [self.EaseMessageReadManager stopMessageAudioModel];
    //    NSIndexPath *indexPath = nil;
    //    if (playingModel) {
    //        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    //    }
    //
    //    if (indexPath) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.tableView beginUpdates];
    //            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //            [self.tableView endUpdates];
    //        });
    //    }
}

/*!
 @method
 @brief mov格式视频转换为MP4格式
 @discussion
 @param movUrl   mov视频路径
 @result  MP4格式视频路径
 */
- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPreset640x480];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [EMCDDeviceManager dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

/*!
 @method
 @brief 通过当前会话类型，返回消息聊天类型
 @discussion
 @result
 */
- (EMChatType)_messageTypeFromConversationType
{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_customDownloadMessageFile:(EMMessage *)aMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message.autoTransfer", @"Please customize the  transfer attachment method") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    });
}

- (void)customDownloadVedioFile:(EMMessage*)aMessage
{
    __weak typeof(self) weakSelf = self;
    [weakSelf _reloadTableViewDataWithMessage:aMessage];
    [self.conversation updateMessageChange:aMessage error:nil];
}

/*!
 @method
 @brief 下载消息附件
 @discussion
 @param message  待下载附件的消息
 @result
 */
- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:@"获取缩略图失败!"];
        }
    };
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if ([videoBody.thumbnailRemotePath hasPrefix:@"http://hgjt-oss"]) {
                [self customDownloadVedioFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message attachment
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
                        if (!error) {
                            [weakSelf _reloadTableViewDataWithMessage:message];
                        }
                        else {
                            [weakSelf showHint:@"获取语音失败"];
                        }
                    }];
                }
            }
        }
    }
}

/*!
 @method
 @brief 传入消息是否需要发动已读回执
 @discussion
 @param message  待判断的消息
 @param read     消息是否已读
 @result
 */
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    return YES;
}

/*!
 @method
 @brief 为传入的消息发送已读回执
 @discussion
 @param messages  待发送已读回执的消息数组
 @param isRead    是否已读
 @result
 */
- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:isRead];
        }
        else{
            isSend = [self shouldSendHasReadAckForMessage:message
                                                     read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
//            message.isRead = YES;
            EMError* err;
            [self.conversation markMessageAsReadWithId:message.messageId error:&err];
            NSLog(@"%@",err);
        }
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (!self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

/*!
 @method
 @brief 位置消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EaseLocationViewController *locationController = [[EaseLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

/*!
 @method
 @brief 视频消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.message.body;
    
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:@"获取视频失败!"];
        return;
    }
    
    dispatch_block_t block = ^{
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
        else
        {
            [weakSelf showHint:@"获取缩略图失败!"];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath]) {
        [self showHint:@"begin downloading thumbnail image, click later"];
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:completion];
        }
        return;
    }
    
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        block();
        return;
    }
    
    [self showHudInView:self.view hint:@"正在获取视频..."];
    if (isCustomDownload) {
        [self _customDownloadMessageFile:model.message];
    } else {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
            [weakSelf hideHud];
            if (!error) {
                block();
            }else{
                [weakSelf showHint:@"获取视频失败!"];
            }
        }];
    }
}

/*!
 @method
 @brief 图片消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_imageMessageCellSelected:(id<IMessageModel>)model
{
    EaseMessageModel* MODEL = model;
    ImageArray = [NSMutableArray array];
    NSInteger index = -1;
    
    for (EMMessage * message in _messsagesSource) {
       
        if (message.body.type == EMMessageBodyTypeImage) {
            
            
            
            EMImageMessageBody *imageBody = (EMImageMessageBody*)[message body];
            NSString *localPath = [imageBody localPath];
            if (localPath && localPath.length > 0) {
                UIImage *image = [UIImage imageWithContentsOfFile:localPath];
             
            BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
            if ([imageBody type] == EMMessageBodyTypeImage) {
                if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                    if (imageBody.downloadStatus == EMDownloadStatusSuccessed)
                    {
                    
                       
                            [ImageArray addObject:image ];
                            NSLog(@"%@",MODEL.messageId);
                            NSLog(@"%@",message.messageId);
                            if ([MODEL.messageId isEqualToString:message.messageId])
                            {
                            index = ImageArray.count -1;
                            }
                        
        
                    }
                }
        }
            }
        }
    }
    

    
    __weak EaseMessageViewController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if ([imageBody type] == EMMessageBodyTypeImage) {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
            if (imageBody.downloadStatus == EMDownloadStatusSuccessed)
            {
                //send the acknowledgement
                [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [imageBody localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    if (image) {
                        [_ImageMArr addObject:image];
                        EaseMessageReadManager* m = [EaseMessageReadManager defaultManager];
                        m.photoBrowser.savedelegate = self;
                        [[EaseMessageReadManager defaultManager] showBrowserWithImages:ImageArray];

                       [[[EaseMessageReadManager defaultManager]photoBrowser] setCurrentPhotoIndex:index];
                        return;
                    }
                }
            }
            
            [weakSelf showHudInView:weakSelf.view hint:@"正在获取大图..."];
            
            void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    //send the acknowledgement
                    [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                    NSString *localPath = aMessage == nil ? model.fileLocalPath : [(EMImageMessageBody*)aMessage.body localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        //                        weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [ImageArray addObject:image];
                            EaseMessageReadManager* m = [EaseMessageReadManager defaultManager];
                            m.photoBrowser.savedelegate = self;
                            
                           
                            [[EaseMessageReadManager defaultManager] showBrowserWithImages:ImageArray];
                            [[[EaseMessageReadManager defaultManager]photoBrowser] setCurrentPhotoIndex:index];
                            
                            
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHint:@"获取大图失败!"];
            };
            
            if (isCustomDownload) {
                [self _customDownloadMessageFile:model.message];
            } else {
                [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:completion];
            }
        }else{
            //get the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:model.message];
            } else {
                [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                    if (!error) {
                        [weakSelf _reloadTableViewDataWithMessage:model.message];
                    }else{
                        [weakSelf showHint:@"获取缩略图失败!"];
                    }
                }];
            }
        }
    }}

- (void)SaveButtonWithIndex:(NSInteger)index {
    
    
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case PHAuthorizationStatusAuthorized: //已获取权限
                        UIImageWriteToSavedPhotosAlbum(self->ImageArray[index], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                        break;
    
                    case PHAuthorizationStatusDenied: //用户已经明确否认了这一照片数据的应用程序访问
                        break;
    
                    case PHAuthorizationStatusRestricted://此应用程序没有被授权访问的照片数据。可能是家长控制权限
                        break;
    
                    default://其他。。。
                        break;
                }
            });
        }];
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    __weak EaseMessageViewController *weakSelf = self;
    if (error) {
        [weakSelf showHint:@"保存失败!"];
        NSLog(@"保存失败");
    }else
    {
        [weakSelf showHint:@"保存成功!"];
        NSLog(@"保存成功");
    }
}




/*!
 @method
 @brief 语音消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {
        [self showHint:@"正在下载语音，稍后点击"];
        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed || downloadStatus == EMDownloadStatusPending)
    {
        [self showHint:@"正在下载语音，稍后点击"];
        BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:nil];
        }
        
        return;
    }
    
    // play the audio
    if (model.bodyType == EMMessageBodyTypeVoice) {
        //send the acknowledgement
        if (_isPlayingAudio) {
            [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak EaseMessageViewController *weakSelf = self;
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFocusView" object:nil];
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak EaseMessageViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFocusView" object:nil];
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

- (void)_callMessageCellSelected:(id<IMessageModel>)model
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageViewController:didSelectCallMessageModel:)]) {
        [self.delegate messageViewController:self didSelectCallMessageModel:model];
    }
}

#pragma mark - pivate data

/*!
 @method
 @brief 加载历史消息
 @discussion
 @param messageId 参考消息的ID
 @param count     获取条数
 @param isAppend  是否在dataArray直接添加
 @result
 */
- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    void (^refresh)(NSArray *messages) = ^(NSArray *messages) {
        dispatch_async(self->_messageQueue, ^{
            //Format the message
            NSArray *formattedMessages = [weakSelf formatMessages:messages];
            if ([formattedMessages count] == 0) {
                return ;
            }
            if(weakSelf){
                __block NSInteger scrollToIndex = 0;
                if (isAppend) {
                    [weakSelf.messsagesSource insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                    
                    //Combine the message
                    dispatch_async(dispatch_get_main_queue(), ^{
                        id object = [weakSelf.dataArray firstObject];
                        if ([object isKindOfClass:[NSString class]]) {
                            NSString *timestamp = object;
                            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model]) {
                                    [weakSelf.dataArray removeObjectAtIndex:0];
                                    *stop = YES;
                                }
                            }];
                        }
                        scrollToIndex = [weakSelf.dataArray count];
                        [weakSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
                    });
                }
                else {
                    [weakSelf.messsagesSource removeAllObjects];
                    [weakSelf.messsagesSource addObjectsFromArray:messages];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.dataArray removeAllObjects];
                        [weakSelf.dataArray addObjectsFromArray:formattedMessages];
                    });
                }
                
                EMMessage *latest = [weakSelf.messsagesSource lastObject];
                weakSelf.messageTimeIntervalTag = latest.timestamp;
            }
            //Refresh the page
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    EaseMessageViewController *strongSelf = weakSelf;
                    [strongSelf.tableView reloadData];
                    if (!messageId) {
                        [strongSelf _scrollViewToBottom:NO];
                    }else{
                        if (strongSelf.dataArray.count>formattedMessages.count) {
                            [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:formattedMessages.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        }
                    }
                }
            });
            
            //re-download all messages that are not successfully downloaded
            for (EMMessage *message in messages)
            {
                [weakSelf _downloadMessageAttachments:message];
            }
            
            //send the read acknoledgement
            [weakSelf _sendHasReadResponseForMessages:messages
                                               isRead:NO];
        });
    };
    
    [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError) {
            if ([aMessages count] > 0) {
                refresh(aMessages);
            }
            if (aMessages.count < count && aMessages.count > 1) {
                NSString* msgid;
                for (EMMessage* m in aMessages) {
                    if (m.body.type == EMMessageBodyTypeText) {
                        if (![[(EMTextMessageBody*)m.body text] isEqualToString:@""]) {
                            if (m.ext) {
                                if (![m.ext[@"em_recall"] boolValue]) {
                                    msgid = m.messageId;
                                    break;
                                }
                            }
                        }
                    }else{
                        msgid = m.messageId;
                        break;
                    }
                }
                [[EMClient sharedClient].chatManager asyncFetchHistoryMessagesFromServer:self.conversation.conversationId conversationType:self.conversation.type startMessageId:msgid pageSize:count - [aMessages count] completion:^(EMCursorResult *aResult, EMError *aError) {
                    if (!aError) {
                        if ([aResult.list count] > 0) {
                            [self.conversation markAllMessagesAsRead:nil];
                            refresh(aResult.list);
                        }
                    }
                }];
            }
        }
    }];
}

#pragma mark - GestureRecognizer

-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        BOOL canLongPress = NO;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
            canLongPress = [_dataSource messageViewController:self
                                   canLongPressRowAtIndexPath:indexPath];
        }
        
        if (!canLongPress) {
            return;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
            [_dataSource messageViewController:self
                    didLongPressRowAtIndexPath:indexPath];
        }
        else{
            id object = [self.dataArray objectAtIndex:indexPath.row];
            if (![object isKindOfClass:[NSString class]]) {
                EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell becomeFirstResponder];
                _menuIndexPath = indexPath;
                [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //time cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    
    id<IMessageModel> model = object;
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:cellForMessageModel:)]) {
        UITableViewCell *cell = [_delegate messageViewController:tableView cellForMessageModel:model];
        if (cell) {
            if ([cell isKindOfClass:[EaseMessageCell class]]) {
                EaseMessageCell *emcell= (EaseMessageCell*)cell;
                if (emcell.delegate == nil) {
                    emcell.delegate = self;
                }
            }
            return cell;
        }
    }
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
        BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
        if (flag) {
            NSString *CellIdentifier = [EaseCustomMessageCell cellIdentifierWithModel:model];
            //send cell
            EaseCustomMessageCell *sendCell = (EaseCustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (sendCell == nil) {
                sendCell = [[EaseCustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(emotionURLFormessageViewController:messageModel:)]) {
                EaseEmotion *emotion = [_dataSource emotionURLFormessageViewController:self messageModel:model];
                if (emotion) {
                    if (![emotion.emotionOriginal isEqualToString:@""]) {
                        model.image = [UIImage imageWithContentsOfFile:emotion.emotionOriginal];
                    }else{
                        model.image = nil;
                    }
                    model.fileURLPath = emotion.emotionOriginalURL;
                }
                sendCell.model = model;
                sendCell.delegate = self;
            }
            return sendCell;
        }
    }
    
    NSString *CellIdentifier = [EaseMessageCell cellIdentifierWithModel:model];
    
    EaseBaseMessageCell *sendCell = (EaseBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (sendCell == nil) {
        sendCell = [[EaseBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
    }
    
    sendCell.model = model;
    return sendCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>=[self.dataArray count]) {
        return 0;
    }
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:heightForMessageModel:withCellWidth:)]) {
            CGFloat height = [_delegate messageViewController:self heightForMessageModel:model withCellWidth:tableView.frame.size.width];
            if (height) {
                return height;
            }
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                return [EaseCustomMessageCell cellHeight:model];
            }
        }
        
        return [EaseBaseMessageCell cellHeightWithModel:model];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data != nil) {
                                [self sendImageMessageWithData:data];
                            } else {
                                [self showHint:@"图片太大，请选择其他图片"];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - EaseMessageCellDelegate

- (void)messageCellSelected:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:)]) {
        BOOL flag = [_delegate messageViewController:self didSelectMessageModel:model];
        if (flag) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
            return;
        }
    }
    
    switch (model.bodyType) {
        case EMMessageBodyTypeText:
        {
            if (model.message.direction == EMMessageDirectionReceive && [model.message.ext count] > 0) {
                NSString *conferenceId = [model.message.ext objectForKey:@"conferenceId"];
                if ([conferenceId length] == 0) {
                    conferenceId = [model.message.ext objectForKey:@"em_conference_id"];
                }
                if ([conferenceId length] > 0) {
                    [self _callMessageCellSelected:model];
                }
            }
        }
            break;
        case EMMessageBodyTypeImage:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            [self _locationMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            [self _videoMessageCellSelected:model];
            
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
            [self showHint:@"Custom implementation!"];
        }
            break;
        default:
            break;
    }
}

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EaseMessageCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            [weakself _refreshAfterSentMessage:message];
        }
        else {
            [weakself.tableView reloadData];
        }
    }];
    
    [self.tableView reloadData];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectAvatarMessageModel:)]) {
        [_delegate messageViewController:self didSelectAvatarMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    CGRect rect = self.tableView.frame;
    rect.origin.y = 0;
    rect.size.height = self.view.frame.size.height - toHeight - iPhoneX_BOTTOM_HEIGHT;
    self.tableView.frame = rect;
    if (!self.tableView.isDecelerating) {
        [self _scrollViewToBottom:NO];
    }
}

- (void)inputTextViewWillBeginEditing:(EaseTextView *)inputTextView
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)inputTextViewDidBeginEditing:(EaseTextView *)inputTextView
{
    if (self.conversation.type == EMConversationTypeChat && self.isTyping) {
        NSString *from = [[EMClient sharedClient] currentUsername];
        
        EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"TypingBegin"];
        body.isDeliverOnlineOnly = YES;
        EMMessage *msg = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:nil];
        [[EMClient sharedClient].chatManager sendMessage:msg progress:nil completion:nil];
    }
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
        [self.atTargets removeAllObjects];
    }
    
    if (self.conversation.type == EMConversationTypeChat && self.isTyping) {
        NSString *from = [[EMClient sharedClient] currentUsername];
        
        EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"TypingEnd"];
        body.isDeliverOnlineOnly = YES;
        EMMessage *msg = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:nil];
        [[EMClient sharedClient].chatManager sendMessage:msg progress:nil completion:nil];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:selectAtTarget:)] && self.conversation.type == EMConversationTypeGroupChat) {
        location += 1;
        __weak typeof(self) weakSelf = self;
        [self.delegate messageViewController:self selectAtTarget:^(EaseAtTarget *target) {
            __strong EaseMessageViewController *strongSelf = weakSelf;
            if (strongSelf && target) {
                if ([target.userId length] || [target.nickname length]) {
                    [strongSelf.atTargets addObject:target];
                    NSString *insertStr = [NSString stringWithFormat:@"%@ ", target.nickname ? target.nickname : target.userId];
                    EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                    NSMutableString *originStr = [toolbar.inputTextView.text mutableCopy];
                    NSUInteger insertLocation = location > originStr.length ? originStr.length : location;
                    [originStr insertString:insertStr atIndex:insertLocation];
                    toolbar.inputTextView.text = originStr;
                    toolbar.inputTextView.selectedRange = NSMakeRange(insertLocation + insertStr.length, 0);
                    [toolbar.inputTextView becomeFirstResponder];
                }
            }
            else if (strongSelf) {
                EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                [toolbar.inputTextView becomeFirstResponder];
            }
        }];
        EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
        [toolbar.inputTextView resignFirstResponder];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location
{
    EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
    if ([toolbar.inputTextView.text length] == location + 1) {
        //delete last character
        NSString *inputText = toolbar.inputTextView.text;
        NSRange range = [inputText rangeOfString:@"@" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            if (location - range.location > 1) {
                NSString *sub = [inputText substringWithRange:NSMakeRange(range.location + 1, location - range.location - 1)];
                for (EaseAtTarget *target in self.atTargets) {
                    if ([sub isEqualToString:target.userId] || [sub isEqualToString:target.nickname]) {
                        inputText = range.location > 0 ? [inputText substringToIndex:range.location] : @"";
                        toolbar.inputTextView.text = inputText;
                        toolbar.inputTextView.selectedRange = NSMakeRange(inputText.length, 0);
                        [self.atTargets removeObject:target];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if ([ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT]) {
        EaseEmotion *emotion = [ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(emotionExtFormessageViewController:easeEmotion:)]) {
            NSDictionary *ext = [self.dataSource emotionExtFormessageViewController:self easeEmotion:emotion];
            [self sendTextMessage:emotion.emotionTitle withExt:ext];
        } else {
            [self sendTextMessage:emotion.emotionTitle withExt:@{MESSAGE_ATTR_EXPRESSION_ID:emotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)}];
        }
        return;
    }
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}

- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    __weak typeof(self) weakSelf = self;
    [self _canRecordCompletion:^(EMRecordResponse recordResponse) {
        switch (recordResponse) {
            case EMRequestRecord:
                
                break;
            case EMCanRecord:
            {
                if ([weakSelf.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
                    [weakSelf.delegate messageViewController:weakSelf
                                         didSelectRecordView:recordView
                                                withEvenType:EaseRecordViewTypeTouchDown];
                } else {
                    if ([weakSelf.recordView isKindOfClass:[EaseRecordView class]]) {
                        [(EaseRecordView *)weakSelf.recordView recordButtonTouchDown];
                    }
                }
                _isRecording = YES;
                EaseRecordView *tmpView = (EaseRecordView *)recordView;
                [weakSelf.view addSubview:tmpView];
                [tmpView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakSelf.navigationController.view);
                    make.centerX.equalTo(weakSelf.view);
                    make.height.width.mas_equalTo(200);
                }];
                [weakSelf.view bringSubviewToFront:recordView];
                int x = arc4random() % 100000;
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
                
                [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
                 {
                     if (error) {
                         _isRecording = NO;
                     }
                 }];
                
            }
                break;
            case EMCanNotRecord:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"record.failToPermission", @"No recording permission") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
                break;
            default:
                break;
        }
    }];
}


- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    if(_isRecording) {
        [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpOutside];
        } else {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
        
        _isRecording = NO;
    }
}

- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    if (_isRecording) {
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpInside];
        } else {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            [self.recordView removeFromSuperview];
        }
        __weak typeof(self) weakSelf = self;
        [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            if (!error) {
                [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
            }
            else {
                [weakSelf showHudInView:self.view hint:error.domain];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf hideHud];
                });
            }
        }];
        _isRecording = NO;
    }
}

- (void)didDragInsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragInside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragInside];
        }
    }
}

- (void)didDragOutsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragOutside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragOutside];
        }
    }
}

#pragma mark - EaseChatBarMoreViewDelegate

- (void)moreView:(EaseChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectMoreView:AtIndex:)]) {
        [self.delegate messageViewController:self didSelectMoreView:moreView AtIndex:index];
        return;
    }
}

- (void)moreViewPhotoAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    // Pop image picker
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewTakePicAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"模拟器不支持拍照"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    self.imagePicker.videoMaximumDuration = 10;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
}

- (void)moreViewLocationAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    EaseLocationViewController *locationController = [[EaseLocationViewController alloc] init];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MAKE1V1CALL object:@{@"chatter":self.conversation.conversationId, @"type":@(EMCallTypeVoice)}];
}

- (void)moreViewVideoCallAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_MAKE1V1CALL object:@{@"chatter":self.conversation.conversationId, @"type":@(EMCallTypeVideo)}];
}

#pragma mark - EMLocationViewDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - Hyphenate

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self addMessageToDataSource:message progress:nil];
            
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
    }
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if (self.conversation.type == EMConversationTypeGroupChat) {
            if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
                EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
                if ([body.action isEqualToString:@"TypingBegin"]) {
                    self.title = @"对方正在输入";
                    continue;
                } else if ([body.action isEqualToString:@"TypingEnd"]) {
                    self.title = self.conversation.conversationId;
                    continue;
                }
            }
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __block id<IMessageModel> model = nil;
            __block BOOL isHave = NO;
            [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if ([obj conformsToProtocol:@protocol(IMessageModel)])
                 {
                     model = (id<IMessageModel>)obj;
                     if ([model.messageId isEqualToString:message.messageId])
                     {
                         model.message.isReadAcked = YES;
                         isHave = YES;
                         *stop = YES;
                     }
                 }
             }];
            
            if(!isHave){
                return;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
                [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
            }
            else{
                [self.tableView reloadData];
            }
        });
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError;
{
    if (aMessage.body) {
        [self _updateMessageStatus:aMessage];
    }
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error{
    if (!error) {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVideo){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVoice){
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView reloadData];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    NSMutableArray *mutaMessages = [NSMutableArray array];
    for (EMMessage* msg in messages) {
        if (msg.body.type != EMMessageBodyTypeCmd) {
            [mutaMessages addObject:msg];
        }
        if (msg.ext) {
            if ([[msg.ext objectForKey:@"isFired"] intValue] == 3) {
                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:msg.ext];
                [dic setValue:@(4) forKey:@"isFired"];
                msg.ext =[dic copy];
                [[EMClient sharedClient].chatManager updateMessage:msg completion:nil];
            }
            if ([[msg.ext objectForKey:@"isFired"] intValue] == 1 && msg.status == EMMessageStatusSucceed) {
                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:msg.ext];
                [dic setValue:@(3) forKey:@"isFired"];
                msg.ext =[dic copy];
                [[EMClient sharedClient].chatManager updateMessage:msg completion:nil];
            }
        }
    }
    
    for (EMMessage *message in mutaMessages) {
        //Calculate time interval
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:stringForDate:)]) {
                timeStr = [_dataSource messageViewController:self stringForDate:messageDate];
            }
            else{
                timeStr = [messageDate formattedTime];
            }
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //Construct message model
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:message];
            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
            model.failImageName = @"imageDownloadFail";
        }
        if (model) {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    
    __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if (weakSelf) {
            [weakSelf.messsagesSource addObject:message];
            NSArray *messages = [weakSelf formatMessages:@[message]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    [weakSelf.dataArray addObjectsFromArray:messages];
                    [weakSelf.tableView reloadData];
                    if (message.direction != EMMessageDirectionReceive || _isBottom == YES) {
                        [weakSelf _scrollViewToBottom:YES];
                    }
                }
            });
        }
    });
}

#pragma mark - public
- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0) {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:NO];
}

#pragma mark - send message

- (void)_refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime) {
        __block __weak typeof(self) weakSelf = self;
        dispatch_async(self.messageQueue, ^{
            NSString *msgId = aMessage.messageId;
            EMMessage *last = weakSelf.messsagesSource.lastObject;
            if ([last isKindOfClass:[EMMessage class]]) {
                
                __block NSUInteger index = NSNotFound;
                index = NSNotFound;
                [weakSelf.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId]) {
                        index = idx;
                        *stop = YES;
                    }
                }];
                if (index != NSNotFound) {
                    [weakSelf.messsagesSource removeObjectAtIndex:index];
                    [weakSelf.messsagesSource addObject:aMessage];
                    
                    //格式化消息
                    weakSelf.messageTimeIntervalTag = -1;
                    NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.dataArray removeAllObjects];
                        [weakSelf.dataArray addObjectsFromArray:formattedMessages];
                        [weakSelf.tableView reloadData];
                        [weakSelf _scrollViewToBottom:NO];
                    });
                }
            }
        });
    }else{
        [self.tableView reloadData];
    }
}

- (void)sendMessage:(EMMessage *)message isNeedUploadFile:(BOOL)isUploadFile
{
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom){
        message.chatType = EMChatTypeChatRoom;
    }
    
    __weak typeof(self) weakself = self;
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && isUploadFile) {
        [EMClient sharedClient].options.isAutoTransferMessageAttachments = YES;
    } else {
        [self addMessageToDataSource:message progress:nil];
//        if (message.body.type == EMMessageBodyTypeVideo) {
//            [weakself uploadAndSendVedioMessage:message];
//            return;
//        }
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
                [weakself.dataSource messageViewController:weakself updateProgress:progress messageModel:nil messageBody:message.body];
            }
        } completion:^(EMMessage *aMessage, EMError *aError) {
            if (!aError) {
                if (aMessage.ext) {
                    if ([[aMessage.ext objectForKey:@"isFired"] intValue] == 1) {
                        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:aMessage.ext];
                        [dic setValue:@(3) forKey:@"isFired"];
                        aMessage.ext =[dic copy];
                        message.ext = [dic copy];
                        [weakself _updateMessageStatus:message];
                        [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
                        [weakself _updateMessageStatus:aMessage];
                    }
                }
            }
            [weakself.tableView reloadData];
        }];
    }
}

- (void) uploadAndSendVedioMessage:(EMMessage*)message {
    __block __weak typeof(self) weakself = self;
    EMError* err;
    message.status = EMMessageStatusDelivering;
    [weakself _updateMessageStatus:message];
    EMVideoMessageBody* body = (EMVideoMessageBody*)message.body;
    if (!body.localPath) {
        message.status = EMMessageStatusFailed;
        [weakself _updateMessageStatus:message];
        return;
    }
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    put.bucketName = @"hgjt-oss";
    put.objectKey = [NSString stringWithFormat:@"im19060501/%@",[body.localPath lastPathComponent]];
    
    put.uploadingFileURL = [NSURL fileURLWithPath:body.localPath]; // 直接上传NSData
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
            [weakself.dataSource messageViewController:weakself updateProgress:totalByteSent/totalBytesExpectedToSend messageModel:nil messageBody:message.body];
        }
    };
    
    OSSTask * putTask = [app.ossClient putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            if (message.status == EMMessageStatusFailed) {
                return nil;
            }
            body.remotePath = [NSString stringWithFormat:@"http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/%@",put.objectKey];
            put.objectKey = [NSString stringWithFormat:@"im19060501/%@",[body.thumbnailLocalPath lastPathComponent]];
            
            put.uploadingFileURL = [NSURL fileURLWithPath:body.thumbnailLocalPath]; // 直接上传NSData
            OSSTask * putTask1 = [app.ossClient putObject:put];
            [putTask1 continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
                if (!task.error) {
                    body.thumbnailRemotePath = [NSString stringWithFormat:@"http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/%@",put.objectKey];
                    message.body = body;
                    [EMClient sharedClient].options.isAutoTransferMessageAttachments = NO;
                    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                        if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
                            [weakself.dataSource messageViewController:weakself updateProgress:progress messageModel:nil messageBody:message.body];
                        }
                    } completion:^(EMMessage *aMessage, EMError *aError) {
                        [weakself.tableView reloadData];
                    }];
                } else {
                    message.status = EMMessageStatusFailed;
                    EMError* err;
                    [weakself.conversation updateMessageChange:message error:&err];
                    [weakself _updateMessageStatus:message];
                }
                return nil;
            }];
        } else {
            message.status = EMMessageStatusFailed;
            EMError* err;
            [weakself.conversation updateMessageChange:message error:&err];
            [weakself _updateMessageStatus:message];
        }
        return nil;
    }];
}

- (void)sendTextMessage:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        return;
    }
    NSDictionary *ext = nil;
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSArray *targets = [self _searchAtTargets:text];
        if ([targets count]) {
            __block BOOL atAll = NO;
            [targets enumerateObjectsUsingBlock:^(NSString *target, NSUInteger idx, BOOL *stop) {
                if ([target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    atAll = YES;
                    *stop = YES;
                }
            }];
            if (atAll) {
                ext = @{kGroupMessageAtList: kGroupMessageAtAll};
            }
            else {
                ext = @{kGroupMessageAtList: targets};
            }
        }
    }
    [self sendTextMessage:text withExt:ext];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper getTextMessage:text to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:ext];
    [self sendMessage:message isNeedUploadFile:NO];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper getLocationMessageWithLatitude:latitude longitude:longitude address:address to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:NO];
}

- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getImageMessageWithImageData:imageData to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getImageMessageWithImage:image to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVoice];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getVoiceMessageWithLocalPath:localPath duration:duration to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVideo];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getVideoMessageWithURL:url to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self sendMessage:message isNeedUploadFile:NO];
}

- (void)sendFileMessageWith:(EMMessage *)message {
    [self sendMessage:message isNeedUploadFile:YES];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
    self.messageTimeIntervalTag = -1;
    __block __weak typeof(self) weakSelf = self;
    dispatch_async(self.messageQueue, ^{
        NSMutableArray* arr = [[weakSelf formatMessages:weakSelf.messsagesSource] mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataArray=arr;
            [weakSelf.tableView reloadData];
        });
        if (weakSelf.isViewDidAppear)
        {
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (EMMessage *message in weakSelf.messsagesSource)
            {
                if ([weakSelf shouldSendHasReadAckForMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [weakSelf _sendHasReadResponseForMessages:unreadMessages isRead:YES];
            }
            
            [weakSelf.conversation markAllMessagesAsRead:nil];
            if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(messageViewControllerMarkAllMessagesAsRead:)]) {
                [weakSelf.dataSource messageViewControllerMarkAllMessagesAsRead:self];
            }
        }
    });
}

- (void)hideImagePicker
{
    if (_imagePicker && [EaseSDKHelper shareHelper].isShowingimagePicker) {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - private
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message
{
    if ([self.conversation.conversationId isEqualToString:message.conversationId])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < self.dataArray.count; i ++) {
                id object = [self.dataArray objectAtIndex:i];
                if ([object isKindOfClass:[EaseMessageModel class]]) {
                    id<IMessageModel> model = object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        id<IMessageModel> model = nil;
                        if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                            model = [self.dataSource messageViewController:self modelForMessage:message];
                        }
                        else{
                            model = [[EaseMessageModel alloc] initWithMessage:message];
                            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
                            model.failImageName = @"imageDownloadFail";
                        }
                        [self.dataArray replaceObjectAtIndex:i withObject:model];
                        [self.tableView reloadData];
                        break;
                    }
                }
            }
        });
    }
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    __block __weak typeof(self) weakSelf = self;
    dispatch_async(self.messageQueue, ^{
        BOOL isChatting = [aMessage.conversationId isEqualToString:weakSelf.conversation.conversationId];
        if (aMessage && isChatting) {
            [[EMClient sharedClient].chatManager updateMessage:aMessage completion:nil];
            id<IMessageModel> model = nil;
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                model = [_dataSource messageViewController:self modelForMessage:aMessage];
            }
            else{
                model = [[EaseMessageModel alloc] initWithMessage:aMessage];
                model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
                model.failImageName = @"imageDownloadFail";
            }
            if (model) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __block NSUInteger index = NSNotFound;
                    [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                        if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                            if ([aMessage.messageId isEqualToString:model.message.messageId])
                            {
                                index = idx;
                                *stop = YES;
                            }
                        }
                    }];
                    
                    if (index != NSNotFound)
                    {
                        [self.dataArray replaceObjectAtIndex:index withObject:model];
                        [self.tableView reloadData];
                    }
                });
            }
        }
    });
}

- (NSArray*)_searchAtTargets:(NSString*)text
{
    NSMutableArray *targets = nil;
    if (text.length > 1) {
        targets = [NSMutableArray array];
        NSArray *splits = [text componentsSeparatedByString:@"@"];
        if ([splits count]) {
            for (NSString *split in splits) {
                if (split.length) {
                    NSString *atALl = @"[有全体消息]";
                    if (split.length >= atALl.length && [split compare:atALl options:NSCaseInsensitiveSearch range:NSMakeRange(0, atALl.length)] == NSOrderedSame) {
                        [targets removeAllObjects];
                        [targets addObject:kGroupMessageAtAll];
                        return targets;
                    }
                    for (EaseAtTarget *target in self.atTargets) {
                        if ([target.userId length]) {
                            if ([split hasPrefix:target.userId] || (target.nickname && [split hasPrefix:target.nickname])) {
                                [targets addObject:target.userId];
                                [self.atTargets removeObject:target];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return targets;
}


@end
