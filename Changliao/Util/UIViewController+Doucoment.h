//
//  UIViewController+Doucoment.h
//  SDKtextDemo
//
//  Created by Stn on 2019/8/6.
//  Copyright © 2019 Stn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Doucoment)<UIDocumentInteractionControllerDelegate>
@property(nonatomic,strong)UIDocumentInteractionController * document;
/**
 设置初始化
 */
-(void)setDocument;
/**
 显示文件打开方式

 @param URL 文件url
 @param viewController 当前视图
 */
-(void)showURL:(NSURL *)URL And:(UIViewController *)viewController ;
@end

NS_ASSUME_NONNULL_END
