//
//  MomentHeaderCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/9/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

/// 朋友圈cell
class MomentHeaderCell: UICollectionViewCell {
    /// 边距
    static let padding: CGFloat = DCUtill.SCRATIOX(16)
    /// 文字左边距
    static let contentLeft = padding+DCUtill.SCRATIOX(47+12)
    /// 文字最大宽度
    static let contentW = UIScreen.main.bounds.width-padding-contentLeft
    /// 头像
    fileprivate lazy var avatarIV: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: MomentHeaderCell.padding, y: 0, width: 50, height: 50)
        iv.layer.cornerRadius = DCUtill.SCRATIOX(23.5)
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    /// 用户名
    fileprivate lazy var usernameLb: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: avatarIV.frame.maxX+10, y: 2, width: MomentHeaderCell.contentW, height: 20)
        lb.textColor = UIColor.black
        lb.font = DCUtill.FONTX(18)
        lb.isUserInteractionEnabled = true
        return lb
    }()
    /// 文字
    fileprivate lazy var conentLb: UILabel = {
        let lb = UILabel()
        lb.frame = CGRect(x: usernameLb.frame.minX, y: usernameLb.frame.maxY, width: MomentHeaderCell.contentW, height: 0)
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.numberOfLines = 0
        lb.isUserInteractionEnabled = true
        return lb
    }()
    /// 九宫格图片展示
    lazy var nineImageView: NineImageView = {
        let view = NineImageView(frame: .zero)
        view.frame = conentLb.frame
        view.frame.size.width -= 50
        return view
    }()
    
    var model:FriendCircleData? {
        didSet {
            setModel()
        }
    }
    
    var data:MomentDetailData? {
        didSet {
            setData()
        }
    }
    
    weak var vc:UIViewController? {
        didSet{
            nineImageView.vc = self.vc
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var images = [String]()
        if model != nil {
            if let pic1 = model?.pic1 {
                images.append(pic1)
            }
            if let pic1 = model?.pic2 {
                images.append(pic1)
            }
            if let pic1 = model?.pic3 {
                images.append(pic1)
            }
            if let pic1 = model?.pic4 {
                images.append(pic1)
            }
            if let pic1 = model?.pic5 {
                images.append(pic1)
            }
            if let pic1 = model?.pic6 {
                images.append(pic1)
            }
            if let pic1 = model?.pic7 {
                images.append(pic1)
            }
            if let pic1 = model?.pic8 {
                images.append(pic1)
            }
            if let pic1 = model?.pic9 {
                images.append(pic1)
            }
        }else{
            if let pic1 = data?.pic1 {
                images.append(pic1)
            }
            if let pic1 = data?.pic2 {
                images.append(pic1)
            }
            if let pic1 = data?.pic3 {
                images.append(pic1)
            }
            if let pic1 = data?.pic4 {
                images.append(pic1)
            }
            if let pic1 = data?.pic5 {
                images.append(pic1)
            }
            if let pic1 = data?.pic6 {
                images.append(pic1)
            }
            if let pic1 = data?.pic7 {
                images.append(pic1)
            }
            if let pic1 = data?.pic8 {
                images.append(pic1)
            }
            if let pic1 = data?.pic9 {
                images.append(pic1)
            }
        }
        switch images.count {
        case 0:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(0)
                make?.width.mas_equalTo()(0)
            }
        return
        case 1,4:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(203))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(203))
            }
        case 2:
            if images[0].hasSuffix(".mp4") {
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
                }
                return
            }else{
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(102))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(210))
                }
            }
        case 3:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(90))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        case 5,6:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(180))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(280))
            }
        default:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        }
        nineImageView.images = images
        self.layoutIfNeeded()
    }
    
    func setup() {
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(onGotoPersonal(g:)))
        avatarIV.addGestureRecognizer(headerTap)
        self.contentView.addSubview(avatarIV)
        avatarIV.mas_makeConstraints { (make) in
            make?.top.offset()(DCUtill.SCRATIOX(22))
            make?.left.offset()(DCUtill.SCRATIOX(16))
            make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(47))
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(onGotoDetail(g:)))
        usernameLb.addGestureRecognizer(tap)
        self.contentView.addSubview(usernameLb)
        usernameLb.mas_makeConstraints { (make) in
            make?.top.equalTo()(avatarIV)
            make?.left.equalTo()(avatarIV.mas_right)?.offset()(DCUtill.SCRATIOX(12))
        }
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(onGotoDetail(g:)))
        conentLb.addGestureRecognizer(tap1)
        self.contentView.addSubview(conentLb)
        conentLb.mas_makeConstraints { (make) in
            make?.left.equalTo()(avatarIV.mas_right)?.offset()(DCUtill.SCRATIOX(12))
            make?.top.equalTo()(usernameLb.mas_bottom)?.offset()(DCUtill.SCRATIOX(10))
            make?.right.lessThanOrEqualTo()(self.contentView)?.offset()(-MomentHeaderCell.padding)
            make?.width.mas_lessThanOrEqualTo()(MomentHeaderCell.contentW)
        }
        self.contentView.addSubview(nineImageView)
        nineImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(conentLb)
            make?.top.equalTo()(conentLb.mas_bottom)?.offset()(DCUtill.SCRATIOX(10))
            make?.height.width().mas_equalTo()(0)
            make?.bottom.offset()(0)
        }
    }
    
    private func setModel() {
        if let a = model?.portrait {
            avatarIV.sd_setImage(with: URL(string: a), completed: nil)
        }
        usernameLb.text = model?.user_name
        conentLb.text = model?.content
        var images = [String]()
        if let pic1 = model?.pic1 {
            images.append(pic1)
        }
        if let pic1 = model?.pic2 {
            images.append(pic1)
        }
        if let pic1 = model?.pic3 {
            images.append(pic1)
        }
        if let pic1 = model?.pic4 {
            images.append(pic1)
        }
        if let pic1 = model?.pic5 {
            images.append(pic1)
        }
        if let pic1 = model?.pic6 {
            images.append(pic1)
        }
        if let pic1 = model?.pic7 {
            images.append(pic1)
        }
        if let pic1 = model?.pic8 {
            images.append(pic1)
        }
        if let pic1 = model?.pic9 {
            images.append(pic1)
        }
        switch images.count {
        case 0:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(0)
                make?.width.mas_equalTo()(0)
            }
        case 1,4:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(203))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(203))
            }
        case 2:
            if images[0].hasSuffix(".mp4") {
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
                }
            }else{
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(102))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(210))
                }
            }
        case 3:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(90))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        case 5,6:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(180))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(280))
            }
        default:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        }
        DispatchQueue.main.async {
            self.nineImageView.images = images
        }
    }
    
    func setData() {
        if let a = data?.circleUser?.portrait {
            avatarIV.sd_setImage(with: URL(string: "\(data?.ossfileprefixurl ?? "")\(a)"), completed: nil)
        }
        usernameLb.text = data?.circleUser?.user_name
        conentLb.text = data?.content
        var images = [String]()
        if let pic1 = data?.pic1 {
            images.append(pic1)
        }
        if let pic1 = data?.pic2 {
            images.append(pic1)
        }
        if let pic1 = data?.pic3 {
            images.append(pic1)
        }
        if let pic1 = data?.pic4 {
            images.append(pic1)
        }
        if let pic1 = data?.pic5 {
            images.append(pic1)
        }
        if let pic1 = data?.pic6 {
            images.append(pic1)
        }
        if let pic1 = data?.pic7 {
            images.append(pic1)
        }
        if let pic1 = data?.pic8 {
            images.append(pic1)
        }
        if let pic1 = data?.pic9 {
            images.append(pic1)
        }
        switch images.count {
        case 0:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(0)
                make?.width.mas_equalTo()(0)
            }
        case 1,4:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(203))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(203))
            }
        case 2:
            if images[0].hasSuffix(".mp4") {
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
                }
            }else{
                nineImageView.mas_updateConstraints { (make) in
                    make?.height.mas_equalTo()(DCUtill.SCRATIOX(102))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(210))
                }
            }
        case 3:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(90))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        case 5,6:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(180))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(280))
            }
        default:
            nineImageView.mas_updateConstraints { (make) in
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(278))
                make?.width.mas_equalTo()(DCUtill.SCRATIOX(278))
            }
        }
        nineImageView.images = images
    }
    
    @objc func onGotoDetail(g:UIGestureRecognizer) {
        if g.state == .ended {
            if model != nil {
                let vc = MomentDetailViewController()
                vc.circle_id = model?.circle_id
                self.vc?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.vc?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func onGotoPersonal(g:UIGestureRecognizer) {
        if g.state == .ended {
            if model != nil {
                let vc = PersonalMomentViewController()
                vc.userid = model?.user_id
                vc.headURL = model?.portrait
                self.vc?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.vc?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    static func cellForSize(_ m:FriendCircleData?) -> CGSize {
        var h = DCUtill.SCRATIOX(22)
        h += DCUtill.ga_heightForComment(str: m?.user_name ?? "", fontSize: DCUtill.SCRATIOX(18), width: MomentHeaderCell.contentW)
        if !(m?.content?.isEmpty ?? true) {
            h += DCUtill.SCRATIOX(10)
            h += DCUtill.ga_heightForComment(str: m?.content ?? "", fontSize: DCUtill.SCRATIOX(17), width: MomentHeaderCell.contentW)
        }
        h += DCUtill.SCRATIOX(10)
        var images = [String]()
        if let pic1 = m?.pic1 {
            images.append(pic1)
        }
        if let pic1 = m?.pic2 {
            images.append(pic1)
        }
        if let pic1 = m?.pic3 {
            images.append(pic1)
        }
        if let pic1 = m?.pic4 {
            images.append(pic1)
        }
        if let pic1 = m?.pic5 {
            images.append(pic1)
        }
        if let pic1 = m?.pic6 {
            images.append(pic1)
        }
        if let pic1 = m?.pic7 {
            images.append(pic1)
        }
        if let pic1 = m?.pic8 {
            images.append(pic1)
        }
        if let pic1 = m?.pic9 {
            images.append(pic1)
        }
        switch images.count {
        case 0:
            h += 0
        case 1,4:
            h += DCUtill.SCRATIOX(203)
        case 2:
            if images[0].hasSuffix(".mp4") {
                h += DCUtill.SCRATIOX(278)
            }else{
                h += DCUtill.SCRATIOX(102)
            }
        case 3:
            h += DCUtill.SCRATIOX(90)
        case 5,6:
            h += DCUtill.SCRATIOX(180)
        default:
            h += DCUtill.SCRATIOX(278)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: h)
    }
}
