//
//  EMCallViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMButton.h"

static bool isHeadphone()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    
    return NO;
}

@interface EMCallViewController : UIViewController

#if DEMO_CALL == 1

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) EMButton *microphoneButton;//k静音
@property (nonatomic, strong) EMButton *speakerButton;//免提

@property (nonatomic, strong) EMButton *hangupButton;//挂断
@property (nonatomic, strong) UIButton *minButton;

- (void)microphoneButtonAction;

- (void)speakerButtonAction;

- (void)minimizeAction;

- (void)hangupAction;

#endif

@end
