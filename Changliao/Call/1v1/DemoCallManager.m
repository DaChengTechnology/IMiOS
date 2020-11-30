//
//  DemoCallManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoCallManager.h"



#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "EaseSDKHelper.h"

#import "Call1v1AudioViewController.h"
#import "Call1v1VideoViewController.h"
#import "UIViewController+oc.h"



#import <UserNotifications/UserNotifications.h>
#import "Chaangliao-Swift.h"

static DemoCallManager *callManager = nil;

@interface DemoCallManager()<EMChatManagerDelegate, EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;
@property (strong, nonatomic) EMCallSession *currentCall;
@property (nonatomic, strong) EM1v1CallViewController *currentController;

@property (strong, nonatomic) NSTimer *timeoutTimer;

@property (nonatomic, strong) CTCallCenter *callCenter;

@property (strong, nonatomic) AVAudioPlayer *ringPlayer;
@property (nonatomic) int callTime;
@property (strong,nonatomic) NSTimer* callTimer;
@property (nonatomic) NSInteger huangUp;

@end



@implementation DemoCallManager

@synthesize gIsCalling = _gIsCalling;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[DemoCallManager alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
    self.callCenter = nil;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_MAKE1V1CALL object:nil];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentCall = nil;
    _currentController = nil;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];

    //录制相关功能初始化
    
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = NO;
        options.videoResolution = EMCallVideoResolution640_480;
        options.isFixedVideoResolution = YES;
    }
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1v1Call:) name:KNOTIFICATION_MAKE1V1CALL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endCall) name:@"EndCall" object:nil];
    
    
//    __weak typeof(self) weakSelf = self;
//    self.callCenter = [[CTCallCenter alloc] init];
//    self.callCenter.callEventHandler = ^(CTCall* call) {
////        if(call.callState == CTCallStateConnected) {
////            [weakSelf hangupCallWithReason:EMCallEndReasonBusy];
////        }
//
//        if(call.callState == CTCallStateConnected) {
//            [weakSelf.currentController muteCall];
//        } else if(call.callState == CTCallStateDisconnected) {
//            [weakSelf.currentController resumeCall];
//        }
//    };
}

#pragma mark - Call Timeout Before Answered

- (void)_timeoutBeforeCallAnswered
{
    [self _stopRing];
    [self endCallWithId:self.currentCall.callId reason:EMCallEndReasonNoResponse];
}

- (void)_startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

- (void)_stopCallTimeoutTimer
{
    
    if (self.timeoutTimer == nil) {
        return;
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    
}

-(void)endCall{
    if (self.currentCall) {
        [self endCallWithId:self.currentCall.callId reason:EMCallEndReasonHangup];
    }
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession
{
    if (!aSession || [aSession.callId length] == 0) {
        return ;
    }
    
    if ([EaseSDKHelper shareHelper].isShowingimagePicker) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideImagePicker" object:nil];
    }
    
    if(_gIsCalling || (self.currentCall && self.currentCall.status != EMCallSessionStatusDisconnected)){
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    _gIsCalling = YES;
    @synchronized (_callLock) {
        [self _startCallTimeoutTimer];
        
        self.currentCall = aSession;
        if (aSession.type == EMCallTypeVoice) {
            self.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:self.currentCall];
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                UILocalNotification *notification = [[UILocalNotification alloc]init];
                notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.repeatInterval = NSCalendarUnitTimeZone;
                notification.alertTitle = @"畅聊";
                notification.alertBody = [NSString stringWithFormat:@"%@邀请你语音聊天",[BoXinUtil getNikeNameWithId:aSession.remoteName]];
                notification.applicationIconBadgeNumber = 1;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        } else {
            self.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:self.currentCall];
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                UILocalNotification *notification = [[UILocalNotification alloc]init];
                notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.repeatInterval = NSCalendarUnitTimeZone;
                notification.alertTitle = @"畅聊";
                notification.alertBody = [NSString stringWithFormat:@"%@邀请你视频聊天",[BoXinUtil getNikeNameWithId:aSession.remoteName]];
                notification.applicationIconBadgeNumber = 1;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
        __block __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf.currentController) {
                return;
            }
            if ([UIViewController getCurrentVC]) {
                FriendData* f = [BoXinUtil getFriendDataWithId:aSession.remoteName];
                if (f) {
                    if (f.is_shield != 1) {
                        [weakSelf _beginRing];
                    }
                }else{
                    [weakSelf _beginRing];
                }
                if ([[UIViewController getCurrentVC] isKindOfClass:[shakeVc class]]) {
                    [[UIViewController getCurrentVC] dismissViewControllerAnimated:NO completion:^{
                        weakSelf.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [[UIViewController getCurrentVC] presentViewController:weakSelf.currentController animated:NO completion:nil];
                    }];
                }else
                if ([[UIViewController getCurrentVC] isKindOfClass:[ShakeViewController class]]) {
                    [[UIViewController getCurrentVC] dismissViewControllerAnimated:NO completion:^{
                        weakSelf.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [[UIViewController getCurrentVC] presentViewController:weakSelf.currentController animated:NO completion:nil];
                    }];
                }else{
                    weakSelf.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [[UIViewController getCurrentVC] presentViewController:weakSelf.currentController animated:NO completion:nil];
                }
                
            }
        });
    }
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        self.currentController.callStatus = EMCallSessionStatusConnected;
    }
}

