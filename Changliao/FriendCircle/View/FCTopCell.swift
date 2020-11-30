//
//  FCTopCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/9/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

private let topOffset: CGFloat = 60
private let bottomIndent: CGFloat = DCUtill.SCRATIOX(24)
private let avatorW: CGFloat = DCUtill.SCRATIOX(76)
private let space: CGFloat = 20
class FCTopCell: UICollectionViewCell {
    
    /// 朋友圈背景图
    fileprivate lazy var headIV: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bounds.height - bottomIndent)
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    /// 用户头像
    fileprivate lazy var avatarIV: UIImageView = {
        let iv = UIImageView()
        iv.frame =  CGRect(x: UIScreen.main.bounds.width - avatorW - 16, y: headIV.frame.maxY, width: avatorW, height: avatorW)
        iv.layer.cornerRadius = DCUtill.SCRATIOX(38)
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    var isMine:Bool = false
    weak var vc:UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.contentView.addSubview(headIV)
        headIV.mas_makeConstraints { (make) in
            make?.left.right()?.offset()(0)
            make?.bottom.offset()(DCUtill.SCRATIOX(-10))
            make?.width.height().mas_equalTo()(UIScreen.main.bounds.width)
            make?.top.offset()(DCUtill.SCRATIOX(-130))
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToMine(g:)))
        avatarIV.addGestureRecognizer(tap)
        self.contentView.addSubview(avatarIV)
        avatarIV.mas_makeConstraints { (make) in
            make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(76))
            make?.bottom.equalTo()(headIV)?.offset()(DCUtill.SCRATIOX(24))
            make?.right.equalTo()(headIV)?.offset()(DCUtill.SCRATIOX(-16))
        }
    }
    
    /// 设置头像
    /// - Parameter url: 头像url
    func setHead(url:String) {
        avatarIV.sd_setImage(with: URL(string: url), completed: nil)
    }
    
    /// 设置朋友圈背景
    /// - Parameter url: 背景url
    func setBK(url:String) {
        headIV.sd_setImage(with: URL(string: url), completed: nil)
    }
    
    @objc func goToMine(g:UIGestureRecognizer) {
        if g.state == .ended {
            if isMine {
                let vc = PersonalMomentViewController()
                if let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")) {
                    vc.userid = model.db?.user_id
                    vc.headURL = model.db?.portrait
                }
                self.vc?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.vc?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    static func cellForSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width - DCUtill.SCRATIOX(120))
    }
}
