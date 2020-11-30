//
//  MomentHistoryCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/23/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MomentHistoryCell: UICollectionViewCell {
    lazy var image:UIImageView = {
        let iv = UIImageView(image: UIImage(named: "AddMoment"))
        return iv
    }()
    lazy var time:UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONTX(20)
        l.textColor = .black
        return l
    }()
    lazy var context:UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONTX(16)
        l.textColor = .black
        l.numberOfLines = 2
        return l
    }()
    lazy var picCount:UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONTX(14)
        l.textColor = UIColor.hexadecimalColor(hexadecimal: "#878787")
        return l
    }()
    var model:MomentData?{
        didSet{
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
        self.contentView.addSubview(image)
        image.mas_makeConstraints { (make) in
            make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(84))
            make?.left.offset()(DCUtill.SCRATIOX(85))
            make?.top.offset()(DCUtill.SCRATIOX(39.5))
            make?.bottom.offset()(DCUtill.SCRATIOX(-39.5))
        }
        self.contentView.addSubview(time)
        time.mas_makeConstraints { (make) in
            make?.right.equalTo()(image.mas_left)?.offset()(DCUtill.SCRATIOX(-18))
            make?.top.equalTo()(image)
        }
        self.contentView.addSubview(context)
        context.mas_makeConstraints { (make) in
            make?.left.equalTo()(image.mas_right)?.offset()(DCUtill.SCRATIOX(13))
            make?.top.equalTo()(image)
            make?.right.mas_lessThanOrEqualTo()(DCUtill.SCRATIOX(-16))
        }
        self.contentView.addSubview(picCount)
        picCount.mas_makeConstraints { (make) in
            make?.left.equalTo()(image.mas_right)?.offset()(DCUtill.SCRATIOX(12))
            make?.bottom.equalTo()(image)
        }
    }
    
    func resetCell() {
        picCount.isHidden = false
        
        image.mas_updateConstraints { (make) in
            make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(84))
        }
    }
    
    func setModel() {
        let date = Date(timeIntervalSince1970: (model?.create_time ?? 0)/1000)
        let calendar = Calendar.current
        let components = calendar.dateComponents(Set(arrayLiteral: .year,.month,.day), from: date)
        let attr1 = NSMutableAttributedString(string: "\(components.day ?? 0)")
        attr1.addAttribute(.font, value: DCUtill.FONTX(21), range: NSRange(location: 0, length: attr1.string.count))
        let attr2 = NSMutableAttributedString(string: "\(components.month ?? 0)月", attributes: [.font:DCUtill.FONTX(13)])
        attr1.append(attr2)
        attr1.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attr1.string.count))
        time.attributedText = attr1
        if model?.pic1?.isEmpty ?? true {
            picCount.isHidden = true
            image.mas_updateConstraints { (make) in
                make?.width.mas_equalTo()(0)
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(24))
            }
        }else{
            resetCell()
            if model?.pic1?.hasSuffix(".mp4") ?? false {
                image.sd_setImage(with: URL(string: model?.pic2 ?? ""), completed: nil)
                picCount.text = "共1个视频"
            }else{
                image.sd_setImage(with: URL(string: model?.pic1 ?? ""), completed: nil)
                var count = 1
                if !(model?.pic2?.isEmpty ?? true) {
                    count += 1
                    if !(model?.pic3?.isEmpty ?? true) {
                        count += 1
                        if !(model?.pic4?.isEmpty ?? true) {
                            count += 1
                            if !(model?.pic5?.isEmpty ?? true) {
                                count += 1
                                if !(model?.pic6?.isEmpty ?? true) {
                                    count += 1
                                    if !(model?.pic7?.isEmpty ?? true) {
                                        count += 1
                                        if !(model?.pic8?.isEmpty ?? true) {
                                            count += 1
                                            if !(model?.pic9?.isEmpty ?? true) {
                                                count += 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                picCount.text = "共\(count)个图片"
            }
        }
        context.text = model?.content
    }
}
