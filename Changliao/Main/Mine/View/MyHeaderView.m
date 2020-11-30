//
//  MyHeaderView.m
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "MyHeaderView.h"
#import "Public.h"
#import "MySelfModel.h"
#import "Chaangliao-Swift.h"
#import "UIButton+YLY.h"

@implementation MyHeaderView

- (void)setIsSetting:(BOOL)isSetting {
    _isSetting = isSetting;
    if (self.isSetting) {
        UIImageView * erweiImg=[[UIImageView alloc]init];
        erweiImg.image=[UIImage imageNamed:@"erweima-2"];
        [self.BackImg addSubview:erweiImg];
        [erweiImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.numberLab.mas_centerY);
            make.left.mas_equalTo(self.numberLab.mas_right).offset(kSCRATIO(6));
            make.height.width.mas_offset(kSCRATIO(11));
        }];
        
        self.linewView=[[UIView alloc]init];
        self.linewView.backgroundColor=kColorFromRGBHex(0x787777);
        [self.BackImg addSubview:self.linewView];
        [self.linewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.numberLab.mas_bottom).offset(kSCRATIO(7));
            make.centerX.mas_equalTo(self.BackImg.mas_centerX);
            make.width.mas_offset(1);
            make.height.mas_offset(kSCRATIO(17));
        }];
        
        self.leftBtn=[UIButton CreatButtontext:@"扫一扫" image:[UIImage imageNamed:@"saoyisao-2"] Font:kFONT(14) Textcolor:kColorFromRGBHex(0x666666)];
        [self.leftBtn layoutWithEdgeInsetsStyle:ButtonEdgeInsetsStyle_Left imageTitleSpace:kSCRATIO(7)];
        
        [self.BackImg addSubview:self.leftBtn];
        [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kSCRATIO(80));
            make.height.mas_offset(kSCRATIO(30));
            make.right.mas_equalTo(self.linewView.mas_left).offset(kSCRATIO(-17));
            make.centerY.mas_equalTo(self.linewView.mas_centerY);
            
        }];
        [self.leftBtn addTarget:self action:@selector(saosaoClick) forControlEvents:UIControlEventTouchUpInside];
        self.rightBtn=[UIButton CreatButtontext:@"消息设置" image:[UIImage imageNamed:@"tianjialiaotian"] Font:kFONT(14) Textcolor:kColorFromRGBHex(0x666666)];
        [self.rightBtn layoutWithEdgeInsetsStyle:ButtonEdgeInsetsStyle_Left imageTitleSpace:kSCRATIO(7)];
        
        [self.BackImg addSubview:self.rightBtn];
        [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.linewView.mas_centerY);
            make.left.mas_equalTo(self.linewView.mas_right).offset(kSCRATIO(17));
            make.height.mas_offset(kSCRATIO(30));
            make.width.mas_equalTo(kSCRATIO(80));
            
        }];
        [self.rightBtn addTarget:self action:@selector(messageClick) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.numberLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userImg.mas_bottom).offset(kSCRATIO(7));
            make.centerX.equalTo(self.BackImg.mas_centerX);
        }];
    }
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}
-(void)setUI{
    UIView * topView=[[UIView alloc]init];
    topView.backgroundColor=kColorFromRGB(236, 88, 46);
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_offset(0);
        make.height.mas_offset(kStatusBarHeight+kSCRATIO(30));
    }];
    self.BackImg=[[UIImageView alloc]init];
    self.BackImg.image=[UIImage imageNamed:@"椭圆x2"];
    
    [self addSubview:self.BackImg];
    [self.BackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kStatusBarHeight);
        make.left.right.mas_offset(0);
        make.bottom.mas_offset(0);
    }];
    self.titLab=[[UILabel alloc]init];
    self.titLab.text=@"设置";
    self.titLab.textColor=ColorWhite;
    self.titLab.font=kFONT(18);
    self.titLab.textAlignment=NSTextAlignmentCenter;
    [self addSubview:self.titLab];
    [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kSCRATIO(34-20)+kStatusBarHeight);
        make.left.right.mas_offset(0);
    }];
    
    self.clickView=[[UIView alloc]init];
    [self.BackImg addSubview:self.clickView];
    [self.clickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(kNavHeight);
        make.left.mas_offset(kSCRATIO(50));
        make.right.mas_offset(kSCRATIO(-50));
        make.bottom.mas_offset(kSCRATIO(-1));
    }];
    
    UITapGestureRecognizer * otherClick=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    otherClick.delegate=self;
    self.clickView.tag=101;
    [self.clickView addGestureRecognizer:otherClick];

 
    self.userImg=[[UIImageView alloc]init];
    self.userImg.contentMode=UIViewContentModeScaleAspectFill;
    self.userImg.clipsToBounds=YES;
    ViewRadius(self.userImg, kSCRATIO(56/2));
    [self.BackImg addSubview:self.userImg];
    [self.userImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titLab.mas_bottom).offset(kSCRATIO(29));
        make.left.mas_offset(kSCRATIO(123));
        make.height.width.mas_offset(kSCRATIO(56));
    }];
    self.userName=[[UILabel alloc]init];
    self.userName.textColor=ColorBlack;
    self.userName.font=kFONT(16);
    self.userName.textAlignment=NSTextAlignmentLeft;
    [self.BackImg addSubview:self.userName];
    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImg.mas_centerY);
        make.left.mas_equalTo(self.userImg.mas_right).offset(kSCRATIO(10));
        make.right.mas_offset(kSCRATIO(-80));
    }];
    self.numberLab=[[UILabel alloc]init];
    self.numberLab.textColor=kColorFromRGBHex(0x666666);
    self.numberLab.font=kFONT(13);
    [self.BackImg addSubview:self.numberLab];
    [self.numberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImg.mas_bottom).offset(kSCRATIO(7));
        make.left.mas_equalTo(self.userImg.mas_left);
    }];
    self.BackImg.userInteractionEnabled=YES;
    //
    
    
    
    UITapGestureRecognizer * imageClick=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userIMgClick:)];
    UITapGestureRecognizer * imageClick1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userIMgClick:)];
    
    self.userImg.userInteractionEnabled=YES;
    self.userName.userInteractionEnabled=YES;
    self.userImg.tag=101;
    self.userName.tag=102;
    [self.userImg addGestureRecognizer:imageClick];
    [self.userName addGestureRecognizer:imageClick1];
    MySelfModel * model=[BoXinUtil getMySelfInfo];
    [self.userImg sd_setImageWithURL:[NSURL URLWithString:model.headURL] placeholderImage:[UIImage imageNamed:@"moren"]];
    self.userName.text=model.userName;
    self.numberLab.text=[NSString stringWithFormat:@"畅聊号：%@",model.idCard];
}
-(void)saosaoClick{
    
    if (self.saosaoBlock) {
        self.saosaoBlock();
    }
}
-(void)messageClick{
    
    if (self.messageBlock) {
        self.messageBlock();
    }
}
-(void)click:(UITapGestureRecognizer *)tap{
    
    if (self.clickBlock) {
        self.clickBlock(tap.view.tag);
    }
}
-(void)userIMgClick:(UITapGestureRecognizer *)tap{
    
    if (self.userClickBlock) {
        self.userClickBlock(tap.view.tag);
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.rightBtn] || [touch.view isDescendantOfView:self.leftBtn]) {
        
        return NO;
    }
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
