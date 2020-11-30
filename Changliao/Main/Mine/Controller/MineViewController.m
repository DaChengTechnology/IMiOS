//
//  MineViewController.m
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "MineViewController.h"
#import "Public.h"
#import "MineDetailsViewController.h"
#import "UIViewController+oc.h"
#import "MyHeaderView.h"
#import "Chaangliao-Swift.h"
#import "ZZQAvatarPicker.h"
#import <Photos/Photos.h>
#import "MineDetailsTableViewCell.h"
#import "ZZQAvatarPicker.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Chaangliao-Swift.h"
@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,strong)UITableView * tableView;

@end

@implementation MineViewController
{
    NSArray * arr;
    MyHeaderView * headerView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    arr=@[@[@"fuzhugongneng",@"mycollection",@"loginlog",@"jubao拷贝"],@[@"辅助功能",@"我的收藏",@"登陆痕迹",@"关于我们"]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UserInfoSuccess) name:@"UserInfoSuccess" object:nil];
    self.view.backgroundColor=kColorFromRGB(242, 242, 242);
    headerView=[[MyHeaderView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, kSCRATIO(229-20)+kStatusBarHeight)];
    headerView.isSetting = YES;
    self.tableView.tableHeaderView=headerView;
    __weak typeof(self)weakSelf=self;
    [headerView setClickBlock:^(NSInteger tag) {
     
                MineDetailsViewController * vc=[[MineDetailsViewController alloc]init];
                vc.hidesBottomBarWhenPushed=YES;
                
                weakSelf.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
                
                vc.navigationController.navigationBar.hidden = YES;
        
                [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];

        
    }];
    [headerView setSaosaoBlock:^{
        NewSaoSaoViewController * vc=[[NewSaoSaoViewController alloc]init];
                        [vc setSaoyisaoBlock:^(NSString * _Nonnull str) {
        
                            [BoXinUtil onScanedWithQrcode:str];
                        }];
                        weakSelf.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    [headerView setMessageBlock:^{
        NewMessageNoyifitySettingViewController *vc = [[NewMessageNoyifitySettingViewController alloc]init];
        weakSelf.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    [headerView setUserClickBlock:^(NSInteger tag) {
        MineDetailsViewController * vc=[[MineDetailsViewController alloc]init];
        vc.hidesBottomBarWhenPushed=YES;
        
        weakSelf.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        
        vc.navigationController.navigationBar.hidden = YES;
        //
        [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_offset(0);
        make.bottom.mas_offset(-kTabHeight);
    }];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//
//    UILabel * titlab=[[UILabel alloc]init];
//    titlab.text=@"设置";
//    titlab.textColor=ColorWhite;
//    titlab.font=kFONT(18);
//    titlab.textAlignment=NSTextAlignmentCenter;
//    [self.view addSubview:titlab];
//    [titlab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_offset(kSCRATIO(34-20)+kStatusBarHeight);
//        make.left.right.mas_offset(0);
//    }];
//

}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if ([self.navigationController.topViewController isKindOfClass:[MineDetailsViewController class] ]) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.fd_prefersNavigationBarHidden = YES;

    }
//[[UIViewController getCurrentVC].navigationController setNavigationBarHidden:YES animated:animated];
    MySelfModel * model=[BoXinUtil getMySelfInfo];
    [headerView.userImg sd_setImageWithURL:[NSURL URLWithString:model.headURL] placeholderImage:[UIImage imageNamed:@"moren"]];
    headerView.userName.text=model.userName;
    headerView.numberLab.text=[NSString stringWithFormat:@"畅聊号：%@",model.idCard];
//    [self.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//        if (context.isCancelled) {
//            [self.navigationController setNavigationBarHidden:YES animated:nil];
//            self.fd_prefersNavigationBarHidden = YES;
//        }
//    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.fd_prefersNavigationBarHidden = YES;
    [super viewDidAppear:animated];
  
}
-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.topViewController isKindOfClass:[MineDetailsViewController class]]) {
        [[UIViewController getCurrentVC].navigationController setNavigationBarHidden:YES animated:animated];
        [UIViewController getCurrentVC].fd_prefersNavigationBarHidden = YES;
    }else{
        [[UIViewController getCurrentVC].navigationController setNavigationBarHidden:NO animated:animated];
        [UIViewController getCurrentVC].fd_prefersNavigationBarHidden = NO;
    }
    
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [[UIViewController getCurrentVC].navigationController setNavigationBarHidden:NO animated:animated];

    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MineDetailsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell  == nil) {
        cell=[[MineDetailsTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=UIColor.whiteColor;
        tableView.rowHeight=kSCRATIO(41);
        
    }
    cell.titImg.image=[UIImage imageNamed:arr[0][indexPath.section]];
    cell.tiLab.text=arr[1][indexPath.section];
    [cell.rightimg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(0);
    }];
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kSCRATIO(10);
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        SecondaryfunctionVc *vc = [[SecondaryfunctionVc alloc]init];
        vc.hidesBottomBarWhenPushed=YES;
        self.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];

    }else if (indexPath.section == 1) {
        CollectionViewController* vc = [[CollectionViewController alloc] initWithConversationChatter:@"collection" conversationType:EMConversationTypeChat];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteCollection"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        vc.hidesBottomBarWhenPushed=YES;
        self.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section== 2) {
        LoginLogController* vc = [LoginLogController new];
        vc.hidesBottomBarWhenPushed=YES;
        self.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];
    }else{
        AboutViewController * vc=[[AboutViewController alloc]init];
        vc.hidesBottomBarWhenPushed=YES;
        self.navigationController.navigationBar.topItem.backBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        [[UIViewController getCurrentVC].navigationController pushViewController:vc animated:YES];

    }
    dispatch_queue_t queu=dispatch_queue_create("aaaaa", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queu, ^{
        
    });
    dispatch_sync(queu, ^{
        
    });
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.bounces=NO;
    }
    return _tableView;
}

#pragma makr -- MyHeaderDelegate


// jsonString 转 NSDictionary
- (NSDictionary *)convertJsonStringToNSDictionary:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"jsonString解析失败:%@", error);
        return nil;
    }
    return json;
}

- (void) UserInfoSuccess {
    MySelfModel * model=[BoXinUtil getMySelfInfo];
    [headerView.userImg sd_setImageWithURL:[NSURL URLWithString:model.headURL] placeholderImage:[UIImage imageNamed:@"moren"]];
    headerView.userName.text=model.userName;
    headerView.numberLab.text=[NSString stringWithFormat:@"畅聊号：%@",model.idCard];
}
@end
