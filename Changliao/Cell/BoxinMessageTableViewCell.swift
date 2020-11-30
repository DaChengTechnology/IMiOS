//
//  SendTextTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/11/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

/// 弃用消息cell
@available(*,deprecated)
class BoxinMessageTableViewCell: EaseMessageCell {
    var headImageView:UIImageView?
    var messageBkImageView:UIImageView?
    var timeLable:UILabel?
    var hasReadImageView:UIImageView?
    var messageLabel:UILabel?
    var messageImageView:UIImageView?
    var vedioPlayImageView:UIImageView?
    var tapMessageView:UIView?
    var nickNameLabel:UILabel?
    var timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var playIndex:Int = 1
    
    
    static func cellIdentifier(withModel model: Any!) -> String! {
        let m = model as! IMessageModel
        switch m.bodyType {
        case EMMessageBodyTypeText:
            return "boxinTextChatCell"
        case EMMessageBodyTypeVoice:
            return "boxinVoiceChatCell"
        case EMMessageBodyTypeImage:
            return "boxinImageChatCell"
        case EMMessageBodyTypeLocation:
            return "boxinLocationChatCell"
        default:
            return "boxinChatCell"
        }
        return "boxinChatCell"
    }
    
    static func cellHeight(withModel model: Any!) -> CGFloat {
        if let m = (model as? IMessageModel) {
            switch m.bodyType {
            case EMMessageBodyTypeText:
                let height = m.text.boundingRect(with: CGSize(width: 190, height: 10000), font: UIFont.systemFont(ofSize: 16)).height + 50
                if height < 64 {
                    return 64
                }
                return height
            case EMMessageBodyTypeImage:
                return UITableView.automaticDimension
            case EMMessageBodyTypeVoice:
                return UITableView.automaticDimension
            case EMMessageBodyTypeLocation:
                return UITableView.automaticDimension
            default:
                return 64
            }
        }
        return 64
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
    }
    
