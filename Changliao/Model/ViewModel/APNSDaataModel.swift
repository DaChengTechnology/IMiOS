//
//  APNSDaataModel.swift
//  boxin
//
//  Created by guduzhonglao on 7/25/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
/// apns消息模型
class APNSDaataModel: HandyJSON {
    /// 发送方ID
    var f:String?
    /// 接收方ID
    var t:String?
    /// 消息ID
    var m:String?
    /// w群组ID
    var g:String?
    required init() {
        
    }
}
