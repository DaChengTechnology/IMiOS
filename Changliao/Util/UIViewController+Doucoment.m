//
//  UIViewController+Doucoment.m
//  SDKtextDemo
//
//  Created by Stn on 2019/8/6.
//  Copyright © 2019 Stn. All rights reserved.
//

#import "UIViewController+Doucoment.h"

@implementation UIViewController (Doucoment)
-(void)setDocument{
    self.document=[[UIDocumentInteractionController alloc]init];
    self.document.delegate=self;
}
-(void)showURL:(NSURL *)URL And:(UIViewController *)viewController{
    self.document = [UIDocumentInteractionController interactionControllerWithURL:URL];
    self.document.UTI = @"com.microsoft.word.doc.pdf.mp4.mov.text.zip";
    [self.document presentOpenInMenuFromRect:viewController.view.bounds inView:viewController.view animated:YES];
}
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
    
}
// 文件分享面板弹出的时候调用
-(void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController*)controller{
    
     NSLog(@"WillPresentOpenInMenu");
}
// 当选择一个文件分享App的时候调用
-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    
}

// 弹框消失的时候走的方法
-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController*)controller{
    NSLog(@"dissMiss");
}

@end
