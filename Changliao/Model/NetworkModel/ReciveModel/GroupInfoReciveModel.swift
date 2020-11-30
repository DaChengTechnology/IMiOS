//
//  GroupInfoReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class GroupInfoData: HandyJSON {
    var administrator_id:String?
    var group_portrait:String?
    var create_time:String?
    var group_name:String?
    var group_id:String?
    var is_admin:Int?
    var is_manager:Int?
    var is_pingbi:Int?
    var notice:String?
    var group_type:Int?
    var is_all_banned:Int?
    var groupUserSum:Int?
    var focusList:[FocusData?]?
    required init() {
        
    }
}

class FocusData: HandyJSON {
    var group_id:String?
    var user_id:String?
    var target_user_id:String?
    var groupuserfocus_id:String?
    required init() {
        
    }
}

class GroupInfoReciveModel: BaseReciveModel {
    var data:GroupInfoData?
    required init() {
        
    }
}
