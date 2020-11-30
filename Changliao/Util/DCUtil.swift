//
//  DCUtil.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
import UIKit


@objc class DCUtill:NSObject {
    /// 设置阴影
    ///
    /// - Parameter controller: <#controller description#>
    class func setNavigationBarShadow(controller:UIViewController) {
        controller.navigationController?.navigationBar.layer.shadowColor = UIColor.hexadecimalColor(hexadecimal: "adacac").cgColor
        controller.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: -5)
    }
    /// 设置标题
    ///
    /// - Parameter controller: <#controller description#>
    class func setNavigationBarTittle(controller:UIViewController) {
        controller.navigationController?.navigationBar.topItem?.title = controller.title
    }
    
    /// 获取导航栏渐变色（从左到右）
    ///
    /// - Parameters:
    ///   - beginColor: 起始颜色（16进制）
    ///   - endColor: 结束颜色（16进制）
    /// - Returns: 颜色图片
    @objc static func gradientRamp(beginColor:String,endColor:String) -> UIImage {
        let gradient = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.width
        let frameAndStatusBar = CGRect(x: 0, y: 0, width: sizeLength, height: 100)
        gradient.frame = frameAndStatusBar
        gradient.colors = [UIColor.hexadecimalColor(hexadecimal: beginColor).cgColor, UIColor.hexadecimalColor(hexadecimal: endColor).cgColor]
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        gradient.locations = gradientLocations
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        UIGraphicsBeginImageContext(gradient.frame.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    /// 过滤出表情转译字符串
    ///
    /// - Parameter text: 文字消息
    /// - Returns: 表情数组
    static func fliterEmotion(text:String) -> [String] {
        var fistString = Array<String>()
        text.split(separator: "[").forEach { (a) in
            fistString.append(String(a.utf8)!)
        }
        if fistString.count == 0 {
            return Array<String>()
        }
        var result = Array<String>()
        for s in fistString {
            let str = String(s.split(separator: "]")[0])
            if str.count != 0 {
                result.append(str)
            }
        }
        return result
    }
    
    /// 全机型适配
    ///
    /// - Parameter x: 设计大小
    /// - Returns: 实际大小
    static func SCRATIO(x:CGFloat) -> CGFloat {
        return ceil(x * UIScreen.main.bounds.width / 375)
    }
    
    static func FONT(x:CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: SCRATIO(x: x))
    }
    
    static func SCRATIOX(_ x:CGFloat) -> CGFloat {
        return ceil(x * UIScreen.main.bounds.width / 414)
    }
    
    static func FONTX(_ x:CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: SCRATIOX(x))
    }
    
    /// 获取连接地址
    ///
    /// - Parameter str: 文本
    /// - Returns: 连接地址列表
    static func getUrls(str:String) -> [String] {
        var urls = [String]()
        // 创建一个正则表达式对象
        do {
            let dataDetector = try NSRegularExpression(pattern: "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]", options: [])
            // 匹配字符串，返回结果集
            let res = dataDetector.matches(in: str,
                                                   options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                   range: NSMakeRange(0, str.count))
            // 取出结果
            for checkingRes in res {
                urls.append((str as NSString).substring(with: checkingRes.range))
            }
        }
        catch {
            print(error)
        }
        return urls
    }
    
    static func ga_heightForComment(str:String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize:  fontSize)
        let rect = NSString(string: str).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height + 20)
    }
    
    static func true_heightForComment(str:String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize:  fontSize)
        let rect = NSString(string: str).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    static func ga_widthForComment(str:String, fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: str).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    static func getMacAddress()->String{
        let index  = Int32(if_nametoindex("en0"))
        let bsdData = "en0".data(using: .utf8)
        var mib : [Int32] = [CTL_NET,AF_ROUTE,0,AF_LINK,NET_RT_IFLIST,index]
        var len = 0;
          
        if sysctl(&mib,UInt32(mib.count), nil, &len,nil,0) < 0 {
            print("Error: could not determine length of info data structure ")
            return "00:00:00:00:00:00"
        }
          
        var buffer = [CChar](repeating: 0, count: len)
        if sysctl(&mib, UInt32(mib.count), &buffer, &len, nil, 0) < 0 {
            print("Error: could not read info data structure")
            return "00:00:00:00:00:00"
        }
          
        let infoData = NSData(bytes: buffer, length: len)
        var interfaceMsgStruct = if_msghdr()
        infoData.getBytes(&interfaceMsgStruct, length: MemoryLayout.size(ofValue: if_msghdr.self))
        let socketStructStart = MemoryLayout.size(ofValue: if_msghdr.self) + 1
        let socketStructData = infoData.subdata(with: NSMakeRange(socketStructStart, len - socketStructStart))
        let rangeOfToken = socketStructData.range(of: bsdData ?? Data(), options: .backwards, in: Range(NSMakeRange(0, socketStructData.count)))
        let macAddressData = socketStructData.subdata(in: Range<Data.Index>(uncheckedBounds: (lower: rangeOfToken!.lowerBound - 2, upper: rangeOfToken!.lowerBound + 4)))
        var macAddressDataBytes = [UInt8](repeating: 0, count: 6)
        macAddressData.copyBytes(to: &macAddressDataBytes, count: 6)
        return macAddressDataBytes.map({ String(format:"%02x", $0) }).joined(separator: ":")
    }
    /*这是一个内置函数
     lower : 内置为 0，可根据自己要获取的随机数进行修改。
     upper : 内置为 UInt32.max 的最大值，这里防止转化越界，造成的崩溃。
     返回的结果： [lower,upper) 之间的半开半闭区间的数。
     */
    public static func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}
