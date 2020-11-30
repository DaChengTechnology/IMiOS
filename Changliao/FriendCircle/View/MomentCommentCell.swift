//
//  MomentCommentCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/10/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MomentCommentCell: UICollectionViewCell {
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
        l.isUserInteractionEnabled = true
        return l
    }()
    
    weak var vc:UIViewController?
    
    var model:CommentData? {
        didSet {
            setModel()
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
    
    func setup() {
        bk.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(g:))))
        comment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(g:))))
        self.contentView.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.top.bottom()?.offset()(0)
        }
        bk.addSubview(comment)
        comment.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(11))
            make?.top.offset()(DCUtill.SCRATIOX(2.5))
            make?.bottom.offset()(DCUtill.SCRATIOX(-2.5))
            make?.right.mas_lessThanOrEqualTo()(DCUtill.SCRATIOX(-11))
        }
    }
    private func setModel() {
        let attr = NSMutableAttributedString(string: "\(model?.friend_name ?? ""):\(model?.comment ?? "")")
        attr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attr.string.count))
        attr.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: 0, length: model?.friend_name?.count ?? 0))
        comment.attributedText = attr
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
    
    static func cellForSize(m:CommentData?) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: DCUtill.ga_heightForComment(str: "\(m?.friend_name ?? ""):\(m?.comment ?? "")", fontSize: DCUtill.SCRATIOX(14), width: UIScreen.main.bounds.width - DCUtill.SCRATIOX(75+16+22)))
    }
}
