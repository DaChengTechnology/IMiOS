//
//  PreviewDocumentViewController.m
//  HappyChat
//
//  Created by Stn on 2019/9/15.
//  Copyright © 2019 onlysea. All rights reserved.
//

#import "PreviewDocumentViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PreviewDocumentViewController () <UIDocumentInteractionControllerDelegate>
@property(nonatomic,strong) UIDocumentInteractionController * documentVC;
@property(nonatomic,assign) BOOL finash;

@end

@implementation PreviewDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:self.locationPath];
    
    self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentVC.delegate = self;
    _finash = [self.documentVC presentPreviewAnimated:NO];
    
  
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_finash) {
        [self dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"文件无效"];
            });
        }];
    }
}
#pragma mark 代理方法
-(UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller{
     return self;
}
-(UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
     return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
      return self.view.frame;
}
//点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController*)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
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
