//
//  DIYMessageCell.swift
//  boxin
//
//  Created by guduzhonglao on 8/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

protocol DIYMessageCellDelegate {
    func headViewClick(model:MessageViewModel)
    func headViewLongPass(model:MessageViewModel)
    func messageClick(model:BoxinMessageModel)
    func messageLongPass(model:BoxinMessageModel)
    func onMessageStateClick(model:BoxinMessageModel)
}

class DIYMessageCell: UITableViewCell {
    
    var headView:ChatHeadView?
    var senderNameLabel:UILabel?
    var bubbleList:[DIYBubleView]?
    var stateList:[DIYStateView]?
    var delegate:DIYMessageCellDelegate?
    var maxWidth = UIScreen.main.bounds.width - (15 + 50 + 10) * 2
    var selectView:[UIImageView]?
    var isMutableSelect:Bool = false {
        didSet {
            MutableSelectChange()
        }
    }
    var model:MessageViewModel?{
        didSet{
            setup()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        if model!.messageList![0].isSender {
            setupSender()
        }else{
            setupReciver()
        }
    }
    
    func setupSender() {
        headView = ChatHeadView(image: model!.messageList![0].avatarImage)
        headView?.layer.cornerRadius = 5
        if model!.messageList![0].avatarURLPath != nil {
            headView?.sd_setImage(with: URL(string: model!.messageList![0].avatarURLPath), completed: nil)
        }
        self.contentView.addSubview(headView!)
        headView?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(self.contentView)?.offset()(-15)
            make?.top.equalTo()(self.contentView)?.offset()(5)
            make?.height.mas_equalTo()(50)
            make?.width.mas_equalTo()(50)
        })
        if bubbleList != nil {
            for b in bubbleList! {
                b.removeFromSuperview()
            }
        }
        if stateList != nil {
            for s in stateList! {
                s.removeFromSuperview()
            }
        }
        for (index,mod) in model!.messageList!.enumerated() {
            let bubble = DIYBubleView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            bubble.index = index
            bubble.pp.hiddenBadge()
            self.contentView.addSubview(bubble)
            if index == 0 {
                if mod.bodyType == EMMessageBodyTypeText {
                    if mod.isIDCard {
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(self.contentView)?.offset()(5)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        }
                    }else if mod.isGifFace {
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(self.contentView)?.offset()(5)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(130)
                            make?.height.mas_equalTo()(130)
                        }
                    }else{
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(self.contentView)?.offset()(18)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        }
                    }
                }
                if mod.bodyType == EMMessageBodyTypeVoice {
                    bubble.mas_makeConstraints { (make) in
                        make?.top.equalTo()(self.contentView)?.offset()(18)
                        make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        make?.width.mas_equalTo()(65)
                        make?.height.mas_equalTo()(25)
                    }
                }
                if mod.bodyType == EMMessageBodyTypeImage || mod.bodyType == EMMessageBodyTypeVideo {
                    if mod.thumbnailImage != nil {
                        bubble.image = mod.thumbnailImage
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(self.contentView)?.offset()(5)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(mod.thumbnailImageSize.width)
                            make?.height.mas_equalTo()(mod.thumbnailImageSize.height)
                        }
                    }else{
                        // 展位图
                        bubble.image = UIImage(named: "未加载")
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(self.contentView)?.offset()(5)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(150)
                            make?.height.mas_equalTo()(112.5)
                        }
                    }
                }
                if mod.bodyType == EMMessageBodyTypeLocation {
                    bubble.mas_makeConstraints { (make) in
                        make?.top.equalTo()(self.contentView)?.offset()(5)
                        make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        make?.width.mas_equalTo()(170)
                        make?.height.mas_equalTo()(85)
                    }
                }
                bubbleList = Array<DIYBubleView>()
                bubbleList?.append(bubble)
            }else{
                if mod.bodyType == EMMessageBodyTypeText {
                    if mod.isIDCard {
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        }
                    }else if mod.isGifFace {
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(130)
                            make?.height.mas_equalTo()(130)
                        }
                    }else{
                        bubble.mas_makeConstraints { (make) in
                           make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        }
                    }
                }
                if mod.bodyType == EMMessageBodyTypeVoice {
                    bubble.mas_makeConstraints { (make) in
                        make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                        make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        make?.width.mas_equalTo()(65)
                        make?.height.mas_equalTo()(25)
                    }
                }
                if mod.bodyType == EMMessageBodyTypeImage || mod.bodyType == EMMessageBodyTypeVideo {
                    if mod.thumbnailImage != nil {
                        bubble.image = mod.thumbnailImage
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(mod.thumbnailImageSize.width)
                            make?.height.mas_equalTo()(mod.thumbnailImageSize.height)
                        }
                    }else{
                        // 展位图
                        bubble.image = UIImage(named: "未加载")
                        bubble.mas_makeConstraints { (make) in
                            make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                            make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                            make?.width.mas_equalTo()(150)
                            make?.height.mas_equalTo()(112.5)
                        }
                    }
                }
                if mod.bodyType == EMMessageBodyTypeLocation {
                    bubble.mas_makeConstraints { (make) in
                        make?.top.equalTo()(bubbleList?.last)?.offset()(10)
                        make?.right.equalTo()(headView?.mas_left)?.offset()(-10)
                        make?.width.mas_equalTo()(170)
                        make?.height.mas_equalTo()(85)
                    }
                }
            }
            bubble.model = mod
            if mod.bodyType == EMMessageBodyTypeText && !mod.isGifFace && !mod.isIDCard {
                
            }
        }
    }
    
    func setupReciver() {
        headView = ChatHeadView(image: model!.messageList![0].avatarImage)
        headView?.layer.cornerRadius = 5
        if model!.messageList![0].avatarURLPath != nil {
            headView?.sd_setImage(with: URL(string: model!.messageList![0].avatarURLPath), completed: nil)
        }
        headView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(g:)))
        headView?.addGestureRecognizer(tap)
        let long = UILongPressGestureRecognizer(target: self, action: #selector(onHeadClick(g:)))
        long.minimumPressDuration = 0.5
        headView?.addGestureRecognizer(long)
        self.contentView.addSubview(headView!)
        headView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.contentView)?.offset()(15)
            make?.top.equalTo()(self.contentView)?.offset()(5)
            make?.height.mas_equalTo()(50)
            make?.width.mas_equalTo()(50)
        })
        if model!.messageList![0].messageType == EMChatTypeGroupChat {
            senderNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            senderNameLabel?.font = UIFont.systemFont(ofSize: 11)
            senderNameLabel?.textColor = UIColor.gray
            senderNameLabel?.numberOfLines = 1
            senderNameLabel?.text = model!.messageList![0].nickname
            self.contentView.addSubview(senderNameLabel!)
            senderNameLabel?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(headView?.mas_bottom)?.offset()(6)
                make?.centerX.equalTo()(headView)
                make?.width.lessThanOrEqualTo()(headView?.mas_width)
            })
        }
    }
    
    @objc func onMessageClick(g:UIGestureRecognizer) {
        if g is UILongPressGestureRecognizer {
            if g.state == .ended {
                delegate?.headViewLongPass(model:self.model!)
            }
        }else{
            if g.state == .ended {
                delegate?.headViewLongPass(model: model!)
            }
        }
    }
    
    @objc func onHeadClick(g:UIGestureRecognizer) {
        if g is UILongPressGestureRecognizer {
            if g.state == .ended {
                delegate?.headViewLongPass(model:self.model!)
            }
        }else{
            if g.state == .ended {
                delegate?.headViewLongPass(model: model!)
            }
        }
    }
    
    private func MutableSelectChange() {
        
    }
    
    static func cellHeight(model:MessageViewModel) -> CGFloat {
        var height = CGFloat(18)
        for m in model.messageList! {
            if m.bodyType == EMMessageBodyTypeText {
                if m.isIDCard {
                    if height == 18 {
                        height = 120
                    }else{
                        height += 120
                    }
                    continue
                }
                if m.isGifFace {
                    if height == 18 {
                        height = 140
                    }else{
                        height += 140
                    }
                    continue
                }
                let tmpWidth = DCUtill.ga_widthForComment(str: m.text, fontSize: 13, height: 13)
                if tmpWidth < UIScreen.main.bounds.width - (15 + 50 + 10) * 2 {
                    if height > 18 {
                        height += 13 + 7 + 6  + 10
                    }else{
                        height += 13 + 7 + 6
                    }
                }else{
                    let tmpHeight = DCUtill.true_heightForComment(str: m.text, fontSize: 13, width: UIScreen.main.bounds.width - (15 + 50 + 10) * 2)
                    if height > 18 {
                        height += tmpHeight + 7 + 6  + 10
                    }else{
                        height += tmpHeight + 7 + 6
                    }
                }
            }
            if m.bodyType == EMMessageBodyTypeVoice {
                if height > 18 {
                    height += 26 + 10
                }else{
                    height += 26
                }
            }
            if m.bodyType == EMMessageBodyTypeImage || m.bodyType == EMMessageBodyTypeVideo {
                if height == 18 {
                    height = 140
                }else{
                    height += 140
                }
            }
            if m.bodyType == EMMessageBodyTypeLocation {
                if height == 18 {
                    height = 95
                }else{
                    height += 95
                }
            }
            if m.bodyType == EMMessageBodyTypeFile {
                if height == 18 {
                    height = 86
                }else{
                    height += 86
                }
            }
        }
        if model.messageList![0].isSender {
            if height < 60 {
                height = 60
            }
        }else{
            if model.messageList![0].messageType == EMChatTypeGroupChat {
                if height < 77 {
                    height = 77
                }
            }else{
                if height < 60 {
                    height = 60
                }
            }
        }
        return height
    }
    
    static func cellID() -> String {
        return "DIYMessage"
    }

}
