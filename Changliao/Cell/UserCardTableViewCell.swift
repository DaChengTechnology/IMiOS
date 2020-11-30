//
//  UserCardTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/19/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class UserCardTableViewCell: UITableViewCell,IModelChatCell {
    var model: Any!
    var delegate:EaseMessageCellDelegate?
    var headImageView:UIImageView?
    var nikeNameLabel:UILabel?
    var cardView:UIView?
    var shareCardUserHead:UIImageView?
    var shareCardNickName:UILabel?
    var shareUserCardId:UILabel?
    var cardLabel:UILabel?
    
    static func cellIdentifier(withModel model: Any!) -> String! {
        return "UserCard"
    }
    
    static func cellHeight(withModel model: Any!) -> CGFloat {
        return 110
    }
    
    required init!(style: UITableViewCell.CellStyle, reuseIdentifier: String!, model: Any!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.model = model
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        selectionStyle = .none
        headImageView = UIImageView(image: UIImage(named: "moren"))
        self.contentView.addSubview(headImageView!)
        headImageView?.isUserInteractionEnabled = true
        let headTap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(g:)))
        headImageView?.addGestureRecognizer(headTap)
        headImageView?.layer.cornerRadius = 4
        headImageView?.layer.masksToBounds = true
//        nikeNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
//        nikeNameLabel?.textColor = UIColor.gray
//        nikeNameLabel?.font = UIFont.systemFont(ofSize: 12)
//        self.contentView.addSubview(nikeNameLabel!)
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        cardView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        cardView?.layer.cornerRadius = 5
        cardView?.layer.masksToBounds = true
        cardView?.layer.borderWidth = 1
        cardView?.backgroundColor = UIColor.white
        cardView?.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "f3f3f3").cgColor
        cardView?.isUserInteractionEnabled = true
        self.contentView.addSubview(cardView!)
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        cardView?.addSubview(lineView)
        lineView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "f3f3f3")
        shareCardUserHead =  UIImageView(image: UIImage(named: "moren"))
        cardView?.addSubview(shareCardUserHead!)
        shareCardUserHead?.layer.cornerRadius = 5
        shareCardUserHead?.layer.masksToBounds = true
        shareUserCardId = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        shareUserCardId?.font = UIFont.systemFont(ofSize: 14)
        shareUserCardId?.textColor = UIColor.lightGray
        cardView?.addSubview(shareUserCardId!)
        shareCardNickName = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        shareCardNickName?.font = UIFont.systemFont(ofSize: 17)
        cardView?.addSubview(shareCardNickName!)
        cardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        cardLabel?.font = UIFont.systemFont(ofSize: 14)
        cardLabel?.text = "个人名片"
        cardLabel?.textColor = UIColor.lightGray
        cardView?.addSubview(cardLabel!)
        let tapView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        tapView.backgroundColor = UIColor.clear
        cardView?.addSubview(tapView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onMessageClick(g:)))
        tapView.addGestureRecognizer(tap)
        tapView.mas_makeConstraints { (make) in
            make?.top.equalTo()(cardView?.mas_top)
            make?.left.equalTo()(cardView?.mas_left)
            make?.right.equalTo()(cardView?.mas_right)
            make?.bottom.equalTo()(cardView?.mas_bottom)
        }
        let mo = model as! IMessageModel
        if mo.isSender {
            headImageView?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.contentView.mas_right)?.offset()(-8)
                make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
                make?.height.mas_equalTo()(40)
                make?.width.mas_equalTo()(40)
            })
//            nikeNameLabel?.mas_makeConstraints({ (make) in
//                make?.right.equalTo()(headImageView?.mas_left)?.offset()(-8)
//                make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
//            })
            cardView?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(self.contentView)?.offset()(8)
                make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-8)
                make?.left.equalTo()(self.contentView.mas_left)?.offset()(70)
                make?.right.equalTo()(headImageView?.mas_left)?.offset()(-8)
            })
            shareCardUserHead?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(cardView?.mas_left)?.offset()(8)
                make?.top.equalTo()(cardView?.mas_top)?.offset()(8)
                make?.height.mas_equalTo()(50)
                make?.width.mas_equalTo()(50)
            })
            shareCardNickName?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(shareCardUserHead?.mas_right)?.offset()(8)
                make?.top.equalTo()(shareCardUserHead?.mas_top)?.offset()(0)
                make?.right.lessThanOrEqualTo()(cardView?.mas_right)?.offset()(-8)
                make?.height.equalTo()(20)
            })
            shareUserCardId?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(shareCardUserHead?.mas_right)?.offset()(8)
                make?.top.equalTo()(shareCardNickName?.mas_bottom)?.offset()(10)
                make?.height.equalTo()(20)
            })
            lineView.mas_makeConstraints { (make) in
                make?.left.equalTo()(cardView)
                make?.right.equalTo()(cardView)
                make?.top.equalTo()(shareCardUserHead?.mas_bottom)?.offset()(8)
                make?.height.mas_equalTo()(0.5)
            }
            cardLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(cardView?.mas_left)?.offset()(8)
                make?.bottom.equalTo()(cardView?.mas_bottom)?.offset()(-8)
            })
        }else{
            headImageView?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self.contentView.mas_left)?.offset()(8)
                make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
                make?.height.mas_equalTo()(40)
                make?.width.mas_equalTo()(40)
            })
//            nikeNameLabel?.mas_makeConstraints({ (make) in
//                make?.left.equalTo()(headImageView?.mas_right)?.offset()(8)
//                make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
//            })
            cardView?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(self.contentView)?.offset()(8)
                make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-8)
                make?.right.equalTo()(self.contentView.mas_right)?.offset()(-70)
                make?.left.equalTo()(headImageView?.mas_right)?.offset()(8)
            })
            shareCardUserHead?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(cardView?.mas_left)?.offset()(8)
                make?.top.equalTo()(cardView?.mas_top)?.offset()(8)
                make?.height.mas_equalTo()(50)
                make?.width.mas_equalTo()(50)
            })
            shareCardNickName?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(shareCardUserHead?.mas_right)?.offset()(8)
                make?.top.equalTo()(shareCardUserHead?.mas_top)?.offset()(0)
                make?.right.lessThanOrEqualTo()(cardView?.mas_right)?.offset()(-8)
                make?.height.equalTo()(20)
            })
            shareUserCardId?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(shareCardUserHead?.mas_right)?.offset()(8)
                make?.top.equalTo()(shareCardNickName?.mas_bottom)?.offset()(10)
                make?.height.equalTo()(20)
            })
            lineView.mas_makeConstraints { (make) in
                make?.left.equalTo()(cardView)
                make?.right.equalTo()(cardView)
                make?.top.equalTo()(shareCardUserHead?.mas_bottom)?.offset()(8)
                make?.height.mas_equalTo()(0.5)
            }
            cardLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(cardView?.mas_left)?.offset()(8)
                make?.bottom.equalTo()(cardView?.mas_bottom)?.offset()(-8)
            })
        }
    }
    
    @objc private func onHeadClick(g:UIGestureRecognizer) {
        delegate?.avatarViewSelcted?(model as? IMessageModel)
    }
    
    @objc private func onMessageClick(g:UIGestureRecognizer) {
        delegate?.messageCellSelected?(model as? IMessageModel)
    }

}
