//
//  DIYBubleView.swift
//  boxin
//
//  Created by guduzhonglao on 8/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DIYBubleView: UIImageView {
    
    var index:Int = -1
    var messageLabel:DCTapView?
    var messageImageView:UIImageView?
    var titleLabel:UILabel?
    var contentLable:UILabel?
    var bkView:UIView?
    var lineView:UIView?
    var personalLabel:UILabel?
    var model:BoxinMessageModel? {
        didSet {
            setup()
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setup() {
        if model!.bodyType == EMMessageBodyTypeText {
            if model!.isIDCard {
                self.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                self.layer.cornerRadius = 12.5
                bkView?.removeFromSuperview()
                bkView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                bkView?.backgroundColor = UIColor.white
                bkView?.layer.cornerRadius = 5
                self.addSubview(bkView!)
                bkView?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self)?.offset()(5)
                    make?.top.equalTo()(self)?.offset()(5)
                    make?.right.equalTo()(self)?.offset()(-5)
                    make?.bottom.equalTo()(self)?.offset()(-5)
                    make?.width.mas_equalTo()(180)
                    make?.height.mas_equalTo()(100)
                })
                messageImageView?.removeFromSuperview()
                messageImageView = UIImageView(image: model?.avatarImage)
                if let url = model?.avatarURLPath {
                    messageImageView?.sd_setImage(with: URL(string: url), placeholderImage: model?.avatarImage, options: .allowInvalidSSLCertificates, context: nil)
                }
                bkView?.addSubview(messageImageView!)
                messageImageView?.mas_makeConstraints({ (make) in
                    make?.top.equalTo()(bkView)?.offset()(15)
                    make?.left.equalTo()(bkView)?.offset()(15)
                    make?.width.mas_equalTo()(50)
                    make?.height.mas_equalTo()(50)
                })
                titleLabel?.removeFromSuperview()
                titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                titleLabel?.font = UIFont.systemFont(ofSize: 13)
                titleLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                titleLabel?.text = model?.personalName
                titleLabel?.textAlignment = .center
                bkView?.addSubview(titleLabel!)
                titleLabel?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(messageImageView?.mas_right)?.offset()(8)
                    make?.top.equalTo()(bkView)?.offset()(26)
                    make?.right.equalTo()(bkView)?.offset()(-8)
                })
                contentLable?.removeFromSuperview()
                contentLable = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                contentLable?.font = UIFont.systemFont(ofSize: 10)
                contentLable?.textColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                contentLable?.text = String(format: "畅聊号:%@", model?.personalIDCard ?? "")
                contentLable?.textAlignment = .center
                bkView?.addSubview(contentLable!)
                contentLable?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(messageImageView?.mas_right)?.offset()(8)
                    make?.top.equalTo()(titleLabel?.mas_bottom)?.offset()(10)
                    make?.right.equalTo()(bkView)?.offset()(-8)
                })
                lineView?.removeFromSuperview()
                lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                lineView?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                bkView?.addSubview(lineView!)
                lineView?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(bkView)?.offset()(20)
                    make?.top.equalTo()(messageImageView?.mas_bottom)?.offset()(10)
                    make?.right.equalTo()(bkView)?.offset()(-20)
                    make?.height.mas_equalTo()(1)
                })
                personalLabel?.removeFromSuperview()
                personalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                personalLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                personalLabel?.font = UIFont.systemFont(ofSize: 11)
                personalLabel?.text = "个人名片"
                return
            }
            if model!.isGifFace {
                bkView?.removeFromSuperview()
                messageImageView?.removeFromSuperview()
                messageLabel?.removeFromSuperview()
                titleLabel?.removeFromSuperview()
                contentLable?.removeFromSuperview()
                lineView?.removeFromSuperview()
                personalLabel?.removeFromSuperview()
                self.backgroundColor = UIColor.clear
                self.layer.cornerRadius = 0
                self.sd_setImage(with: URL(string: model!.faceUrl)) { (image, err, type, url) in
                    if err == nil {
                        self.mas_remakeConstraints({ (make) in
                            make?.left.equalTo()(self.mas_left)
                            make?.top.equalTo()(self.mas_top)
                            make?.height.mas_equalTo()(130)
                            make?.width.mas_equalTo()(image!.size.width/image!.size.height*130)
                        })
                    }
                }
                return
            }
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            if model!.isSender {
                self.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
            }else{
                self.backgroundColor = UIColor.white
            }
            self.layer.cornerRadius = 12.5
            let width = DCUtill.ga_widthForComment(str: model!.text, fontSize: 13, height: 15)
            if width <= (DIYMessageCell.appearance() as DIYMessageCell).maxWidth - 24 {
                messageLabel = DCTapView(frame: CGRect(x: 0, y: 0, width: width, height: 15))
                messageLabel?.text = model?.text
                self.addSubview(messageLabel!)
                messageLabel?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self)?.offset()(12)
                    make?.top.equalTo()(self)?.offset()(7)
                    make?.right.equalTo()(self)?.offset()(-12)
                    make?.bottom.equalTo()(self)?.offset()(-7)
                    make?.width.mas_equalTo()(width)
                    make?.height.mas_equalTo()(15)
                })
            }else{
                let w = (DIYMessageCell.appearance() as DIYMessageCell).maxWidth - 24
                let heigh = DCUtill.true_heightForComment(str: model!.text, fontSize: 13, width: w)
                messageLabel = DCTapView(frame: CGRect(x: 0, y: 0, width: w, height: heigh))
                messageLabel?.text = model?.text
                self.addSubview(messageLabel!)
                messageLabel?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self)?.offset()(12)
                    make?.top.equalTo()(self)?.offset()(7)
                    make?.right.equalTo()(self)?.offset()(-12)
                    make?.bottom.equalTo()(self)?.offset()(-7)
                    make?.width.mas_equalTo()(w)
                    make?.height.mas_equalTo()(heigh)
                })
            }
        }
        if model?.bodyType == EMMessageBodyTypeImage {
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 0
        }
        if model?.bodyType == EMMessageBodyTypeVoice {
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 0
            if model!.isSender {
                self.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "ec582e")
                messageImageView = UIImageView(image: UIImage(named: "白3"))
                messageImageView?.mas_makeConstraints({ (make) in
                    make?.width.mas_equalTo()(11)
                    make?.height.mas_equalTo()(15)
                    make?.right.equalTo()(self)?.offset()(-8)
                    make?.centerY.equalTo()(self)
                })
                titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                titleLabel?.font = UIFont.systemFont(ofSize: 9)
                titleLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "#666666")
                titleLabel?.text = String(format: "%.0f″", model!.mediaDuration)
                self.addSubview(titleLabel!)
                titleLabel?.mas_makeConstraints({ (make) in
                    make?.right.equalTo()(self.mas_left)?.offset()(-6)
                    make?.bottom.equalTo()(messageImageView)?.offset()(-1)
                })
            }else{
                self.backgroundColor = UIColor.white
                messageImageView = UIImageView(image: UIImage(named: "橙3"))
                messageImageView?.mas_makeConstraints({ (make) in
                    make?.width.mas_equalTo()(11)
                    make?.height.mas_equalTo()(15)
                    make?.left.equalTo()(self)?.offset()(8)
                    make?.centerY.equalTo()(self)
                })
                titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                titleLabel?.font = UIFont.systemFont(ofSize: 9)
                titleLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "#666666")
                titleLabel?.text = String(format: "%.0f″", model!.mediaDuration)
                self.addSubview(titleLabel!)
                titleLabel?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self.mas_right)?.offset()(6)
                    make?.bottom.equalTo()(messageImageView)?.offset()(-1)
                })
            }
            self.layer.cornerRadius = 12.5
        }
        if model!.bodyType == EMMessageBodyTypeVideo {
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 0
            messageImageView = UIImageView(image: UIImage(named: "playVedio"))
            self.addSubview(messageImageView!)
            messageImageView?.mas_makeConstraints({ (make) in
                make?.width.mas_equalTo()(28)
                make?.height.mas_equalTo()(28)
                make?.centerX.equalTo()(self)
                make?.centerY.equalTo()(self)
            })
        }
        if model?.bodyType == EMMessageBodyTypeFile {
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 0
            messageImageView = UIImageView(image: UIImage(named: "file"))
            self.addSubview(messageImageView!)
            messageImageView?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self)
                make?.top.equalTo()(self)
                make?.bottom.equalTo()(self)
                make?.width.mas_equalTo()(64)
                make?.height.mas_equalTo()(76)
            })
            bkView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            bkView?.backgroundColor = UIColor.white
            bkView?.layer.cornerRadius = 10
            bkView?.layer.shadowOpacity = 0.2
            bkView?.layer.shadowColor = UIColor.hexadecimalColor(hexadecimal: "#270606").cgColor
            bkView?.layer.shadowRadius = 2.5
            self.addSubview(bkView!)
            let w = (DIYMessageCell.appearance() as DIYMessageCell).maxWidth - 64 - 5
            bkView?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(messageImageView)?.offset()(5)
                make?.width.mas_lessThanOrEqualTo()(w)
                make?.centerY.equalTo()(messageImageView)
            })
            titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            titleLabel?.font = UIFont.systemFont(ofSize: 13)
            titleLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "#666666")
            titleLabel?.text = model?.fileName
            bkView?.addSubview(titleLabel!)
            titleLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(bkView)?.offset()(7)
                make?.top.equalTo()(bkView)?.offset()(5)
                make?.right.equalTo()(bkView)?.offset()(-7)
                make?.bottom.equalTo()(bkView)?.offset()(-5)
            })
            contentLable = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            contentLable?.font = UIFont.systemFont(ofSize: 11)
            contentLable?.textColor = UIColor.hexadecimalColor(hexadecimal: "#666666")
            var showSize = model!.fileSize / 8
            if showSize < 1024 {
                contentLable?.text = String(format: "%.2fKB", showSize)
            }else{
                showSize = showSize / 1024
                if showSize < 1024 {
                    contentLable?.text = String(format: "%.2fMB", showSize)
                }else{
                    showSize = showSize / 1024
                    contentLable?.text = String(format: "%.2fGB", showSize)
                }
            }
            self.addSubview(contentLable!)
            contentLable?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(bkView)
                make?.top.equalTo()(bkView?.mas_bottom)?.offset()(6)
            })
        }
        if model?.bodyType == EMMessageBodyTypeLocation {
            bkView?.removeFromSuperview()
            messageImageView?.removeFromSuperview()
            messageLabel?.removeFromSuperview()
            titleLabel?.removeFromSuperview()
            contentLable?.removeFromSuperview()
            lineView?.removeFromSuperview()
            personalLabel?.removeFromSuperview()
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = 0
            image = UIImage(named: "address")
            titleLabel?.font = UIFont.systemFont(ofSize: 13)
            titleLabel?.textColor = UIColor.white
            titleLabel?.text = model?.address
            titleLabel?.numberOfLines = 1
            self.addSubview(titleLabel!)
            titleLabel?.mas_makeConstraints({ (make) in
                make?.left.equalTo()(self)?.offset()(13)
                make?.bottom.equalTo()(self)?.offset()(-4)
                make?.right.equalTo()(self)?.offset()(-13)
            })
        }
    }

}
