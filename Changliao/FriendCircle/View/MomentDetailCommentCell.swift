//
//  MomentDetailCommentCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit
import HandyJSON

class MomentDetailCommentCell: UICollectionViewCell,UIGestureRecognizerDelegate {
    /// 背景
    lazy var bk: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "F3F3F4")
        v.isUserInteractionEnabled = true
        return v
    }()
    lazy var comment:UILabel = {
        let l = UILabel()
        l.textColor = UIColor.hexadecimalColor(hexadecimal: "#6F7EA3")
        l.font = DCUtill.FONTX(14)
        l.numberOfLines = 0
        return l
    }()
    
    var model:HandyJSON? {
        didSet {
            setModel()
        }
    }
    
    var ownerID:String?
    
    var delegate:MomentRefreshDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(g:)))
        tap.delegate = self
        bk.addGestureRecognizer(tap)
        let loop = UILongPressGestureRecognizer(target: self, action: #selector(onTap(g:)))
        loop.minimumPressDuration = 0.5
        loop.delegate = self
        bk.addGestureRecognizer(loop)
        self.contentView.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.top.bottom()?.offset()(0)
        }
        bk.addSubview(comment)
        comment.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(11))
            make?.top.offset()(DCUtill.SCRATIOX(5))
            make?.bottom.offset()(DCUtill.SCRATIOX(-5))
            make?.right.mas_lessThanOrEqualTo()(DCUtill.SCRATIOX(-11))
        }
    }
    private func setModel() {
        if let m = model as? CommentData {
            let attr = NSMutableAttributedString(string: "\(m.friend_name ?? ""):\(m.comment ?? "")")
            attr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attr.string.count))
            attr.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: 0, length: m.friend_name?.count ?? 0))
            comment.attributedText = attr
        }
        if let m = model as? CommentReplyData {
            let attr = NSMutableAttributedString(string: "\(m.friend_name ?? "") 回复 \(m.reply_name ?? ""):\(m.comment ?? "")")
            attr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attr.string.count))
            attr.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: 0, length: m.friend_name?.count ?? 0))
            attr.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: (m.friend_name?.count ?? 0) + 4, length: m.reply_name?.count ?? 0))
            comment.attributedText = attr
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func onTap(g:UIGestureRecognizer) {
        if g is UITapGestureRecognizer {
            if g.state == .ended {
                if let mm = self.model as? CommentData {
                    if mm.user_id == EMClient.shared()?.currentUsername {
                        UIApplication.shared.keyWindow?.makeToast("不能回复自己")
                        return
                    }
                    MomentCommentView({ (text) in
                        if let t = text {
                            if t.isEmpty {
                                return
                            }
                            self.publishComment(t)
                        }
                        }, plat: mm.friend_name).show()
                }else if let mm = self.model as? CommentReplyData {
                    if mm.user_id == EMClient.shared()?.currentUsername {
                        UIApplication.shared.keyWindow?.makeToast("不能回复自己")
                        return
                    }
                    MomentCommentView({ (text) in
                        if let t = text {
                            if t.isEmpty {
                                return
                            }
                            self.publishComment(t)
                        }
                        }, plat: mm.friend_name).show()
                }else {
                    return
                }
            }
        }
        if g is UILongPressGestureRecognizer {
            if g.state == .began {
                if let m = model as? CommentData {
                    if ownerID == EMClient.shared()?.currentUsername || m.user_id == EMClient.shared()?.currentUsername {
                        let alert = UIAlertController(title: "你确定要删除这条评论吗", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (a) in
                            self.deleteComment(id: m.comments_id)
                        }))
                        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                        UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                    }
                }else if let m = model as? CommentReplyData {
                    if ownerID == EMClient.shared()?.currentUsername || m.user_id == EMClient.shared()?.currentUsername {
                        let alert = UIAlertController(title: "你确定要删除这条回复吗", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (a) in
                            self.deleteReply(id: m.reply_id)
                        }))
                        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                        UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func publishComment(_ text:String) {
        DispatchQueue.global().async {
            let m = ReplyCommentSendModel()
            if let mm = self.model as? CommentData {
                m.comment_id = mm.comments_id
            }else if let mm = self.model as? CommentReplyData {
                m.comment_id = mm.comment_id
                m.to_reply_id = mm.reply_id
            }else {
                return
            }
            m.content = text
            BoXinProvider.request(.ReplyCpmment(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                self.delegate?.needReload()
                            }else{
                                UIViewController.currentViewController()?.view.makeToast(mo.message)
                            }
                        }else{
                            UIViewController.currentViewController()?.view.makeToast("数据格式错误")
                        }
                    }else{
                        UIViewController.currentViewController()?.view.makeToast("链接服务器错误")
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
    
    func deleteComment(id:String?) {
        DispatchQueue.global().async {
            let m = DeleteMomentCommentSendModel()
            m.comments_id = id
            BoXinProvider.request(.DeleteMomentComment(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                self.delegate?.needReload()
                            }else{
                                UIViewController.currentViewController()?.view.makeToast(mo.message)
                            }
                        }else{
                            UIViewController.currentViewController()?.view.makeToast("数据格式错误")
                        }
                    }else{
                        UIViewController.currentViewController()?.view.makeToast("链接服务器错误")
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
    
    func deleteReply(id:String?) {
        DispatchQueue.global().async {
            let m = DeleteMomentReplySendModel()
            m.reply_id = id
            BoXinProvider.request(.DeleteMomentReply(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                self.delegate?.needReload()
                            }else{
                                UIViewController.currentViewController()?.view.makeToast(mo.message)
                            }
                        }else{
                            UIViewController.currentViewController()?.view.makeToast("数据格式错误")
                        }
                    }else{
                        UIViewController.currentViewController()?.view.makeToast("链接服务器错误")
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
}