- (void) onCalling {
    self.callTime += 1;
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self _stopCallTimeoutTimer];
        self.currentController.callStatus = EMCallSessionStatusAccepted;
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onCalling) userInfo:nil repeats:YES];
    }
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    
    
    if (self.callTimer.isValid) {
        [self.callTimer invalidate];
        self.callTimer = nil;
    }
    BOOL isInsertMSG = false;
    if (EMCallEndReasonHangup == aReason) {
        NSString* text;
        NSDictionary* dic;
        if (aSession.type == EMCallTypeVoice) {
            text = [NSString stringWithUTF8String:"[:voice]"];
            dic = @{@"callType":@"1"};
        }else{
            text = [NSString stringWithUTF8String:"[:vedio]"];
            dic = @{@"callType":@"2"};
        }
        NSString* calltext;
        if (self.callTime != 0) {
            calltext = [NSString stringWithFormat:@"通话时间%@",[self _updateCallDuration]];
        }else{
            calltext = @"已挂断";
        }
        self.callTime = 0;
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ %@",text,calltext]];
        NSString *from = [[EMClient sharedClient] currentUsername];
        if (aSession.isCaller) {
            EMMessage *message = [[EMMessage alloc] initWithConversationID:aSession.remoteName from:from to:aSession.remoteName body:body ext:dic];
            message.chatType = EMChatTypeChat;
            message.localTime = [[NSDate new] timeIntervalSince1970] * 1000;
            message.timestamp = [[NSDate new] timeIntervalSince1970] * 1000;
            message.direction = EMMessageDirectionSend;
            message.status = EMMessageStatusSucceed;
            EMConversation* conversation = [[[EMClient sharedClient] chatManager] getConversation:aSession.remoteName type:EMConversationTypeChat createIfNotExist:true];
            EMError * err;
            [conversation insertMessage:message error:&err];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCall" object:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMessage" object:nil];
        }else{
            EMMessage *message = [[EMMessage alloc] initWithConversationID:aSession.remoteName from:aSession.remoteName to:from body:body ext:dic];
            message.chatType = EMChatTypeChat;
            message.localTime = [[NSDate new] timeIntervalSince1970] * 1000;
            message.timestamp = [[NSDate new] timeIntervalSince1970] * 1000;
            message.direction = EMMessageDirectionReceive;
            message.status = EMMessageStatusSucceed;
            EMConversation* conversation = [[[EMClient sharedClient] chatManager] getConversation:aSession.remoteName type:EMConversationTypeChat createIfNotExist:true];
            EMError * err;
            [conversation insertMessage:message error:&err];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCall" object:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMessage" object:nil];
        }
        isInsertMSG = true;
    }
    
    if (![aSession.callId isEqualToString:self.currentCall.callId]) {
        return;
    }
    [self _stopRing];
    [self _endCallWithId:aSession.callId isNeedHangup:NO reason:aReason];
    if (aReason != EMCallEndReasonHangup) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            if (isInsertMSG) {
                return;
            }
            NSString *reasonStr = @"通话结束";
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                    reasonStr = @"对方无响应";
                    
                    break;
                case EMCallEndReasonDecline:
                    if (aSession.isCaller) {
                        reasonStr = @"对方已拒绝";
                    }else{
                        reasonStr = @"已挂断";
                    }
                    break;
                case EMCallEndReasonBusy:
                    reasonStr = @"对方通话中";
                    break;
                case EMCallEndReasonFailed:
                    reasonStr = @"连接失败";
                    break;
                case EMCallEndReasonRemoteOffline:
                    reasonStr = @"对方不在线";
                    break;
                
                default:
                    break;
            }
            NSString* text;
            NSDictionary* dic;
            if (aSession.type == EMCallTypeVoice) {
                text = [NSString stringWithUTF8String:"[:voice]"];
                dic = @{@"callType":@"1"};
            }else{
                text = [NSString stringWithUTF8String:"[:vedio]"];
                dic = @{@"callType":@"2"};
            }
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ %@",text,reasonStr]];
            NSString *from = [[EMClient sharedClient] currentUsername];
            if (aSession.isCaller) {
                EMMessage *message = [[EMMessage alloc] initWithConversationID:aSession.remoteName from:from to:aSession.remoteName body:body ext:dic];
                message.chatType = EMChatTypeChat;
                EMConversation* conversation = [[[EMClient sharedClient] chatManager] getConversation:aSession.remoteName type:EMConversationTypeChat createIfNotExist:true];
                message.localTime = [[NSDate new] timeIntervalSince1970] * 1000;
                message.timestamp = [[NSDate new] timeIntervalSince1970] * 1000;
                message.status = EMMessageStatusSucceed;
                EMError * err;
                [conversation insertMessage:message error:&err];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCall" object:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMessage" object:nil];
            }else{
                EMMessage *message = [[EMMessage alloc] initWithConversationID:aSession.remoteName from:aSession.remoteName to:from body:body ext:dic];
                message.chatType = EMChatTypeChat;
                message.localTime = [[NSDate new] timeIntervalSince1970] * 1000;
                message.timestamp = [[NSDate new] timeIntervalSince1970] * 1000;
                message.direction = EMMessageDirectionReceive;
                message.status = EMMessageStatusSucceed;
                EMConversation* conversation = [[[EMClient sharedClient] chatManager] getConversation:aSession.remoteName type:EMConversationTypeChat createIfNotExist:true];
                EMError * err;
                [conversation insertMessage:message error:&err];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCall" object:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMessage" object:nil];
            }
        }
    }
}

