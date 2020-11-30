//
//  EM1v1CallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EM1v1CallViewController.h"
#import "UIViewController+oc.h"
#import "Chaangliao-Swift.h"
#import "Public.h"
#import <SDAutoLayout/SDAutoLayout.h>

#import "callPhoneUserModel.h"

@interface EM1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;
@property (nonatomic,strong)callPhoneUserModel * model;
@end

@implementation EM1v1CallViewController

#if DEMO_CALL == 1

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
{
    self = [super init];
    if (self) {
        _callSession = aCallSession;
        _callStatus = EMCallSessionStatusDisconnected;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.model=[BoXinUtil getCallModelWithId:self.callSession.remoteName];

    [self _setup1v1CallControllerSubviews];
    self.timeLabel.hidden = YES;
    self.answerButton.enabled = NO;
    self.callStatus = self.callSession.status;
    [self.waitImgView startAnimating];
    
    //监测耳机状态，如果是插入耳机状态，不显示扬声器按钮
    self.speakerButton.hidden = isHeadphone();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChanged:)   name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self clearDataAndView];
}

- (void)clearDataAndView
{
    [self _stopCallDurationTimer];
    
    [_floatingView removeFromSuperview];
    _floatingView = nil;
}

#pragma mark - Subviews

- (void)_setup1v1CallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backImg=[[UIImageView alloc]init];
    
    
    [self.view addSubview:self.backImg];
    [self.backImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.backImg layoutIfNeeded];
    [self.backImg sd_setImageWithURL:[NSURL URLWithString:self.model.user_Pic] placeholderImage:[UIImage imageNamed:@"moren"]];
    self.backImg.contentMode=UIViewContentModeScaleAspectFill;
    self.backImg.clipsToBounds=YES;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualView1 = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualView1.frame = CGRectMake(0, 0, self.backImg.width, self.backImg.height);
    visualView1.alpha = 0.3;
    [self.backImg addSubview:visualView1];
    
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(kSCRATIO(-195)-BOTTOM_HEIGHT);
        make.left.right.mas_offset(0);
    }];
//    self.statusLabel.text = @"正在建立连接..."
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:kSCRATIO(18)];
    self.timeLabel.textColor = UIColor.whiteColor;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.timeLabel];
   

    self.remoteNameLabel.text = [BoXinUtil getNikeNameWithId:self.callSession.remoteName];

    
    UIImageView  * bigCirleView=[[UIImageView  alloc]init];
    [self.backImg addSubview:bigCirleView];
    [bigCirleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kSCRATIO(113-20)+kStatusBarHeight);
        make.centerX.mas_equalTo(self.backImg.mas_centerX);
        make.width.mas_equalTo(kSCRATIO(183));
        make.height.mas_equalTo(kSCRATIO(183));
    }];
    bigCirleView.image=[UIImage imageNamed:@"callBackImg"];
    
    
    self.remoteUserPic=[[UIImageView alloc]init];
    [bigCirleView addSubview:self.remoteUserPic];
    [self.remoteUserPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bigCirleView.mas_centerY);
        make.centerX.mas_equalTo(bigCirleView.mas_centerX);
        make.height.mas_equalTo(kSCRATIO(91));
        make.width.mas_equalTo(kSCRATIO(97));

    }];
    [self.remoteUserPic layoutIfNeeded];
    ViewRadius(self.remoteUserPic, self.remoteUserPic.height/2);
    [self.remoteUserPic sd_setImageWithURL:[NSURL URLWithString:self.model.user_Pic] placeholderImage:[UIImage imageNamed:@"moren"]];
    self.remoteUserPic.contentMode=UIViewContentModeScaleAspectFill;
    self.remoteUserPic.clipsToBounds=YES;
    //接听者名字
    self.remoteNameLabel = [[QQMIaoBianLab alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:kSCRATIO(21)];
    self.remoteNameLabel.textAlignment=NSTextAlignmentCenter;
    [self.backImg addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bigCirleView.mas_bottom).offset(kSCRATIO(0));
        make.left.right.mas_offset(0);
    }];
    self.remoteNameLabel.text = [BoXinUtil getNikeNameWithId:self.callSession.remoteName];

    if (self.callType==EMCallTypeVideo) {
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(kSCRATIO(40));
            make.width.mas_offset(kSCRATIO(64));
            make.bottom.mas_offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.height.mas_offset(kSCRATIO(92));
            
        }];
    }
    
  
