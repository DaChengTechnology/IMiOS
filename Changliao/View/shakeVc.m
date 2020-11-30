//
//  shakeVc.m
//  boxin
//
//  Created by Sea on 2019/8/4.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "shakeVc.h"
#import <SDWebImage/SDWebImage.h>
#import "Chaangliao-Swift.h"
#import "UIViewController+oc.h"

@interface shakeVc ()
@property (nonatomic,strong)AVAudioPlayer *ringPlayer;
@property (nonatomic,strong)AppDelegate *app;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation shakeVc

- (void)viewDidLoad {
    [super viewDidLoad];
    _UserName.text = _Username;
    [_IconImage sd_setImageWithURL:[NSURL URLWithString:_UserIcon]];
//    _UserName.font = [UIFont systemFontOfSize:25];
    _IconImage.layer.masksToBounds = YES;
    _IconImage.layer.cornerRadius = 45;
    [self ShowGif];
    [self Player];
}
-(void)ShowGif
{
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"抖一抖4" withExtension:@"gif"];//加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);//将GIF图片转换成对应的图片源
    size_t frameCout=CGImageSourceGetCount(gifSource);//获取其中图片源个数，即由多少帧图片组成
    NSMutableArray* frames=[[NSMutableArray alloc] init];//定义数组存储拆分出来的图片
    for (size_t i=0; i<frameCout;i++){
        CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);//从GIF图片中取出源图片
        UIImage* imageName=[UIImage imageWithCGImage:imageRef];//将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];//将图片加入数组中
        CGImageRelease(imageRef);
    }
    CFRelease(gifSource);
    _waitIMage.animationImages=frames;//将图片数组加入UIImageView动画数组中
    _waitIMage.animationDuration=3;//每次动画时长
    [_waitIMage startAnimating];//开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
    [_LeftButton sd_setImageWithURL:[[NSBundle mainBundle] URLForResource:@"忽略0.1" withExtension:@"gif"] forState:UIControlStateNormal];
    [_RightButton sd_setImageWithURL:[[NSBundle mainBundle] URLForResource:@"抖一抖接听0.1" withExtension:@"gif"] forState:UIControlStateNormal];
}
-(void)Player
{
    _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_app.player != nil) {
        if (_app.player.isPlaying == YES) {
            [_app.player stop];
        }
    }
    [_ringPlayer stop];
    FriendData* f = [BoXinUtil getFriendDataWithId:self.UserId];
    if (f) {
        if (f.is_shield == 1) {
            return;
        }
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"newMessage"]  isEqualToString: @"1"]) {        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"]  isEqualToString: @"1"]) {
            if (_ringPlayer == nil) {
                _ringPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"shake" withExtension:@"mp3"] error:nil];
            }
            
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [_ringPlayer setVolume:1.0];
            _ringPlayer.numberOfLoops = -1;
            if ([_ringPlayer prepareToPlay]) {
                _app.player = _ringPlayer;
                [_ringPlayer play];
            }
        }
    }
//    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"newMessage"]  isEqualToString: @"1"]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"shake"]  isEqualToString: @"1"]) {
            _timer = [NSTimer timerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(timerRepeat:)
                                                   userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop] addTimer:_timer
                                         forMode:NSRunLoopCommonModes];
            
            [_timer fire];
            if (_app.timer != nil) {
                dispatch_source_cancel(_app.timer);
            }
            
        }
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_timer) {
        [_timer invalidate];
    }
    if (_ringPlayer) {
        [_ringPlayer stop];
    }
}

-(void)timerRepeat:(NSTimer *)timer
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}
- (IBAction)LeftBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [BoXinUtil dissmissGotoChat];
    }];
}
- (IBAction)RightBtn:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        if ([[self getCurrentViewController] isKindOfClass:[ChatViewController class]]) {
            ChatViewController* chat = [self getCurrentViewController];
            if ([chat.conversation.conversationId isEqualToString:self.UserId]) {
                return ;
            }else{
                [[self getCurrentViewController].navigationController popToRootViewControllerAnimated:YES];
                ChatViewController *vc = [[ChatViewController alloc]initWithConversationChatter:self->_UserId conversationType:EMConversationTypeChat];
                
                [self getCurrentViewController].navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
                vc.title = self->_Username;
                [[[self getCurrentViewController]navigationController] pushViewController:vc animated:YES];
                return;
            }
        }
        ChatViewController *vc = [[ChatViewController alloc]initWithConversationChatter:self->_UserId conversationType:EMConversationTypeChat];
        
        [self getCurrentViewController].navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        vc.title = self->_Username;
        [[[self getCurrentViewController]navigationController] pushViewController:vc animated:YES];
    }];
}
- (UIViewController *)getCurrentViewController
{
    UIViewController *result = nil;
    // 获取默认的window
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    // app默认windowLevel是UIWindowLevelNormal，如果不是，找到它。
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    // 获取window的rootViewController
    result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result visibleViewController];
    }
    return result;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