- (NSString *)_updateCallDuration
{
    self.callTime  += 1;
    int hour = self.callTime / 3600;
    int m = (self.callTime - hour * 3600) / 60;
    int s = self.callTime - hour * 3600 - m * 60;
    
    if (hour > 0) {
        return [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        return [NSString stringWithFormat:@"%i:%02d", m, s];
    }
    else{
        return [NSString stringWithFormat:@"00:%02d", s];
    }
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self.currentController updateStreamingStatus:aStatus];
    }
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
//        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = [[EMClient sharedClient].callManager getCallOptions].offlineMessageText;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{@"em_apns_ext":@{@"em_push_title":text}}];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - NSNotification

- (void)handleMake1v1Call:(NSNotification*)notify
{
    if (!notify.object) {
        return;
    }
    
    if (_gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    EMCallType type = (EMCallType)[[notify.object objectForKey:@"type"] integerValue];
    if (type == EMCallTypeVideo) {
        [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.default", @"Default") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        }];
//        [alertController addAction:defaultAction];
//
//        UIAlertAction *customAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.custom", @"Custom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:YES];
//        }];
//        [alertController addAction:customAction];
//
//        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//        [self.mainController.navigationController presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
    }
}

- (void)_makeCallWithUsername:(NSString *)aUsername
                         type:(EMCallType)aType
            isCustomVideoData:(BOOL)aIsCustomVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        DemoCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            if (aError) {
                if (aError.code == EMErrorNetworkUnavailable) {
                    self->_gIsCalling = NO;
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NetworkConnectFeild", comment: @"Network connect feild") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
            }
            if (aError || aCallSession == nil) {
                self->_gIsCalling = NO;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"初始化失败" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
            
            @synchronized (self.callLock) {
                strongSelf.currentCall = aCallSession;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (aType == EMCallTypeVideo) {
                        strongSelf.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:strongSelf.currentCall];
                    } else {
                        strongSelf.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:strongSelf.currentCall];
                    }
                    
                    if (strongSelf.currentController) {
                        strongSelf.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [[UIViewController getCurrentVC] presentViewController:strongSelf.currentController animated:NO completion:nil];
                    }
                });
            }
            
            [weakSelf _startCallTimeoutTimer];
        }
        else {
            _gIsCalling = NO;
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    if (!((AppDelegate*)[UIApplication sharedApplication].delegate).isNetworkConnect) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NetworkConnectFeild", comment: @"Network connect feild") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", comment: @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    _gIsCalling = YES;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = aIsCustomVideo;
    
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername
                                            record:NO
                                       mergeStream:NO
                                               ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
                                                   completionBlock(aCallSession, aError);
                                               }];
}

#pragma mark - public

- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

- (void)answerCall:(NSString *)aCallId
{
    [self _stopRing];
    [self _stopCallTimeoutTimer];
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        return ;
    }
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onCalling) userInfo:nil repeats:YES];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:weakSelf.currentCall.callId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NetworkConnectFeild", @"Network connect feild") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", comment: @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{
                    [weakSelf endCallWithId:aCallId reason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

- (void)_endCallWithId:(NSString *)aCallId
          isNeedHangup:(BOOL)aIsNeedHangup
                reason:(EMCallEndReason)aReason
{
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        if (aIsNeedHangup) {
            EMError* err = [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
        }
        return ;
    }
    
    _gIsCalling = NO;
    [self _stopCallTimeoutTimer];
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = NO;
    
    if (aIsNeedHangup) {
        [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    @synchronized (_callLock) {
        self.currentCall = nil;
        
        //        self.currentController.isDismissing = YES;
        [self.currentController clearDataAndView];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [audioSession setMode:AVAudioSessionModeDefault error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason
{
    [self _stopRing];
    [self _endCallWithId:aCallId isNeedHangup:YES reason:aReason];
}

- (void)_beginRing
{
    [self.ringPlayer stop];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ring" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    AVAudioSession* aas = [AVAudioSession sharedInstance];
    [aas setMode:AVAudioSessionModeDefault error:nil];
    [aas setActive:YES error:nil];
    self.ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.ringPlayer setVolume:1];
    self.ringPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    if([self.ringPlayer prepareToPlay])
    {
        [self.ringPlayer play]; //播放
    }
}

- (void) setTime:(int)time {
    _callTime = time;
}

- (void)_stopRing
{
    if (self.ringPlayer.isPlaying) {
        [self.ringPlayer stop];
    }
}


@end