//    self.waitImgView = [[UIImageView alloc] init];
//    self.waitImgView.contentMode = UIViewContentModeScaleAspectFit;
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (int i = 25; i < 88; i++) {
//        NSString *name = [[NSString alloc] initWithFormat:@"animate_000%@", @(i)];
//        [array addObject:[UIImage imageNamed:name]];
//    }
//    [self.waitImgView setAnimationImages:array];
//    [self.view addSubview:self.waitImgView];
//    [self.waitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(20);
//        make.right.equalTo(self.view).offset(-20);
//    }];
//
//    [self.minButton setImage:[UIImage imageNamed:@"minimize_gray"] forState:UIControlStateNormal];
//    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-30);
//        make.right.equalTo(self.view).offset(-25);
//        make.width.height.equalTo(@40);
//    }];
    
   
        
        self.answerButton = [[EMButton alloc] initWithTitle:@"接听" target:self action:@selector(answerAction)];
        [self.answerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self.answerButton setImage:[UIImage imageNamed:@"answe"] forState:UIControlStateNormal];
        [self.view addSubview:self.answerButton];
    
}

#pragma mark - Floating View

- (EMStreamView *)floatingView
{
    if (_floatingView == nil) {
        _floatingView = [[EMStreamView alloc] initWithFrame:CGRectMake(WIDTH-KSCHEIGHT(110), KSCHEIGHT(40-20)+kStatusBarHeight, KSCHEIGHT(100), HEIGHT/WIDTH*KSCHEIGHT(80))];
        _floatingView.enableVideo = self.callSession.type == EMCallTypeVideo ? YES : NO;
        _floatingView.delegate = self;
    }
    
    return _floatingView;
}

- (void)_updateFloatingViewWithCallStatus:(EMCallSessionStatus)callStatus
{
    if (!_floatingView) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
            _floatingView.status = StreamStatusConnecting;
        }
            break;
        case EMCallSessionStatusConnected:
        case EMCallSessionStatusAccepted:
        {
            _floatingView.status = StreamStatusConnected;
        }
            break;
            
        default:
            _floatingView.status = StreamStatusNormal;
            break;
    }
}

- (void)_updateFloatingViewWithStreamingStatus:(EMCallStreamingStatus)aStatus
{
    if (!_floatingView) {
        return;
    }
    
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            _floatingView.enableVoice = NO;
            break;
        case EMCallStreamStatusVoiceResume:
            _floatingView.enableVoice = YES;
            break;
        case EMCallStreamStatusVideoPause:
            _floatingView.enableVideo = NO;
            break;
        case EMCallStreamStatusVideoResume:
            _floatingView.enableVideo = YES;
            break;
            
        default:
            break;
    }
}

#pragma mark - Timer

- (void)_updateCallDuration
{
    
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    self.statusLabel.hidden=YES;
   
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, m, s];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%02d", s];
        
    }
}

- (void)_startCallDurationTimer
{
    [self _stopCallDurationTimer];
    
    self.callDuration = 0;
    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateCallDuration) userInfo:nil repeats:YES];
}

- (void)_stopCallDurationTimer
{
    if (self.callDurationTimer) {
        [self.callDurationTimer invalidate];
        self.callDurationTimer = nil;
    }
}

#pragma mark - NSNotification

- (void)handleAudioRouteChanged:(NSNotification *)aNotif
{
    NSDictionary *interuptionDict = aNotif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //插入耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = YES;
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //拔出耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = NO;
                if (self.speakerButton.isSelected) {
                    [self speakerButtonAction];
                }
            });
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    
    self.minButton.selected = NO;
    [self.floatingView removeFromSuperview];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[UIViewController getCurrentVC] presentViewController:self animated:NO completion:nil];
}

