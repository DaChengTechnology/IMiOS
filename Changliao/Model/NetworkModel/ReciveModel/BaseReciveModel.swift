//
//  BaseReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/8/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
class BaseReciveModel:HandyJSON {
    /// 状态码
    var code:Int?
    /// 消息
    var message:String?
    
    required init() {
        
    }
}

