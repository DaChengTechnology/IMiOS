//
//  LginLogTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 10/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class LginLogTableViewCell: UITableViewCell {
    
    private var bkView:UIView?
    private var timeLabel:UILabel?
    private var proformLabel:UILabel?
    private var iPLabel:UILabel?
    private var operationLabel:UILabel?
    var model:GetLoginTraceData? {
        didSet {
            timeLabel?.text = self.model?.create_time
            if self.model?.device?.isEmpty ?? true {
                let loginIPText = NSAttributedString(string: "登陆IP:", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "010101")])
                let iptext = NSMutableAttributedString(string: self.model?.ipadd ?? "", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "#EC582E")])
                iptext.insert(loginIPText, at: 0)
                proformLabel?.attributedText = iptext
                let operationText = NSAttributedString(string: "敏感操作:", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "010101")])
                let perationtext = NSMutableAttributedString(string: self.model?.content ?? "", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "#EC582E")])
                perationtext.insert(operationText, at: 0)
                iPLabel?.attributedText = perationtext
                operationLabel?.text = nil
            }else{
                let DeviceText = NSAttributedString(string: "登陆设备:", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "010101")])
                let devicetext = NSMutableAttributedString(string: self.model?.device ?? "", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "#EC582E")])
                devicetext.insert(DeviceText, at: 0)
                proformLabel?.attributedText = devicetext
                let loginIPText = NSAttributedString(string: "登陆IP:", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "010101")])
                let iptext = NSMutableAttributedString(string: self.model?.ipadd ?? "", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "#EC582E")])
                iptext.insert(loginIPText, at: 0)
                iPLabel?.attributedText = iptext
                let operationText = NSAttributedString(string: "敏感操作:", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "010101")])
                let perationtext = NSMutableAttributedString(string: self.model?.content ?? "", attributes: [NSAttributedString.Key.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "#EC582E")])
                perationtext.insert(operationText, at: 0)
                operationLabel?.attributedText = perationtext
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        bkView = UIView()
        bkView?.backgroundColor = UIColor.white
        bkView?.layer.cornerRadius = DCUtill.SCRATIO(x: 10)
        bkView?.layer.masksToBounds = true
        self.contentView.addSubview(bkView!)
        bkView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: 10))
            make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -15))
            make?.bottom.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -10))
        })
        timeLabel = UILabel()
        timeLabel?.font = DCUtill.FONT(x: 14)
        bkView?.addSubview(timeLabel!)
        timeLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.right.lessThanOrEqualTo()(bkView)?.offset()(DCUtill.SCRATIO(x: -15))
        })
        proformLabel = UILabel()
        proformLabel?.font = DCUtill.FONT(x: 14)
        bkView?.addSubview(proformLabel!)
        proformLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(timeLabel?.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 10))
        })
        iPLabel = UILabel()
        iPLabel?.font = DCUtill.FONT(x: 14)
        bkView?.addSubview(iPLabel!)
        iPLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(proformLabel?.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 10))
        })
        operationLabel = UILabel()
        operationLabel?.font = DCUtill.FONT(x: 14)
        bkView?.addSubview(operationLabel!)
        operationLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(iPLabel?.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 10))
        })
        let tipsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        tipsLabel.text = "如果这不是您本人的操作，您的畅聊密码已经泄漏。请立即进入“个人设置-重置密码”中修改个人密码，防止您的损失。"
        tipsLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "010101")
        tipsLabel.numberOfLines = 0
        tipsLabel.font = DCUtill.FONT(x: 14)
        bkView?.addSubview(tipsLabel)
        tipsLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(operationLabel?.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 10))
            make?.right.lessThanOrEqualTo()(bkView)?.offset()(DCUtill.SCRATIO(x: -15))
            make?.bottom.equalTo()(bkView)?.offset()(DCUtill.SCRATIO(x: -15))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
