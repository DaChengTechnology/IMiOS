//
//  SecondaryfunctionVc.m
//  boxin
//
//  Created by Sea on 2019/7/20.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "SecondaryfunctionVc.h"
#import "SecondaryfunctionCell.h"
#import "Chaangliao-Swift.h"
@interface SecondaryfunctionVc ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@end

@implementation SecondaryfunctionVc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"辅助功能";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.tableview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"渐变填充1"]];
    self.navigationController.navigationBar.translucent=NO;

}

-(UITableView *)tableview
{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableview  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableview registerNib:[UINib nibWithNibName:@"SecondaryfunctionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SecondaryfunctionCell"];
        self.tableview.estimatedRowHeight = 0;
        self.automaticallyAdjustsScrollViewInsets=NO;
        self.tableview.estimatedSectionHeaderHeight = 0;
        
        self.tableview.estimatedSectionFooterHeight = 0;
    }
    return _tableview;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SecondaryfunctionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecondaryfunctionCell"];
    if (!cell) {
        cell = [[SecondaryfunctionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SecondaryfunctionCell"];
    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
        {   
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AddGroupChatViewController* vc = [sb instantiateViewControllerWithIdentifier:@"AddGroup"];
            vc.type = 2;
            self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
}
-(void)onBack
{
    
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
