//
//  EM1v1CallViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

#import "DemoCallManager.h"
#import "EMStreamView.h"
#import "QQMIaoBianLab.h"

@interface EM1v1CallViewController : EMCallViewController<EMStreamViewDelegate>


@property (nonatomic, strong) QQMIaoBianLab *remoteNameLabel; // 接听者名字
@property (nonatomic, strong) UIImageView *remoteUserPic; // 接听者头像
@property (nonatomic, strong)UIImageView * backImg;
@property (nonatomic, strong) UILabel *timeLabel;//接听时间

@property (nonatomic, strong) EMButton *answerButton;

@property (nonatomic, strong) UIImageView *waitImgView;//等待图片

@property (nonatomic, strong) EMStreamView *floatingView;

@property (nonatomic) EMCallSessionStatus callStatus;
@property (nonatomic, strong) EMCallSession *callSession;
@property (nonatomic)EMCallType callType;
- (instancetype)initWithCallSession:(EMCallSession *)aCallSession;

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus;

- (void)clearDataAndView;


@end
