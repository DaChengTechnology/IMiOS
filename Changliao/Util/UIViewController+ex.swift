//
//  UIViewController+ex.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

extension UIViewController {
    /// 获取当前ViewController
    ///
    /// - Parameter base: 载体
    /// - Returns: <#return value description#>
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
    
    /// 清除所有模态
    ///
    /// - Parameter animated: 是否带动画
    func clearAllModelController(animated:Bool,complete:(() -> Void)?) {
        var presentingViewController = self.presentingViewController
        var lastVC = self
        while presentingViewController != nil {
            let temp = presentingViewController
            presentingViewController = presentingViewController?.presentingViewController
            lastVC = temp!
        }
        lastVC.dismiss(animated: animated, completion: complete)
    }
    
    func toLoginOrWelcomeCOntroller(animated:Bool,complete:(() -> Void)?) {
        var presentingViewController = self.presentingViewController
        var lastVC = self
        while presentingViewController != nil {
            let temp = presentingViewController
            presentingViewController = presentingViewController?.presentingViewController
            if let vc = presentingViewController as? UINavigationController {
                if vc.viewControllers[0] is WelcomeViewController {
                    lastVC = temp!
                    break
                }
            }
            lastVC = temp!
        }
        lastVC.dismiss(animated: animated, completion: complete)
    }
}
