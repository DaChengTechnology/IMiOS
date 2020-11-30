//
//  ChatRefhreshHeader.swift
//  boxin
//
//  Created by guduzhonglao on 8/25/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class ChatRefhreshHeader: MJRefreshHeader {
    
    var loadBkView:UIView?
    var activityIndicatorView:UIActivityIndicatorView?
    
    override var state: MJRefreshState{
        didSet{
            switch self.state {
            case .refreshing:
                activityIndicatorView?.frame = CGRect(x: 2.5, y: 2.5, width: 20, height: 20)
                activityIndicatorView?.isHidden = false
                activityIndicatorView?.startAnimating()
            default:
                activityIndicatorView?.stopAnimating()
                activityIndicatorView?.isHidden = true
            }
        }
    }
    
    override var pullingPercent: CGFloat{
        didSet{
            var per = self.pullingPercent
            if per > 1 {
                per = 1
            }
            loadBkView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25 * per))
            loadBkView?.center = self.center
        }
    }

    override func prepare() {
        super.prepare()
        self.mj_h = 50
        loadBkView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        loadBkView?.center = self.center
        addSubview(loadBkView!)
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView?.frame = CGRect(x: 2.5, y: 2.5, width: 20, height: 20)
        loadBkView?.addSubview(activityIndicatorView!)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        loadBkView?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        activityIndicatorView?.isHidden = true
    }

}
