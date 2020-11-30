//
//  DCDesEncrypt.swift
//  boxin
//
//  Created by guduzhonglao on 7/4/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

public class IAppEncryptionUtitlity: NSObject {
    private override init(){}
    public static let sharedNetworkVar: IAppEncryptionUtitlity = IAppEncryptionUtitlity()
    let key = "TI92v/3IGb8="
    func myEncrypt(encryptData:String) -> NSData?{
        
        let myKeyData : NSData = ("TI92v/3IGb8=" as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData
        let myRawData : NSData = encryptData.data(using: String.Encoding.utf8)! as NSData
        let buffer_size : size_t = myRawData.length + kCCBlockSize3DES
        let buffer = UnsafeMutablePointer<NSData>.allocate(capacity: buffer_size)
        var num_bytes_encrypted : size_t = 0
        
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithm3DES)
        let options:   CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        let keyLength        = size_t(kCCKeySize3DES)
        
        let Crypto_status: CCCryptorStatus = CCCrypt(operation, algoritm, options, myKeyData.bytes, keyLength, nil, myRawData.bytes, myRawData.length, buffer, buffer_size, &num_bytes_encrypted)
        
        if UInt32(Crypto_status) == UInt32(kCCSuccess){
            
            let myResult: NSData = NSData(bytes: buffer, length: num_bytes_encrypted)
            
            free(buffer)
            print("my result \(myResult)") //This just prints the data
            
            let keyData: NSData = myResult
            
            let hexString = keyData.hexEncodedString()
            print("hex result \(keyData)") // I needed a hex string output
            
            
            //myDecrypt(decryptData: myResult) // sent straight to the decryption function to test the data output is the same
            return myResult
        }else{
            free(buffer)
            return nil
        }
    }
    func myDecrypt(decryptData : NSData) -> NSData?{
        
        let mydata_len : Int = decryptData.length
        let keyData : NSData = "TI92v/3IGb8=".data(using: .utf8)?.base64EncodedData() as! NSData
        
        let buffer_size : size_t = mydata_len+kCCBlockSizeAES128
        let buffer = UnsafeMutablePointer<NSData>.allocate(capacity: buffer_size)
        var num_bytes_encrypted : size_t = 0
        
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithm3DES)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
        let keyLength        = size_t(kCCKeySize3DES)
        
        let decrypt_status : CCCryptorStatus = CCCrypt(operation, algoritm, options, keyData.bytes, keyLength, nil, decryptData.bytes, mydata_len, buffer, buffer_size, &num_bytes_encrypted)
        
        if UInt32(decrypt_status) == UInt32(kCCSuccess){
            
            let myResult : NSData = NSData(bytes: buffer, length: num_bytes_encrypted)
            free(buffer)
            print("decrypt \(myResult)")
            
            let stringResult = String(data: myResult as Data, encoding: .utf8)
            print("my decrypt string \(stringResult)")
            return myResult
        }else{
            free(buffer)
            return nil
            
        }
    }
}
extension NSData {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        //var map = { String(format: format, $0) }.joined()
        
        return ""
    }
}
