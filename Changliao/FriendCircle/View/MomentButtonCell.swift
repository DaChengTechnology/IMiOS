//
//  MomentButtonCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/10/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

protocol MomentRefreshDelegate {
    func needRefresh(momentId:String?)
    func needReload()
}

extension MomentRefreshDelegate {
    func needReload() {
        
    }
}

/// 朋友圈底部cell
class MomentButtonCell: UICollectionViewCell {
    /// 朋友圈时间
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: DCUtill.SCRATIOX(75), y: DCUtill.SCRATIOX(15), width: DCUtill.SCRATIOX(200), height: DCUtill.SCRATIOX(30)))
        label.font = DCUtill.FONTX(14)
        label.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
        return label
    }()
    /// 更多按钮
    lazy var moreBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "FCMore"), for: .normal)
        return btn
    }()
    var model:FriendCircleData? {
        didSet{
            setModel()
        }
    }
    var data:MomentDetailData? {
        didSet{
            setData()
        }
    }
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
        self.contentView.addSubview(timeLabel)
        moreBtn.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        self.contentView.addSubview(moreBtn)
        moreBtn.mas_makeConstraints { (make) in
            make?.top.offset()(DCUtill.SCRATIOX(14))
            make?.right.offset()(DCUtill.SCRATIOX(-22))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(36))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(22))
            make?.bottom.offset()(DCUtill.SCRATIOX(-14))
        }
    }
    @objc func onMore() {
        if model != nil {
            let v = MomentLikeView(moreBtn, { (index) in
                if index == 1 {
                    self.like()
                }else if index == 2 {
                    self.unlike()
                }else if index == 3 {
                    self.comment()
                }
            }, (model?.likeList?.contains(where: { (l) -> Bool in
                if l?.user_id == EMClient.shared()?.currentUsername {
                    return true
                }
                return false
            }) ?? false))
            v.show()
        }else if data != nil {
            let v = MomentLikeView(moreBtn, { (index) in
                if index == 1 {
                    self.like()
                }else if index == 2 {
                    self.unlike()
                }else if index == 3 {
                    self.comment()
                }
            }, (data?.likeList?.contains(where: { (l) -> Bool in
                if l?.user_id == EMClient.shared()?.currentUsername {
                    return true
                }
                return false
            }) ?? false))
            v.show()
        }
    }
    
    private func setModel() {
        timeLabel.text = model?.create_time
    }
    
    private func setData() {
        timeLabel.text = data?.create_time
    }
    
    func like() {
        DispatchQueue.global().async {
            let m = MomentSendModel()
            if self.model != nil {
                m.circle_id = self.model?.circle_id
            }else{
                m.circle_id = self.data?.circle_id
            }
            BoXinProvider.request(.GiveLike(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                let data = LikeData()
                                data.friend_name = "您"
                                data.user_id = EMClient.shared()?.currentUsername
                                if self.model != nil {
                                    if self.model?.likeList == nil {
                                        self.model?.likeList = [data]
                                    }else{
                                        self.model?.likeList?.append(data)
                                    }
                                }else{
                                    if self.data?.likeList == nil {
                                        self.data?.likeList = [data]
                                    }else{
                                        self.data?.likeList?.append(data)
                                    }
                                }
                                self.delegate?.needRefresh(momentId: m.circle_id)
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
    
    func unlike() {
        DispatchQueue.global().async {
            let m = MomentSendModel()
            if self.model != nil {
                m.circle_id = self.model?.circle_id
            }else{
                m.circle_id = self.data?.circle_id
            }
            BoXinProvider.request(.CancelLike(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                if self.model != nil {
                                    self.model?.likeList = self.model?.likeList?.filter({ (l) -> Bool in
                                        if l?.user_id == EMClient.shared()?.currentUsername {
                                            return false
                                        }
                                        return true
                                    })
                                }else{
                                    self.data?.likeList = self.data?.likeList?.filter({ (l) -> Bool in
                                        if l?.user_id == EMClient.shared()?.currentUsername {
                                            return false
                                        }
                                        return true
                                    })
                                }
                                self.delegate?.needRefresh(momentId: m.circle_id)
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
    
    func comment() {
        MomentCommentView({ (text) in
            if let t = text {
                if t.isEmpty {
                    return
                }
                self.publishComment(t)
            }
            }, plat: nil).show()
    }
    
    func publishComment(_ text:String) {
        DispatchQueue.global().async {
            let m = DoCommentSendModel()
            if self.model != nil {
                m.circle_id = self.model?.circle_id
            }else{
                m.circle_id = self.data?.circle_id
            }
            m.content = text
            BoXinProvider.request(.DoComment(model: m),callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if mo.code == 200 {
                                let data = CommentData()
                                data.friend_name = "您"
                                data.user_id = EMClient.shared()?.currentUsername
                                data.comment = m.content
                                if self.model != nil {
                                    if self.model?.commentsList == nil {
                                        self.model?.commentsList = [data]
                                    }else{
                                        self.model?.commentsList?.append(data)
                                    }
                                }else{
                                    if self.data?.likeList == nil {
                                        self.data?.commentsList = [data]
                                    }else{
                                        self.data?.commentsList?.append(data)
                                    }
                                }
                                self.delegate?.needRefresh(momentId: m.circle_id)
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
    
    static func cellForSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: DCUtill.SCRATIOX(50))
    }
}
