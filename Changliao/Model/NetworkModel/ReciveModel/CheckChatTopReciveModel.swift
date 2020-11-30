//
//  CheckChatTopReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class CheckChatData: HandyJSON {
    var user_id:String?
    var target_id:String?
    var typhe:Int?
    required init() {
        
    }
}

class CheckChatTopReciveModel: BaseReciveModel {
    var data:CheckChatData?
}
