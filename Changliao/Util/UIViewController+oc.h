//
//  UIViewController+oc.h
//  
//
//  Created by guduzhonglao on 6/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (oc)

+ (UIViewController *)getCurrentVC;
+ (UIViewController *)getPresentedViewController;
- (void) dissmissAllController;

@end

NS_ASSUME_NONNULL_END
