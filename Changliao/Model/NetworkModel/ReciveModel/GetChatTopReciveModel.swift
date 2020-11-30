//
//  GetChatTopReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/21/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class ChatTapData: HandyJSON {
    var target_id:String?
    var type:Int?
    required init() {
        
    }
}

class GetChatTopReciveModel: BaseReciveModel {
    var data:[ChatTapData?]?
}