#pragma mark - Status

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    if (_callStatus >= callStatus) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
//            self.statusLabel.text = NSLocalizedString(@"Cancel", @"Cancel");
        }
            break;
        case EMCallSessionStatusConnected:
        {
//            self.statusLabel.text = NSLocalizedString(@"Cancel", @"Cancel");
            self.answerButton.enabled = YES;
        }
            break;
        case EMCallSessionStatusAccepted:
        {
            
            [self _startCallDurationTimer];
            
//            self.statusLabel.text = @"已接通";
            if (self.callType==EMCallTypeVideo) {
                 [self.backImg removeFromSuperview];
            }
            
            self.timeLabel.hidden=NO;
            
            [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_offset(kSCRATIO(-145)-BOTTOM_HEIGHT);
                make.left.right.mas_offset(0);
            }];
            
//            [UIView animateWithDuration:1.0 delay:timeIntervalSinceNow options:UIViewAnimationOptionTransitionCurlDown animations:^{
//                self.statusLabel.alpha=0;
//
//            } completion:^(BOOL finished) {
//
//            }];
            
//            [self.waitImgView stopAnimating];
//            if (!self.callSession.isCaller) {
//                [self.answerButton removeFromSuperview];
//                [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.centerX.equalTo(self.view);
//                    make.bottom.equalTo(self.view).offset(kSCRATIO(-53)-BOTTOM_HEIGHT);
//                    make.width.height.mas_equalTo(kSCRATIO(64));
//                }];
//            }
//            self.remoteNameLabel.text = [BoXinUtil getNikeNameWithId:self.callSession.remoteName];

            if (self.microphoneButton.isSelected) {
                [self.callSession pauseVoice];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.microphoneButton.isSelected && self.speakerButton.isSelected) {
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    [audioSession setActive:YES error:nil];
                }
            });
        }
            break;
            
        default:
            break;
    }
    
    [self _updateFloatingViewWithCallStatus:callStatus];
}

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus
{
    NSString *str = @"对方数据流状态有更新";
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            str = @"对方已静音";
            break;
        case EMCallStreamStatusVoiceResume:
            str = @"对方解除静音";
            break;
        case EMCallStreamStatusVideoPause:
            str = @"对方禁止上传视频";
            break;
        case EMCallStreamStatusVideoResume:
            str = @"对方恢复上传视频";
            break;
            
        default:
            break;
    }
    
    [self showHint:str];
    
    [self _updateFloatingViewWithStreamingStatus:aStatus];
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.selected;
    if (self.microphoneButton.isSelected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (void)speakerButtonAction
{
    [super speakerButtonAction];
}

- (void)minimizeAction
{
}

- (void)hangupAction
{
    [self clearDataAndView];
    
    NSString *callId = self.callSession.callId;
    _callSession = nil;
    
    EMCallEndReason reason = EMCallEndReasonHangup;
    if (self.callDuration < 1 && !self.callSession.isCaller) {
        reason = EMCallEndReasonDecline;
    }
    [[DemoCallManager sharedManager] endCallWithId:callId reason:reason];
}

- (void)answerAction
{
    
   
    if (self.callType==EMCallTypeVoice) {
        [self.view addSubview:self.microphoneButton];
        [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kSCRATIO(40));
            make.bottom.mas_offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.width.mas_offset(kSCRATIO(64));
            make.height.mas_equalTo(kSCRATIO(92));
        }];
        [self.answerButton removeFromSuperview];
        [self.view addSubview:self.speakerButton];
        [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-kSCRATIO(40));
            make.bottom.equalTo(self.microphoneButton);
            make.width.mas_offset(kSCRATIO(64));
            make.height.mas_equalTo(kSCRATIO(92));
            
        }];

        
        [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.microphoneButton);
            make.height.mas_equalTo(kSCRATIO(92));
            make.width.mas_equalTo(kSCRATIO(64));
            
        }];
        [self.hangupButton layoutIfNeeded];
        
        
    }else{
        
        [self.answerButton setHidden:YES];
        
        [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kSCRATIO(40));
            make.bottom.mas_offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.height.mas_equalTo(kSCRATIO(92));
            make.width.mas_equalTo(kSCRATIO(64));
            
        }];
        [self.backImg removeFromSuperview];
        
    }
   
    [[DemoCallManager sharedManager] answerCall:self.callSession.callId];
    self.callStatus = EMCallSessionStatusAccepted;
}

#endif

@end
