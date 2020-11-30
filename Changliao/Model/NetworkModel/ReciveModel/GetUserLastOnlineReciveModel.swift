//
//  GetUserLastOnlineReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 10/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class GetUserLastOnlineData: HandyJSON {
    var time:String?
    var status:Int?
    required init() {
        
    }
}

class GetUserLastOnlineReciveModel: BaseReciveModel {
    var data:GetUserLastOnlineData?
}
