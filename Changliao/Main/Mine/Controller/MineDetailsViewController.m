//
//  MineDetailsViewController.m
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "MineDetailsViewController.h"
#import "Public.h"
#import "MineDetailsTableViewCell.h"
#import "MyHeaderView.h"
#import "Chaangliao-Swift.h"
#import "ZZQAvatarPicker.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIButton+YLY.h"
@interface MineDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property( nonatomic,strong)UITableView * tableView;


@end

@implementation MineDetailsViewController{
    NSArray * arr;
    MyHeaderView *headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=kColorFromRGBHex(0xf2f2f2);
//    self.navigationController.navigationBar.barTintColor=kColorFromRGBHex(0xec582e);
    arr=@[@[@"newMyEdit",@"newMyPhone",@"newMyErWei",@"newMySecret"],@[@"修改昵称",@"修改手机号",@"我的二维码",@"重置密码"]];
    [self.view addSubview:self.tableView];
    headerView=[[MyHeaderView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, kSCRATIO(187-20)+kStatusBarHeight)];
    headerView.BackImg.image=[UIImage imageNamed:@"mySetBack"];
    headerView.leftBtn.hidden=YES;
    headerView.rightBtn.hidden=YES;
    headerView.linewView.hidden=YES;
    UIButton * backImg=[UIButton CreatButtontext:@"" image:[UIImage imageNamed:@"myselfNewBack"] Font:nil Textcolor:nil ];
    
    [headerView addSubview:backImg];
    [backImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(headerView.titLab.mas_centerY);
        make.left.mas_offset(kSCRATIO(10));
        make.width.mas_offset(kSCRATIO(40));
        make.height.mas_offset(kSCRATIO(40));

    }];
    [backImg addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
  
    self.tableView.tableHeaderView=headerView;
    __weak typeof(self)weakSelf=self;
    [headerView setUserClickBlock:^(NSInteger tag) {
        
        if (tag==101) {
            YBIBImageData *data1 = [YBIBImageData new];
            NSString * str=[BoXinUtil getMySelfInfo].headURL;
            NSArray *array = [str componentsSeparatedByString:@"?"];
            NSString * realy=array[0];

            data1.imageURL = [NSURL URLWithString:realy];
            data1.projectiveView = headerView.userImg;
         YBImageBrowser *browser = YBImageBrowser.new;
          browser.dataSourceArray = [NSArray arrayWithObjects:data1, nil];
       [browser showToView:weakSelf.navigationController.view];
        }else{
            [ZZQAvatarPicker startSelected:^(UIImage * _Nonnull image) {
                if (image) {
                    [BoXinUtil uploadPortraitWithImage:image complite:^(BOOL finsh) {
                        headerView.userImg.image=image;
                    }];
                }
            }];
        }
    }];
   
    [headerView setClickBlock:^(NSInteger tag) {
        [ZZQAvatarPicker startSelected:^(UIImage * _Nonnull image) {
            if (image) {
                [BoXinUtil uploadPortraitWithImage:image complite:^(BOOL finsh) {
                    headerView.userImg.image=image;
                }];
            }
        }];
    
    }];
    headerView.isSetting = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_offset(0);
        make.bottom.mas_offset(0);
    }];

    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
   
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newMyBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
//
//    self.navigationItem.leftItemsSupplementBackButton = YES;
//    UIBarButtonItem *returnButtonItem =
//    returnButtonItem.image=[UIImage imageNamed:@"newMyBack"];
//    
//     self.navigationItem.backBarButtonItem = returnButtonItem;
    UILabel * logOutLab=[[UILabel alloc]init];
    logOutLab.text=@"退出登录";
    logOutLab.textColor=kColorFromRGBHex(0xff2727);
    logOutLab.font=kFONT(14);
    logOutLab.backgroundColor=ColorWhite;
    logOutLab.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:logOutLab];
    [logOutLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-BOTTOM_HEIGHT);
        make.left.right.mas_offset(0);
        make.height.mas_offset(kSCRATIO(41));
    }];
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logOutClick)];
    logOutLab.userInteractionEnabled=YES;
    [logOutLab addGestureRecognizer:tap];
    [self.navigationController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (context.isCancelled) {
            [self.navigationController setNavigationBarHidden:YES animated:nil];
            self.fd_prefersNavigationBarHidden = YES;
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.backIndicatorImage=[UIImage new];    self.fd_prefersNavigationBarHidden = YES;
    MySelfModel * model=[BoXinUtil getMySelfInfo];
    [headerView.userImg sd_setImageWithURL:[NSURL URLWithString:model.headURL] placeholderImage:[UIImage imageNamed:@"moren"]];
    headerView.userName.text=model.userName;
    headerView.numberLab.text=[NSString stringWithFormat:@"畅聊号：%@",model.idCard];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"  " style:UIBarButtonItemStylePlain target:nil action:nil];
    MineDetailsTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell) {
        UILabel* username = [cell viewWithTag:100];
        if (username) {
            username.text = model.userName;
        }
    }
   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:nil];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.backIndicatorImage=nil;
    self.fd_prefersNavigationBarHidden = YES;
    NSLog(@"aaa");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
        self.navigationController.delegate = nil;
    }
}

