//
//  GetUserByIDReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/12/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class GetUserData: HandyJSON {
    var user_id:String?
    var user_name:String?
    var portrait:String?
    var id_card:String?
    var remark:String?
    required init() {
        
    }
}

class GetUserByIDReciveModel: BaseReciveModel {
    var data:GetUserData?
}
