//
//  Call1v1AudioViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1AudioViewController.h"

#import "EMButton.h"

#import "DemoCallManager.h"

#import "Public.h"
@interface Call1v1AudioViewController ()

@end

@implementation Call1v1AudioViewController

#if DEMO_CALL == 1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    self.callType=EMCallTypeVoice;
    //默认不开启扬声器
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    //判断是否是发起者 yes不是
    if (self.callSession.isCaller==YES) {
        [self.view addSubview:self.microphoneButton];
        [self.view addSubview:self.speakerButton];
        [self.view addSubview:self.hangupButton];
        [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kSCRATIO(40));
            make.bottom.mas_offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.width.mas_offset(kSCRATIO(64));
            make.height.mas_equalTo(kSCRATIO(92));
        }];
        //静音
        [self.speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-kSCRATIO(40));
            make.bottom.equalTo(self.microphoneButton);
            make.width.mas_offset(kSCRATIO(64));
            make.height.mas_equalTo(kSCRATIO(92));
            
        }];
        [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view).offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.height.mas_equalTo(kSCRATIO(92));
            make.width.mas_equalTo(kSCRATIO(64));
            
        }];
       
        
    }else{
        
       
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton);
            make.left.equalTo(self.view).offset(kSCRATIO(40));
            make.height.mas_equalTo(kSCRATIO(92));
            make.width.mas_equalTo(kSCRATIO(64));
        }];
        [self.view addSubview:self.hangupButton];
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(kSCRATIO(-40));
            make.bottom.equalTo(self.view).offset(kSCRATIO(-21)-BOTTOM_HEIGHT);
            make.height.mas_equalTo(kSCRATIO(92));
            make.width.mas_equalTo(kSCRATIO(64));
            
        }];
    }
  

   
    
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.microphoneButton.mas_top).offset(-40);
    }];
    
    self.floatingView.bgView.image = [UIImage imageNamed:@"floating_voice"];
    self.floatingView.bgView.layer.borderWidth = 0;
    self.floatingView.isLockedBgView = YES;
}

#pragma mark - Action

- (void)minimizeAction
{
    
    self.minButton.selected = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.top.equalTo(keyWindow.mas_top).offset(80);
        make.right.equalTo(keyWindow.mas_right).offset(-40);
    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#endif

@end
