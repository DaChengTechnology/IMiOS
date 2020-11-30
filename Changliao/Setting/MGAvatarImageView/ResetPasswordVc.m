//
//  ResetPasswordVc.m
//  boxin
//
//  Created by Sea on 2019/7/20.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "ResetPasswordVc.h"
#import "Chaangliao-Swift.h"
#import "SendCodeModel.h"
#import "UIViewController+oc.h"
@interface ResetPasswordVc ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *NumberLab;
@property (weak, nonatomic) IBOutlet UITextField *NewPassword;
@property (weak, nonatomic) IBOutlet UITextField *TwoNewPassword;
@property(nonatomic,strong)UILabel* placeholderLab;
@end

@implementation ResetPasswordVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重置密码";
    _NumberLab.text = self.card_id;
    _NewPassword.secureTextEntry = YES;
    _TwoNewPassword.secureTextEntry = YES;
    _NewPassword.delegate = self;
    _TwoNewPassword.delegate = self;
    _NewPassword.keyboardType = UIKeyboardTypeASCIICapable;
    _TwoNewPassword.keyboardType = UIKeyboardTypeASCIICapable;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done",@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(OverReset)];
    self.placeholderLab=[[UILabel alloc]init];
    [self.view addSubview:self.placeholderLab];
    self.placeholderLab.textColor=kColorFromRGBHex(0x8a8888);
    self.placeholderLab.text=@"密码必须是8-16位数字、字符组合";
    self.placeholderLab.font=kFONT(11);
    [self.placeholderLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_TwoNewPassword.mas_bottom).offset(kSCRATIO(10));
        make.left.mas_offset(kSCRATIO(19));
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"渐变填充1"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    NSString *regex = @"^[a-zA-Z0-9]";
    NSPredicate *emailValidate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailValidate evaluateWithObject:string];
}

-(void)OverReset
{
    [self.view endEditing:YES];
    if ([_NewPassword.text isEqualToString:_TwoNewPassword.text] ) {
        if (_NewPassword.text.length>=8 && _NewPassword.text.length <=16) {
            if ([self deptNumInputShouldNumber:_NewPassword.text]) {
                [SVProgressHUD showErrorWithStatus:@"密码只能为8-16位数字密码组合"];
                [SVProgressHUD dismissWithDelay:1.0];
            }else{
                if ([self deptStringInputShouldNumber:_NewPassword.text]) {
                    [SVProgressHUD showErrorWithStatus:@"密码只能为8-16位数字密码组合"];
                    [SVProgressHUD dismissWithDelay:1.0];
                }else{
                    [self NetWorkRequest];
                }
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"密码只能为8-16位数字密码组合"];
            [SVProgressHUD dismissWithDelay:1.0];
        }
        
    }else
    {
        [SVProgressHUD showErrorWithStatus:@"两次密码不一致"];
        [SVProgressHUD dismissWithDelay:1.0];
    }
}
-(void)NetWorkRequest
{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    [manager.requestSerializer setValue:([NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"])  forHTTPHeaderField:@"version"];
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"client"];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"imToken"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"ios:%@",[BoXinUtil getIMEI]] forHTTPHeaderField:@"imei"];
    [manager.requestSerializer setValue:[UtilTools deviceModel] forHTTPHeaderField:@"dbrand"];
    NSDictionary *dict = @{
                           @"token":self.token,
                           @"client_type":@"1",
                           @"password":_NewPassword.text
                           
                           };
    // parameters 参数字典
    NSString *str = @"register/resetPassword";
    NSString *UrlStr = [NSString stringWithFormat:@"%@%@",ApiHead1er,str];
    [manager GET:UrlStr parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        //进度
//        [MBProgressHUD showHUDAddedTo:self animated:YES];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SendCodeModel *model = [SendCodeModel mj_objectWithKeyValues:responseObject];
        if (![BoXinUtil isTokenExpired:[model.code integerValue]]) {
            return;
        }
        if ([model.code isEqualToString:@"200"]) {
            [BoXinUtil Logout];
            [self.navigationController popToRootViewControllerAnimated:NO];
            dispatch_after(DISPATCH_TIME_NOW + 2, dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"重置密码成功， 请重新登陆"];
                [SVProgressHUD dismissWithDelay:2.0];
            });
        }else
        {
            [SVProgressHUD showErrorWithStatus:model.message];
            [SVProgressHUD dismissWithDelay:1.0];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // error 错误信息
        
        [SVProgressHUD showErrorWithStatus:@"重置失败"];
        [SVProgressHUD dismissWithDelay:1.0];
    }];
    
    
}
- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (BOOL) deptStringInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[a-zA-Z]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
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
