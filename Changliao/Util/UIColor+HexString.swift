//
//  UIColor+HexString.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
extension UIColor{
    class func hexadecimalColor(hexadecimal:String)->UIColor{
        var cstr = hexadecimal.trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines).uppercased() as NSString;
        if(cstr.length < 6){
            return UIColor.clear;
        }
        if(cstr.hasPrefix("0X")){
            cstr = cstr.substring(from: 2) as NSString
        }
        if(cstr.hasPrefix("#")){
            cstr = cstr.substring(from: 1) as NSString
        }
        if(cstr.length != 6 && cstr.length != 8){
            return UIColor.clear;
        }
        if cstr.length==6 {
            var range = NSRange.init()
            range.location = 0
            range.length = 2
            //r
            let rStr = cstr.substring(with: range);
            //g
            range.location = 2;
            let gStr = cstr.substring(with: range)
            //b
            range.location = 4;
            let bStr = cstr.substring(with: range)
            var r :UInt32 = 0x0;
            var g :UInt32 = 0x0;
            var b :UInt32 = 0x0;
            Scanner.init(string: rStr).scanHexInt32(&r);
            Scanner.init(string: gStr).scanHexInt32(&g);
            Scanner.init(string: bStr).scanHexInt32(&b);
            return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1);
        }
        var range = NSRange.init()
        range.location = 0
        range.length = 2
        //r
        let rStr = cstr.substring(with: range);
        //g
        range.location = 2;
        let gStr = cstr.substring(with: range)
        //b
        range.location = 4;
        let bStr = cstr.substring(with: range)
        range.location=6
        let aStr = cstr.substring(with: range)
        var r :UInt32 = 0x0;
        var g :UInt32 = 0x0;
        var b :UInt32 = 0x0;
        var a :UInt32 = 0x0
        Scanner.init(string: rStr).scanHexInt32(&r);
        Scanner.init(string: gStr).scanHexInt32(&g);
        Scanner.init(string: bStr).scanHexInt32(&b);
        Scanner(string: aStr).scanHexInt32(&a)
        return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0);
    }
}
