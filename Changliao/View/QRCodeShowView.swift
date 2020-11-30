//
//  QRCodeShowView.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import CoreImage
import SDWebImage

class QRCodeShowView: UIView {
    
    var bk:UIView

    init(qrcode:String) {
        bk = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        super.init(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        bk.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        bk.isUserInteractionEnabled =  true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        bk.addGestureRecognizer(tap)
        let headImageView = UIImageView(image: UIImage(named: "moren"))
        self.addSubview(headImageView)
        let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
        headImageView.sd_setImage(with: URL(string: model!.db!.portrait!), placeholderImage: UIImage(named: "moren"))
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 5
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.mas_left)?.offset()(8)
            make?.top.equalTo()(self.mas_top)?.offset()(16)
            make?.width.mas_equalTo()(50)
            make?.height.mas_equalTo()(50)
        }
        let phone = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        phone.font = UIFont.systemFont(ofSize: 13)
        phone.textColor = UIColor.hexadecimalColor(hexadecimal: "8a8888")
        phone.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", model!.db!.id_card!)
        self.addSubview(phone)
        phone.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(8)
            make?.bottom.equalTo()(headImageView.mas_bottom)
        }
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        name.font = UIFont.systemFont(ofSize: 14)
        name.text = model?.db?.user_name
        self.addSubview(name)
        name.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(8)
            make?.bottom.equalTo()(phone.mas_top)?.offset()(-4)
        }
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = qrcode.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        let QRImaageView = UIImageView(image: createNonInterpolatedUIImageFormCIImage(image: (filter?.outputImage)!, size: 300))
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.addSubview(QRImaageView)
        QRImaageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.mas_left)?.offset()(8)
            make?.right.equalTo()(self.mas_right)?.offset()(-8)
            make?.top.equalTo()(headImageView.mas_bottom)?.offset()(16)
            make?.height.mas_equalTo()(284)
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.hexadecimalColor(hexadecimal: "8a8888")
        label.text = "扫一扫上面二维图案，加我畅聊"
        self.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.top.equalTo()(QRImaageView.mas_bottom)?.offset()(8)
            make?.bottom.equalTo()(self.mas_bottom)?.offset()(-16)
            make?.centerX.equalTo()(self.mas_centerX)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        bk = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        super.init(coder: aDecoder)
    }
    
    func show() {
        UIViewController.currentViewController()?.view.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.bk.superview?.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.bk.superview?.mas_safeAreaLayoutGuideRight)
            make?.top.equalTo()(self.bk.superview?.mas_safeAreaLayoutGuideTop)
            make?.bottom.equalTo()(self.bk.superview?.mas_bottom)
        }
        UIViewController.currentViewController()?.view.addSubview(self)
        self.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(300)
            make?.centerX.equalTo()(self.superview?.mas_centerX)
            make?.centerY.equalTo()(self.superview?.mas_centerY)
        }
    }
    
    //MARK: - 根据CIImage生成指定大小的高清UIImage
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        //CIImage没有frame与bounds属性,只有extent属性
        let ciextent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/ciextent.width, size/ciextent.height)
        
        let context = CIContext(options: nil)  //创建基于GPU的CIContext对象,性能和效果更好
        let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! //CIImage->CGImage
        
        let width = ciextent.width * scale
        let height = ciextent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray() //灰度颜色通道
        let info_UInt32 = CGImageAlphaInfo.none.rawValue
        
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: info_UInt32)! //图形上下文，画布
        bitmapRef.interpolationQuality = CGInterpolationQuality.none //写入质量
        bitmapRef.scaleBy(x: scale, y: scale) //调整“画布”的缩放
        bitmapRef.draw(bitmapImage, in: ciextent)  //绘制图片
        
        let scaledImage: CGImage = bitmapRef.makeImage()! //保存
        return UIImage(cgImage: scaledImage)
    }
    
    //MARK: - 根据背景图片和头像合成头像二维码
    func creatImage(bgImage: UIImage, iconImage:UIImage) -> UIImage{
        
        //开启图片上下文
        UIGraphicsBeginImageContext(bgImage.size)
        //绘制背景图片
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        //绘制头像
        let width: CGFloat = 50
        let height: CGFloat = width
        let x = (bgImage.size.width - width) * 0.5
        let y = (bgImage.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        return newImage!
    }
    
    @objc private func dismiss() {
        bk.removeFromSuperview()
        self.removeFromSuperview()
    }
    
}
