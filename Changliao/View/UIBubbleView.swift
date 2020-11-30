//
//  UIBubbleView.swift
//  boxin
//
//  Created by guduzhonglao on 6/12/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class UIBubbleView: UIView {

    var messageBkImageView:UIImageView?
    var timeLable:UILabel?
    var hasReadImageView:UIImageView?
    var messageLabel:UILabel?
    var messageImageView:UIImageView?
    var vedioPlayImageView:UIImageView?
    
    init(model:IMessageModel) {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
        if model.isSender {
            initSendMessage(model: model)
        }else{
            initReciveMessage(model: model)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    }
    
    func initSendMessage(model: IMessageModel) {
        switch model.bodyType {
        case EMMessageBodyTypeText:
            initSendText(model: model)
        default:
            break
        }
    }
    
    func initReciveMessage(model:IMessageModel) {
        
    }
    
    func initSendText(model:IMessageModel) {
        switch model.bodyType {
        case EMMessageBodyTypeText:
            messageBkImageView = UIImageView(image: UIImage(named: "多边形1拷贝2")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 12), resizingMode: .stretch))
            messageBkImageView?.contentMode = .scaleAspectFill
            self.addSubview(messageBkImageView!)
            hasReadImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            self.addSubview(hasReadImageView!)
            if model.isMessageRead {
                hasReadImageView?.image = UIImage(named: "已读1")
            }
            timeLable = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
            timeLable?.font = UIFont.systemFont(ofSize: 8)
            timeLable?.textColor = UIColor.white
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            timeLable?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(model.message!.localTime)))
            self.addSubview(timeLable!)
            messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
            messageLabel?.font = UIFont.systemFont(ofSize: 16)
            messageLabel?.text = model.text
            messageLabel?.numberOfLines = 0
            messageLabel?.preferredMaxLayoutWidth = 190
            messageLabel?.lineBreakMode = .byWordWrapping
            self.addSubview(messageLabel!)
            messageBkImageView?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.mas_right)?.offset()(-12)
                make?.bottom.equalTo()(self.mas_bottom)?.offset()(-3)
                make?.left.equalTo()(self.mas_left)?.offset()(6)
                make?.top.equalTo()(self.mas_top)?.offset()(3)
            })
            hasReadImageView?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.mas_right)?.offset()(-12)
                make?.bottom.equalTo()(self.mas_bottom)?.offset()(-3)
                make?.height.mas_equalTo()(5)
                make?.width.mas_equalTo()(10)
            })
            timeLable?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(hasReadImageView?.mas_left)
                make?.bottom.equalTo()(self.mas_bottom)?.offset()(-3)
            })
            messageLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self.mas_left)
                make?.right.equalTo()(timeLable?.mas_left)
                make?.bottom.equalTo()(self.mas_bottom)?.offset()(-5)
                make?.top.equalTo()(self.mas_top)?.offset()(15)
                make?.height.mas_greaterThanOrEqualTo()(20)
            })
        default:
            break
        }
    }
    
}
