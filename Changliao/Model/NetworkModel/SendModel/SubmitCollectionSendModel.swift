//
//  SubmitCollectionSendModel.swift
//  boxin
//
//  Created by guduzhonglao on 11/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation

class SubmitCollectionSendModel: UserInfoSendModel {
    var type:Int?
    var content:String?
    init(_  message:EMMessage) {
        super.init()
        if message.body.type == EMMessageBodyTypeText {
            if message.ext?["type"] as? String == "person" {
                type = 2
                let content = MessgaeData()
                content.content = "[名片]"
                content.userid = message.ext?["id"] as? String
                content.name = message.ext?["username"] as? String
                content.cardid = message.ext?["usernum"] as? String
                content.head = message.ext?["userhead"] as? String
                self.content = content.toJSONString()
                return
            }
            type = 1
            let content = MessgaeData()
            let body = message.body as? EMTextMessageBody
            content.content = body?.text
            self.content = content.toJSONString()
            return
        }
        if let body = message.body as? EMLocationMessageBody {
            type = 4
            let content = MessgaeData()
            content.address = body.address
            content.latitude = body.latitude
            content.longitude = body.longitude
            self.content = content.toJSONString()
            return
        }
        if let body = message.body as? EMImageMessageBody {
            type = 6
            let content = MessgaeData()
            let arr1 = body.localPath.split(separator: "/")
            content.fileName = String(arr1[arr1.count-1])
            let arr = body.remotePath.split(separator: "/")
            content.name = String(arr[arr.count - 1])
            content.size = body.fileLength
            if let image = UIImage(contentsOfFile: body.localPath) {
                content.width = Int(image.size.width)
                content.height = Int(image.size.height)
            }else{
                if let image = UIImage(contentsOfFile: body.thumbnailLocalPath) {
                    content.width = Int(image.size.width)
                    content.height = Int(image.size.height)
                }
            }
            self.content = content.toJSONString()
            return
        }
        if let body = message.body as? EMVoiceMessageBody {
            type = 7
            let content = MessgaeData()
            let arr = body.remotePath.split(separator: "/")
            content.name = String(arr[arr.count - 1])
            content.size = body.fileLength
            content.timelong = body.duration
            self.content = content.toJSONString()
            return
        }
        if let body = message.body as? EMVideoMessageBody {
            type = 8
            let content = MessgaeData()
            content.duration = body.duration
            let arr1 = body.localPath.split(separator: "/")
            content.filename = String(arr1[arr1.count-1])
            content.size = body.fileLength
            let arr2 = body.remotePath.split(separator: "/")
            content.videoname = String(arr2[arr2.count-1])
            if let image = UIImage(contentsOfFile: body.thumbnailLocalPath) {
                content.width = Int(image.size.width)
                content.height = Int(image.size.height)
            }
            let arr3 = body.thumbnailRemotePath.split(separator: "/")
            content.fileimage = String(arr3[arr3.count-1])
            self.content = content.toJSONString()
            return
        }
        if let body = message.body as? EMFileMessageBody {
            type = 5
            let content = MessgaeData()
            content.filename = body.displayName
            let arr = body.remotePath.split(separator: "/")
            content.name = String(arr[arr.count - 1])
            content.size = body.fileLength
            self.content = content.toJSONString()
            return
        }
    }
    
    required init() {
        super.init()
    }
}
