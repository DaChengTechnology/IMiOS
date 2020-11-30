//
//  BoxinMessageModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

@objc class BoxinMessageModel: EaseMessageModel {
    @objc var member:GroupMemberData?
    @objc var urls:[String]?
    @objc var isIDCard = false
    @objc var isGifFace = false
    @objc var faceUrl:String = ""
    @objc var personalID:String = ""
    @objc var personalHeadURL:String = ""
    @objc var personalName:String = ""
    @objc var personalIDCard:String = ""
    @objc var faceH:CGFloat = 0
    @objc var faceW:CGFloat = 0
    
    required init!(message: EMMessage!) {
        if message.body.type == EMMessageBodyTypeText {
            if let textBody = message.body as? EMTextMessageBody {
                if (message.ext?["jpzim_is_big_expression"] as? Bool) ?? false {
                    isGifFace = true
                    faceUrl = (message.ext?["jpzim_big_expression_path"] as? String) ?? ""
                    faceH = CGFloat(Double(message.ext?["faceH"] as? String ?? "0") ?? 0)
                    faceW = CGFloat(Double(message.ext?["faceW"] as? String ?? "0") ?? 0)
                }
                if textBody.text.hasSuffix("_encode") {
                    let messagetext = String(textBody.text.split(separator: "_")[0].utf8)
                    if messagetext != nil {
                        super.init(message: message)
                        self.text = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: DCEncrypt.Decode_AES(strToDecode: messagetext!))
                        urls = DCUtill.getUrls(str: text)
                        if message.ext?["type"] as? String == "person" {
                            isIDCard = true
                            personalID = (message.ext?["id"] as? String) ?? ""
                        }
                        return
                    }
                }
            }
        }
        if message.body.type == EMMessageBodyTypeText {
            if message.ext?["type"] as? String == "person" {
                isIDCard = true
                personalID = (message.ext?["id"] as? String) ?? ""
            }
            if (message.ext?["jpzim_is_big_expression"] as? Bool) ?? false {
                isGifFace = true
                faceUrl = (message.ext?["jpzim_big_expression_path"] as? String) ?? ""
                faceH = CGFloat(Double(message.ext?["faceH"] as? String ?? "0") ?? 0)
                faceW = CGFloat(Double(message.ext?["faceW"] as? String ?? "0") ?? 0)
            }
        }
        if message.body.type == EMMessageBodyTypeFile {
            guard let size = (message.ext?["size"]) as? Int64 else {
                super.init(message: message)
                return
            }
            if let body = message.body as? EMFileMessageBody {
                body.fileLength = size
                message.body = body
            }
        }
        super.init(message: message)
        if message.body.type == EMMessageBodyTypeImage {
            let body = message.body as! EMImageMessageBody
            if body.thumbnailLocalPath != nil {
                self.thumbnailImage = UIImage(contentsOfFile: body.thumbnailLocalPath)
            }
            self.thumbnailFileURLPath = body.thumbnailRemotePath
            self.thumbnailFileLocalPath = body.thumbnailLocalPath
        }
    }
}
