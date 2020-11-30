//
//  ErWeiMaViewController.m
//  boxin
//
//  Created by Sea on 2019/8/1.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "ErWeiMaViewController.h"
#import "Public.h"
#import <SDWebImage/SDWebImage.h>
#import "Chaangliao-Swift.h"
#import "WSLNativeScanTool.h"

@interface ErWeiMaViewController ()

@end

@implementation ErWeiMaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=kColorFromRGBHex(0xf6f6f6);
    self.title=@"二维码名片";
    [self loadUI];
}
-(void)loadUI{
    UIView * whiteView=[[UIView alloc]init];
    whiteView.backgroundColor=ColorWhite;
    [whiteView.layer setMasksToBounds:YES];
    [whiteView.layer setCornerRadius:5];
    [self.view addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(HEIGHT/2-kSCRATIO(441)/2-kNavHeight);
        make.left.mas_offset(kSCRATIO(20));
        make.right.mas_offset(kSCRATIO(-20));
        make.height.mas_offset(kSCRATIO(441));
    }];
    UIImageView * imgv=[[UIImageView alloc]init];
    [whiteView addSubview:imgv];
    UIImageView * titImg=[[UIImageView alloc]init];
    [titImg.layer setMasksToBounds:YES];
    [titImg.layer setCornerRadius:5];
    titImg.contentMode=UIViewContentModeScaleAspectFill;
    titImg.clipsToBounds=YES;
    [whiteView addSubview:titImg];
    [titImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kSCRATIO(25));
        make.left.mas_equalTo(imgv.mas_left);
        make.height.width.mas_offset(kSCRATIO(61));
    }];
    UserModel* model = [BoXinUtil getUserInfo];
    [titImg sd_setImageWithURL:[NSURL URLWithString:model.userImg] placeholderImage:[UIImage imageNamed:@"moren"]];
    UILabel * titlab=[[UILabel alloc]init];
    titlab.text=model.userName;
    titlab.font=kFONT(15);
    titlab.textAlignment=NSTextAlignmentLeft;
    titlab.textColor=ColorBlack;
    [whiteView addSubview:titlab];
    [titlab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kSCRATIO(38));
        make.left.mas_equalTo(titImg.mas_right).offset(kSCRATIO(11));
        make.right.mas_equalTo(whiteView.mas_right).offset(kSCRATIO(-10));
    }];
    UILabel * idCardLab=[[UILabel alloc]init];
    idCardLab.textColor=kColorFromRGB(138, 136, 136);
    idCardLab.text=model.userIDCard;
    idCardLab.textAlignment=NSTextAlignmentLeft;
    idCardLab.font=kFONT(15);
    [whiteView addSubview:idCardLab];
    [idCardLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titlab.mas_bottom).offset(kSCRATIO(9));
        make.left.mas_equalTo(titImg.mas_right).offset(kSCRATIO(11));

    }];
    [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titImg.mas_bottom).offset(kSCRATIO(28));
        make.centerX.mas_equalTo(whiteView.mas_centerX);
        make.width.mas_offset(kSCRATIO(271));
        make.height.mas_offset(kSCRATIO(262));
    }];
    NSString * str=self.jsonStr;
    imgv.image=[WSLNativeScanTool createQRCodeImageWithString:str andSize:CGSizeMake(kSCRATIO(271), kSCRATIO(262)) andBackColor:ColorWhite andFrontColor:[UIColor blackColor] andCenterImage:nil];
    UILabel * backLab=[[UILabel alloc]init];
    backLab.text=@"扫一扫上面的二维码图案";
    backLab.textColor=kColorFromRGB(138, 136, 136);
    backLab.textAlignment=NSTextAlignmentCenter;
    [whiteView addSubview:backLab];
    [backLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imgv.mas_bottom).offset(kSCRATIO(24));
        make.left.right.mas_offset(0);
        
    }];

    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"渐变填充1"]];
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
