//
//  shakeVc.h
//  boxin
//
//  Created by Sea on 2019/8/4.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface shakeVc : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *IconImage;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UIButton *LeftButton;
@property (weak, nonatomic) IBOutlet UIButton *RightButton;
@property (weak, nonatomic) IBOutlet UIImageView *waitIMage;
@property (nonatomic,strong)NSString *Username;
@property (nonatomic,strong)NSString *UserIcon;
@property (nonatomic,strong)NSString *UserId;

@end

NS_ASSUME_NONNULL_END
