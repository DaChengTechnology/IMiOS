//
//  MyHeaderView.h
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyHeaderView : UIView<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UILabel * titLab;
@property(nonatomic,strong)UIImageView * userImg;
@property(nonatomic,strong)UILabel * userName;
@property(nonatomic,strong)UILabel * numberLab;
@property(nonatomic,strong)UIButton * leftBtn;
@property(nonatomic,strong)UIButton * rightBtn;
@property(nonatomic,strong)UIImageView * BackImg;
@property(nonatomic,strong)UIImageView * whiteView;
@property(nonatomic,strong)UIView * linewView;
@property(nonatomic,strong)    UIView * clickView;
@property(nonatomic,copy)void(^messageBlock)(void);
@property(nonatomic,copy)void(^saosaoBlock)(void);
@property(nonatomic,copy)void(^userClickBlock)(NSInteger tag);
@property(nonatomic,copy)void(^clickBlock)(NSInteger tag);
@property(nonatomic) BOOL isSetting;

@end

NS_ASSUME_NONNULL_END
