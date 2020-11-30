//
//  GetConllectionListReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 11/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class CollectionListData: HandyJSON {
    var collection_id:String?
    var create_time:Int64 = 0
    var type:Int = 0
    var osspath:String?
    var content:MessgaeData?
    var time:Int64?
    var id:String?
    required init() {
        
    }
    
    func toMessage() -> EMMessage {
        if type == 1 {
            let body = EMTextMessageBody(text: content?.content ?? "")
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 2 {
            let ext = ["type":"person","id":content?.userid ?? "","username" : content?.name ?? "", "usernum": content?.cardid ?? "", "userhead": content?.head ?? ""]
            let body = EMTextMessageBody(text: content?.content)
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: ext)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 4 {
            let body = EMLocationMessageBody(latitude: content?.latitude ?? 0.0, longitude: content?.longitude ?? 0.0, address: content?.address ?? "")
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 5 {
            let body = EMFileMessageBody(localPath: "", displayName: "")
            body?.displayName = content?.filename
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 6 {
            let body = EMImageMessageBody(data: Data(), thumbnailData: Data())
            body?.displayName = content?.fileName
            body?.thumbnailDisplayName = content?.fileName
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            body?.thumbnailRemotePath = body!.remotePath + "?x-oss-process=image/resize,w_300,limit_0"
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) && body?.displayName != "" {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            body?.size = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
            body?.thumbnailSize = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
            body?.thumbnailFileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 7 {
            let body = EMVoiceMessageBody(localPath: "", displayName: "")
            body?.displayName = content?.name
            body?.duration = content?.timelong ?? 0
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("appdata", isDirectory: true)
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        let body = EMVideoMessageBody(localPath: "", displayName: "")
        body?.displayName = content?.filename
        body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.videoname ?? "")
        body?.thumbnailRemotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.fileimage ?? "")
        body?.duration = content?.duration ?? 0
        let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        var dic = path[path.count - 1]
        dic.appendPathComponent("appdata", isDirectory: true)
        dic.appendPathComponent("chatbuffer1", isDirectory: true)
        var b = ObjCBool(booleanLiteral: false)
        if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
            if b.boolValue {
                dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                if FileManager.default.fileExists(atPath: dic.path) {
                    body?.localPath = dic.path
                    body?.downloadStatus = EMDownloadStatusSuccessed
                }else{
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                try? FileManager.default.removeItem(at: dic)
                body?.downloadStatus = EMDownloadStatusPending
            }
        }else{
            body?.downloadStatus = EMDownloadStatusPending
        }
        var dic1 = path[path.count-1]
        dic1.appendPathComponent("VedioTemp", isDirectory: true)
        b = ObjCBool(booleanLiteral: false)
        if FileManager.default.fileExists(atPath: dic1.path, isDirectory: &b) {
            if b.boolValue {
                dic1.appendPathComponent(content?.fileimage ?? "", isDirectory: false)
                if FileManager.default.fileExists(atPath: dic1.path) {
                    body?.thumbnailLocalPath = dic1.path
                    body?.thumbnailDownloadStatus = EMDownloadStatusSuccessed
                }else{
                    body?.thumbnailDownloadStatus = EMDownloadStatusPending
                }
            }else{
                try? FileManager.default.removeItem(at: dic1)
                body?.thumbnailDownloadStatus = EMDownloadStatusPending
            }
        }else{
            body?.thumbnailDownloadStatus = EMDownloadStatusPending
        }
        body?.fileLength = content?.size ?? 0
        body?.thumbnailSize = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
        let msg = EMMessage(conversationID: "collection", from: EMClient.shared()?.currentUsername, to: "collection", body: body, ext: nil)
        msg?.localTime = time ?? create_time
        msg?.timestamp = time ?? create_time
        msg?.isRead = true
        msg?.direction = EMMessageDirectionSend
        msg?.messageId = id ?? collection_id
        msg?.status=EMMessageStatusSucceed
        return msg!
    }
    
    func toConversationMessage() -> EMMessage {
        if type == 1 {
            let body = EMTextMessageBody(text: content?.content ?? "")
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 2 {
            let ext = ["type":"person","id":content?.userid ?? "","username" : content?.name ?? "", "usernum": content?.cardid ?? "", "userhead": content?.head ?? ""]
            let body = EMTextMessageBody(text: content?.content)
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: ext)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 4 {
            let body = EMLocationMessageBody(latitude: content?.latitude ?? 0.0, longitude: content?.longitude ?? 0.0, address: content?.address ?? "")
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 5 {
            let body = EMFileMessageBody(localPath: "", displayName: "")
            body?.displayName = content?.filename
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 6 {
            let body = EMImageMessageBody(data: Data(), thumbnailData: Data())
            body?.displayName = content?.fileName
            body?.thumbnailDisplayName = content?.fileName
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            body?.thumbnailRemotePath = body!.remotePath + "?x-oss-process=image/resize,w_300,limit_0"
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) && body?.displayName != "" {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            body?.size = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
            body?.thumbnailSize = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
            body?.thumbnailFileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        if type == 7 {
            let body = EMVoiceMessageBody(localPath: "", displayName: "")
            body?.displayName = content?.name
            body?.duration = content?.timelong ?? 0
            body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.name ?? "")
            let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            var dic = path[path.count - 1]
            dic.appendPathComponent("appdata", isDirectory: true)
            dic.appendPathComponent("chatbuffer", isDirectory: true)
            var b = ObjCBool(booleanLiteral: false)
            if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                if b.boolValue {
                    dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                    if FileManager.default.fileExists(atPath: dic.path) {
                        body?.localPath = dic.path
                        body?.downloadStatus = EMDownloadStatusSuccessed
                    }else{
                        body?.downloadStatus = EMDownloadStatusPending
                    }
                }else{
                    try? FileManager.default.removeItem(at: dic)
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                body?.downloadStatus = EMDownloadStatusPending
            }
            body?.fileLength = content?.size ?? 0
            let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
            msg?.localTime = time ?? create_time
            msg?.timestamp = time ?? create_time
            msg?.isRead = true
            msg?.direction = EMMessageDirectionSend
            msg?.messageId = id ?? collection_id
            msg?.status=EMMessageStatusSucceed
            return msg!
        }
        let body = EMVideoMessageBody(localPath: "", displayName: "")
        body?.displayName = content?.filename
        body?.remotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.videoname ?? "")
        body?.thumbnailRemotePath = (osspath ?? "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/") + (content?.fileimage ?? "")
        body?.duration = content?.duration ?? 0
        let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        var dic = path[path.count - 1]
        dic.appendPathComponent("appdata", isDirectory: true)
        dic.appendPathComponent("chatbuffer1", isDirectory: true)
        var b = ObjCBool(booleanLiteral: false)
        if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
            if b.boolValue {
                dic.appendPathComponent(body?.displayName ?? "", isDirectory: false)
                if FileManager.default.fileExists(atPath: dic.path) {
                    body?.localPath = dic.path
                    body?.downloadStatus = EMDownloadStatusSuccessed
                }else{
                    body?.downloadStatus = EMDownloadStatusPending
                }
            }else{
                try? FileManager.default.removeItem(at: dic)
                body?.downloadStatus = EMDownloadStatusPending
            }
        }else{
            body?.downloadStatus = EMDownloadStatusPending
        }
        var dic1 = path[path.count-1]
        dic1.appendPathComponent("VedioTemp", isDirectory: true)
        b = ObjCBool(booleanLiteral: false)
        if FileManager.default.fileExists(atPath: dic1.path, isDirectory: &b) {
            if b.boolValue {
                dic1.appendPathComponent(content?.fileimage ?? "", isDirectory: false)
                if FileManager.default.fileExists(atPath: dic1.path) {
                    body?.thumbnailLocalPath = dic1.path
                    body?.thumbnailDownloadStatus = EMDownloadStatusSuccessed
                }else{
                    body?.thumbnailDownloadStatus = EMDownloadStatusPending
                }
            }else{
                try? FileManager.default.removeItem(at: dic1)
                body?.thumbnailDownloadStatus = EMDownloadStatusPending
            }
        }else{
            body?.thumbnailDownloadStatus = EMDownloadStatusPending
        }
        body?.fileLength = content?.size ?? 0
        body?.thumbnailSize = CGSize(width: content?.width ?? 0, height: content?.height ?? 0)
        let msg = EMMessage(conversationID: "collect", from: EMClient.shared()?.currentUsername, to: "collect", body: body, ext: nil)
        msg?.localTime = time ?? create_time
        msg?.timestamp = time ?? create_time
        msg?.isRead = true
        msg?.direction = EMMessageDirectionSend
        msg?.messageId = id ?? collection_id
        msg?.status=EMMessageStatusSucceed
        return msg!
    }
}

class MessgaeData: HandyJSON {
    /// 文本消息
    var content:String?
    /// 语音时长
    var timelong:Int32?
    /// 文件大小
    var size:Int64?
    /// 语音、图片oss文件名称、名片昵称
    var name:String?
    /// 视频长度秒
    var duration:Int32?
    /// 视频、文件文件名
    var filename:String?
    /// 视频oss文件名
    var videoname:String?
    /// 视频缩略图oss文件名
    var fileimage:String?
    /// 图片文件名
    var fileName:String?
    /// 图片、视频宽度
    var width:Int?
    /// 图片视频高度
    var height:Int?
    /// 位置消息地址
    var address:String?
    /// 位置消息精度
    var latitude:Double?
    /// 位置消息纬度
    var longitude:Double?
    /// 名片头像
    var head:String?
    /// 名片畅聊号
    var cardid:String?
    /// 名片userID
    var userid:String?
    required init() {
        
    }
}

class GetConllectionListReciveModel: BaseReciveModel {
    var data:[CollectionListData?]?
}
