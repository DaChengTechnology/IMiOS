//
//  MomentLikeCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/10/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

/// 朋友圈喜欢cell
class MomentLikeCell: UICollectionViewCell {
    /// 背景
    lazy var bk: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "F3F3F4")
        v.isUserInteractionEnabled = true
        return v
    }()
    /// 图标
    lazy var likeIV = UIImageView(image: UIImage(named: "FCLikeShow"))
    /// 文字信息
    lazy var likeLabel: UILabel = {
        let l = UILabel()
        l.font = DCUtill.FONTX(16)
        l.textColor = UIColor.hexadecimalColor(hexadecimal: "#6F7EA3")
        l.numberOfLines = 0
        return l
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
        bk.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(g:))))
        self.contentView.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.top.bottom()?.offset()(0)
        }
        bk.addSubview(likeIV)
        likeIV.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(11))
            make?.top.offset()(DCUtill.SCRATIOX(15))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(20))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(17))
        }
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#E2E2E2")
        bk.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0);
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
        bk.addSubview(likeLabel)
        likeLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(likeIV.mas_right)?.offset()(DCUtill.SCRATIOX(11))
            make?.top.offset()(DCUtill.SCRATIOX(13))
            make?.right.mas_lessThanOrEqualTo()(DCUtill.SCRATIOX(-11))
            make?.bottom.equalTo()(line.mas_top)?.offset()(DCUtill.SCRATIOX(-13))
        }
    }
    private func setModel() {
        var names = [String]()
        guard let likes = model?.likeList else {
            return
        }
        for l in likes {
            if let n = l?.friend_name {
                names.append(n)
            }
        }
        likeLabel.text = names.joined(separator: "、")
    }
    
    private func setData() {
        var names = [String]()
        guard let likes = data?.likeList else {
            return
        }
        for l in likes {
            if let n = l?.friend_name {
                names.append(n)
            }
        }
        likeLabel.text = names.joined(separator: "、")
    }
    
    @objc func onTap(g:UIGestureRecognizer) {
        if g.state == .ended {
            if model != nil {
                let vc = MomentDetailViewController()
                vc.circle_id = model?.circle_id
                self.vc?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.vc?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    static func cellForSize(m:FriendCircleData?) -> CGSize {
        var names = [String]()
        guard let likes = m?.likeList else {
            return .zero
        }
        for l in likes {
            if let n = l?.friend_name {
                names.append(n)
            }
        }
        return CGSize(width: UIScreen.main.bounds.width, height: DCUtill.ga_heightForComment(str: names.joined(separator: "、"), fontSize: DCUtill.SCRATIOX(16), width: UIScreen.main.bounds.width - DCUtill.SCRATIOX(75+16+53)) + DCUtill.SCRATIOX(5))
    }
}
