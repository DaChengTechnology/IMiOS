//
//  DCEncrypt.swift
//  Fight
//
//  Created by dacheng on 2017/11/19.
//  Copyright © 2017年 dacheng. All rights reserved.
//

import Foundation
import CryptoSwift

let aeskey:String = "TVD1NJPRL6T2caV9NvLXQw=="

@objc class DCEncrypt: NSObject {
    
    //aes ebc加密
    @objc static func Encoade_AES(strToEncode:String) -> String{
        let ps = strToEncode.data(using: .utf8)
        var encrpted:[UInt8] = []
        let key = Data(base64Encoded: aeskey)?.bytes
        do{
            encrpted = try AES(key: key!, blockMode: ECB(), padding: .pkcs7).encrypt((ps?.bytes)!)
        }catch{            print(error.localizedDescription)
        }
        let encoded = Data(encrpted)
        return encoded.toHexString().uppercased()
    }
    
    //aes ebc 解密
    @objc static func Decode_AES(strToDecode:String) -> String{
        let encrypted = Array<UInt8>.init(hex: strToDecode)
        var decrytped:[UInt8] = []
        let key = Data(base64Encoded: aeskey)?.bytes
        do{
            decrytped = try AES(key: key!, blockMode: ECB(), padding: .pkcs7).decrypt(encrypted)
        }catch{
            print(error.localizedDescription)
        }
        let encoded = Data(decrytped)
        return String(data: encoded, encoding: String.Encoding.utf8) ?? " "
    }
    
    //md5
    static func MD5(str:String) -> String{
        return str.md5()
    }
}