    required init!(style: UITableViewCell.CellStyle, reuseIdentifier: String!, model: IMessageModel!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, model: model)
        self.model = model
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        setup()
    }
    override func isCustomBubbleView(_ model: Any!) -> Bool {
        return true
    }
    
    func setup() {
        if let m = model as? IMessageModel {
            DispatchQueue.main.async {
                if m.isSender {
                    self.initSendMessage(mod: m)
                }else{
                    self.initReciveMessage(mod: m)
                }
            }
        }
    }
    
    @objc func onClickHead(g:UIGestureRecognizer){
        if g.state == .ended {
            delegate?.avatarViewSelcted?((model as! IMessageModel))
        }
    }
    
    @objc func onClickMessaage(g:UIGestureRecognizer){
        if g.state == .ended {
            delegate?.messageCellSelected?((model as! IMessageModel))
        }
    }
    
    func initSendMessage(mod: IMessageModel) {
        switch mod.bodyType {
        case EMMessageBodyTypeText:
            sendText(mod: mod)
        case EMMessageBodyTypeImage:
            sendImage(mod: mod)
        case EMMessageBodyTypeLocation:
            sendLocation(mod: mod)
        case EMMessageBodyTypeVoice:
            sendVoise(mod: mod)
        default:
            break
        }
    }
    
    func initReciveMessage(mod: IMessageModel) {
        switch mod.bodyType {
        case EMMessageBodyTypeText:
            reciveText(mod: mod)
        case EMMessageBodyTypeImage:
            ReciveImage(mod: mod)
        case EMMessageBodyTypeLocation:
            reciveLocation(mod: mod)
        case EMMessageBodyTypeVoice:
            reciveVoise(mod: mod)
        default:
            break
        }
    }
    
    func sendText(mod:IMessageModel) {
        DispatchQueue.main.async {
            self.headImageView = UIImageView(image: UIImage(named: "moren"))
            self.headImageView?.contentMode = .scaleAspectFill
            self.contentView.addSubview(self.headImageView!)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickHead(g:)))
            self.headImageView?.isUserInteractionEnabled = true
            self.headImageView?.addGestureRecognizer(tap)
            self.headImageView?.layer.masksToBounds = true
            self.headImageView?.layer.cornerRadius = 22.5
            self.headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
            self.nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            self.nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
            self.nickNameLabel?.text = mod.nickname
            self.nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
            self.contentView.addSubview(self.nickNameLabel!)
            self.messageBkImageView = UIImageView(image: UIImage(named: "气泡发送")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 17), resizingMode: .stretch))
            self.messageBkImageView?.contentMode = .scaleToFill
            if mod.isMessageRead {
                self.hasReadImageView?.image = UIImage(named: "已读1")
            }
            self.contentView.addSubview(self.messageBkImageView!)
            self.hasReadImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            self.messageBkImageView?.addSubview(self.hasReadImageView!)
            self.timeLable = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
            self.timeLable?.font = UIFont.systemFont(ofSize: 8)
            self.timeLable?.textColor = UIColor.white
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            self.timeLable?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(mod.message!.localTime)))
            self.messageBkImageView?.addSubview(self.timeLable!)
            self.messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
            self.messageLabel?.font = UIFont.systemFont(ofSize: 16)
            self.messageLabel?.text = mod.text
            self.messageLabel?.numberOfLines = 0
            self.messageLabel?.preferredMaxLayoutWidth = 190
            self.messageLabel?.lineBreakMode = .byWordWrapping
            self.messageBkImageView?.addSubview(self.messageLabel!)
            self.tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.tapMessageView?.backgroundColor = UIColor.clear
            self.tapMessageView?.isUserInteractionEnabled = true
            self.messageBkImageView?.isUserInteractionEnabled = true
            let tapMessage = UITapGestureRecognizer(target: self, action: #selector(self.onClickMessaage(g:)))
            self.tapMessageView?.addGestureRecognizer(tapMessage)
            self.headImageView?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
                make?.right.equalTo()(self.contentView.mas_right)?.offset()(-16)
                make?.height.mas_equalTo()(45)
                make?.width.mas_equalTo()(45)
            })
            self.nickNameLabel?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
                make?.right.equalTo()(self.headImageView?.mas_left)?.offset()(-14)
            })
            self.messageBkImageView?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.headImageView?.mas_left)?.offset()(-4)
                make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
                make?.top.equalTo()(self.nickNameLabel?.mas_bottom)?.offset()(2)
            })
            self.hasReadImageView?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.messageBkImageView?.mas_right)?.offset()(-17)
                make?.bottom.equalTo()(self.messageBkImageView?.mas_bottom)?.offset()(-6)
                make?.height.mas_equalTo()(5)
                make?.width.mas_equalTo()(10)
            })
            self.timeLable?.mas_makeConstraints({ (make) in
                make?.right.equalTo()(self.hasReadImageView?.mas_left)?.equalTo()(-3)
                make?.bottom.equalTo()(self.messageBkImageView?.mas_bottom)?.offset()(-6)
            })
            self.messageLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self.messageBkImageView?.mas_left)?.offset()(10)
                make?.right.equalTo()(self.timeLable?.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(self.messageBkImageView?.mas_bottom)?.offset()(-6)
                make?.top.equalTo()(self.messageBkImageView?.mas_top)?.offset()(6)
            })
            self.messageBkImageView?.addSubview(self.tapMessageView!)
            self.tapMessageView?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self.messageBkImageView?.mas_left)
                make?.right.equalTo()(self.messageBkImageView?.mas_right)
                make?.top.equalTo()(self.messageBkImageView?.mas_top)
                make?.bottom.equalTo()(self.messageBkImageView?.mas_bottom)
            })
        }
    }
    
    func reciveText(mod:IMessageModel) {
        headImageView = UIImageView(image: mod.avatarImage)
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.left.equalTo()(self.contentView.mas_left)?.offset()(16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        nickNameLabel?.textColor = UIColor.gray
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(14)
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 10), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        timeLable = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
        timeLable?.font = UIFont.systemFont(ofSize: 7)
        timeLable?.textColor = UIColor.white
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timeLable?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(mod.message!.localTime)))
        messageBkImageView?.addSubview(timeLable!)
        timeLable?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-10)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
        })
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
        messageLabel?.font = UIFont.systemFont(ofSize: 16)
        messageLabel?.preferredMaxLayoutWidth = 190
        messageLabel?.numberOfLines = 0
        messageLabel?.text = mod.text
        messageBkImageView?.addSubview(messageLabel!)
        messageLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(17)
            make?.right.equalTo()(timeLable?.mas_left)?.offset()(-7)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
        })
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func sendImage(mod:IMessageModel) {
        headImageView = UIImageView(image: UIImage(named: "moren"))
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        headImageView?.addGestureRecognizer(tap)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.right.equalTo()(self.contentView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.adjustsFontForContentSizeCategory = true
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-14)
            make?.height.mas_equalTo()(14)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡发送")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 17), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        messageImageView = UIImageView(image: mod.image)
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(10)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-17)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.height.mas_equalTo()(120)
            make?.width.mas_equalTo()(120)
        })
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func ReciveImage(mod:IMessageModel) {
        headImageView = UIImageView(image: mod.avatarImage)
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.left.equalTo()(self.contentView.mas_left)?.offset()(16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        nickNameLabel?.textColor = UIColor.gray
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(14)
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
            make?.height.mas_equalTo()(14)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 10), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        messageImageView = UIImageView(image: mod.thumbnailImage)
        messageImageView?.sd_setImage(with: URL(string: mod.thumbnailFileURLPath), placeholderImage: mod.thumbnailImage)
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(17)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-10)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.width.mas_equalTo()(120)
            make?.height.mas_equalTo()(mod.imageSize.height / mod.imageSize.width * 120)
        })
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func sendLocation(mod:IMessageModel) {
        headImageView = UIImageView(image: UIImage(named: "moren"))
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.right.equalTo()(self.contentView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-14)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡发送")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 17), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        messageImageView = UIImageView(image: UIImage(named: "EaseUIResource/chat_location_preview"))
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(10)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-17)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.height.mas_equalTo()(60)
            make?.width.mas_equalTo()(80)
        })
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func reciveLocation(mod:IMessageModel) {
        headImageView = UIImageView(image: mod.avatarImage)
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.left.equalTo()(self.contentView.mas_left)?.offset()(16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        nickNameLabel?.textColor = UIColor.gray
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(14)
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
            make?.height.mas_equalTo()(14)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 10), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        messageImageView = UIImageView(image: UIImage(named: "EaseUIResource/chat_location_preview"))
        messageImageView?.sd_setImage(with: URL(string: mod.thumbnailFileURLPath), placeholderImage: mod.thumbnailImage)
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(17)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-10)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.width.mas_equalTo()(120)
            make?.height.mas_equalTo()(mod.imageSize.height / mod.imageSize.width * 120)
        })
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func sendVoise(mod:IMessageModel) {
        headImageView = UIImageView(image: UIImage(named: "moren"))
        headImageView?.contentMode = .scaleAspectFill
        self.contentView.addSubview(headImageView!)
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.right.equalTo()(self.contentView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-14)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡发送")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 17), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(headImageView?.mas_left)?.offset()(-4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        hasReadImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        messageBkImageView?.addSubview(hasReadImageView!)
        hasReadImageView?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-17)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.height.mas_equalTo()(5)
            make?.width.mas_equalTo()(10)
        })
        if mod.isMessageRead {
            hasReadImageView?.image = UIImage(named: "已读1")
        }
        timeLable = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
        timeLable?.font = UIFont.systemFont(ofSize: 8)
        timeLable?.textColor = UIColor.white
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timeLable?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(mod.message!.localTime)))
        messageBkImageView?.addSubview(timeLable!)
        timeLable?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(hasReadImageView?.mas_left)?.equalTo()(-3)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
        })
        messageImageView = UIImageView(image: UIImage(named: "voise_3"))
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(40)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(timeLable?.mas_left)?.offset()(-7)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.height.mas_equalTo()(14.5)
            make?.width.mas_equalTo()(14.5)
        })
        let md = mod as! EaseMessageModel
        md.addObserver(self, forKeyPath: "isMediaPlaying", options: [.new,.old], context: nil)
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    func reciveVoise(mod:IMessageModel) {
        headImageView = UIImageView(image: mod.avatarImage)
        headImageView?.contentMode = .scaleAspectFill
        headImageView?.layer.masksToBounds = true
        headImageView?.layer.cornerRadius = 22.5
        self.contentView.addSubview(headImageView!)
        headImageView?.sd_setImage(with: URL(string: mod.avatarURLPath), placeholderImage: mod.avatarImage)
        headImageView?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(10.5)
            make?.left.equalTo()(self.contentView.mas_left)?.offset()(16)
            make?.height.mas_equalTo()(45)
            make?.width.mas_equalTo()(45)
        })
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickHead(g:)))
        headImageView?.isUserInteractionEnabled = true
        headImageView?.addGestureRecognizer(tap)
        nickNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        nickNameLabel?.font = UIFont.systemFont(ofSize: 12)
        nickNameLabel?.textColor = UIColor.gray
        nickNameLabel?.text = mod.nickname
        nickNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "616160")
        self.contentView.addSubview(nickNameLabel!)
        nickNameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(14)
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(8)
        })
        messageBkImageView = UIImageView(image: UIImage(named: "气泡")?.resizableImage(withCapInsets: UIEdgeInsets(top: 6, left: 17, bottom: 6, right: 10), resizingMode: .stretch))
        messageBkImageView?.contentMode = .scaleToFill
        self.contentView.addSubview(messageBkImageView!)
        messageBkImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(headImageView?.mas_right)?.offset()(4)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-10.5)
            make?.top.equalTo()(nickNameLabel?.mas_bottom)?.offset()(2)
        })
        timeLable = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 5))
        timeLable?.font = UIFont.systemFont(ofSize: 7)
        timeLable?.textColor = UIColor.white
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timeLable?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(mod.message!.localTime)))
        messageBkImageView?.addSubview(timeLable!)
        timeLable?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(messageBkImageView?.mas_right)?.offset()(-10)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
        })
        messageImageView = UIImageView(image: UIImage(named: "recive_voise_3"))
        messageBkImageView?.addSubview(messageImageView!)
        messageImageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)?.offset()(17)
            make?.top.equalTo()(messageBkImageView?.mas_top)?.offset()(6)
            make?.right.equalTo()(timeLable?.mas_left)?.offset()(-7)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)?.offset()(-6)
            make?.width.mas_equalTo()(14.5)
            make?.height.mas_equalTo()(14.5)
        })
        let md = mod as! EaseMessageModel
        md.addObserver(self, forKeyPath: "isMediaPlaying", options: [.new,.old], context: nil)
        tapMessageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tapMessageView?.backgroundColor = UIColor.clear
        tapMessageView?.isUserInteractionEnabled = true
        messageBkImageView?.isUserInteractionEnabled = true
        let tapMessage = UITapGestureRecognizer(target: self, action: #selector(onClickMessaage(g:)))
        tapMessageView?.addGestureRecognizer(tapMessage)
        messageBkImageView?.addSubview(tapMessageView!)
        tapMessageView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(messageBkImageView?.mas_left)
            make?.right.equalTo()(messageBkImageView?.mas_right)
            make?.top.equalTo()(messageBkImageView?.mas_top)
            make?.bottom.equalTo()(messageBkImageView?.mas_bottom)
        })
    }
    
    @objc func onPlayStateDidChange(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let md = model as! IMessageModel
        if md.isMediaPlayed {
            timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timer.schedule(deadline: DispatchTime.now(), repeating: 0.5)
            timer.setEventHandler {
                if md.isSender {
                    self.messageImageView?.image = UIImage(named: String(format: "voise_%d", self.playIndex))
                }else{
                    self.messageImageView?.image = UIImage(named: String(format: "recive_voise_%d", self.playIndex))
                }
                self.playIndex += 1
                if self.playIndex == 4 {
                    self.playIndex = 1
                }
            }
            timer.resume()
        }else{
            timer.cancel()
            if md.isSender {
                self.messageImageView?.image = UIImage(named: "voise_3")
            }else{
                self.messageImageView?.image = UIImage(named: "recive_voise_3")
            }
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setCustomBubbleView(_ model: Any!) {
        
    }
    
    override func setCustomModel(_ model: Any!) {
        setup()
    }
    
    override func updateCustomBubbleViewMargin(_ bubbleMargin: UIEdgeInsets, model mode: Any!) {
        
    }
    
}
