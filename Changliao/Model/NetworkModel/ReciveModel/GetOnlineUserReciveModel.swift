//
//  GetOnlineUserReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 10/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
class OnlineUserData: HandyJSON {
    var id:String?
    required init() {
        
    }
}

class GetOnlineUserReciveModel: BaseReciveModel {
    var data:[OnlineUserData?]?
}
