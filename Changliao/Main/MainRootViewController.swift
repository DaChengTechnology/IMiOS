//
//  MainRootViewController.swift
//  boxin
//
//  Created by guduzhonglao on 8/5/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

@objc public protocol ShouldPopDelegate
{
    @objc func currentViewControllerShouldPop() -> Bool
    @objc func onPop()
}

@objc extension UIViewController: ShouldPopDelegate
{
    @objc public func currentViewControllerShouldPop() -> Bool {
        return true
    }
    
    @objc public func onPop() {
        
    }
}

@objc class MainRootViewController: UINavigationController,UINavigationBarDelegate,UINavigationControllerDelegate {

}
