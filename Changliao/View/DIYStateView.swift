//
//  DIYStateView.swift
//  boxin
//
//  Created by guduzhonglao on 8/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DIYStateView: UIView {
    
    var index:Int = -1

    var sendingActive:UIActivityIndicatorView{
        let active = UIActivityIndicatorView(style: .gray)
        active.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return active
    }
    
    var errButton:UIButton {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn.setImage(UIImage(named: "叉叉"), for: .normal)
        btn.setImage(UIImage(named: "对勾"), for: .disabled)
        return btn
    }
    
    func setModel(_ model:BoxinMessageModel) {
        self.backgroundColor = UIColor.clear
        if model.isSender {
            if model.messageStatus == EMMessageStatusPending {
                if sendingActive.isAnimating {
                    sendingActive.stopAnimating()
                }
                sendingActive.removeFromSuperview()
                errButton.removeFromSuperview()
                self.addSubview(sendingActive)
                sendingActive.startAnimating()
                return
            }else if model.messageStatus == EMMessageStatusFailed {
                if sendingActive.isAnimating {
                    sendingActive.stopAnimating()
                }
                sendingActive.removeFromSuperview()
                errButton.removeFromSuperview()
                self.addSubview(errButton)
                errButton.isEnabled = true
                return
            }else if model.isMessageRead {
                if sendingActive.isAnimating {
                    sendingActive.stopAnimating()
                }
                sendingActive.removeFromSuperview()
                errButton.removeFromSuperview()
                self.addSubview(errButton)
                errButton.isEnabled = false
                return
            }else{
                if sendingActive.isAnimating {
                    sendingActive.stopAnimating()
                }
                sendingActive.removeFromSuperview()
                errButton.removeFromSuperview()
            }
        }
    }

}