-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)logOutClick{
    UIAlertController * controler=[UIAlertController alertControllerWithTitle:@"是否退出?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sure=[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BoXinUtil Logout];

    }];
    UIAlertAction * canle=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    
    [controler addAction:sure];
    [controler addAction:canle];
    controler.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controler animated:YES completion:^{
        
    }];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  
    return [[UIView alloc]init];


}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return kSCRATIO(10);
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MineDetailsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel * userName;
    MySelfModel * model=[BoXinUtil getMySelfInfo];

    if (cell  == nil) {
        cell=[[MineDetailsTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
       cell.backgroundColor=UIColor.clearColor;

        tableView.rowHeight=kSCRATIO(41);
        userName=[[UILabel alloc]init];
        userName.textColor=ColorBlack;
        userName.font=kFONT(14);
        userName.tag = 100;
    }
    cell.titImg.image=[UIImage imageNamed:arr[0][indexPath.section]];
    cell.tiLab.text=arr[1][indexPath.section];
    [cell addSubview:userName];
    [userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.mas_centerY);
        make.right.mas_offset(kSCRATIO(-40));
        make.left.mas_greaterThanOrEqualTo(cell.tiLab.mas_right).offset(8);
    }];
    if (indexPath.section==0) {
        userName.text=model.userName;
        
    }else{
        userName.text=@"";
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {
        case 0:
        {
            ChangeNickNameViewController *vc=[[ChangeNickNameViewController alloc]init];
          
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
//            LoginViewController *login=[[LoginViewController alloc]init];
//            UIStoryboard * store= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            LoginViewController *login=[store instantiateViewControllerWithIdentifier:@"Login"];
//            login.type=1;
//
//            [self.navigationController pushViewController:login animated:YES];
            
        }
            break;
        case 2:
        {
            ErWeiMaViewController * erwei=[[ErWeiMaViewController alloc]init];
            MySelfModel * model=[BoXinUtil getMySelfInfo];
            NSDictionary * dic=[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"type",
                                model.userID,@"id",nil];
            erwei.jsonStr=[self convertToJsonData:dic];

            [self.navigationController pushViewController:erwei animated:YES];
        }
            break;
        case 3:{
            ResetPasswordVc * vc=[[ResetPasswordVc alloc]init];
             MySelfModel * model=[BoXinUtil getMySelfInfo];
            vc.card_id = model.idCard;
            vc.token = [[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        default:
            break;
    }

}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator=NO;
//
        _tableView.bounces=NO;
       
        
    }
    return _tableView;
}
-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
        
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;

}
- (void)setCustomGestureRecognizer {
    // 获取系统自带滑动手势的target对象
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    
    // 设置手势代理，拦截手势触发
    pan.delegate = self;
    
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:pan];
    
    // 禁止使用系统自带的滑动手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    
    // 判断当前是否禁止侧滑返回，
    UIViewController *topViewController = self.childViewControllers.lastObject;
//    if ([topViewController wyj_naviPopGRDisable]) {
//        return NO;
//    }
    
    // ---------------------- return YES------------------------------
    //如果在此处 return YES ,则是全屏侧滑返回
//#  需要注意的是：
//#    全屏返回手势，会和 系统tabbarCell 左滑删除的时候 手势冲突，导致左滑删除不出来，
//#    简单点我是将当前手势改为 左滑边缘处 才能够触发，基本和系统的一样
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGPoint offSet   = [gestureRecognizer locationInView:gestureRecognizer.view];
    BOOL    result   = (0 < offSet.x && location.x <= 40);
    return result;
    
        return YES;
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
