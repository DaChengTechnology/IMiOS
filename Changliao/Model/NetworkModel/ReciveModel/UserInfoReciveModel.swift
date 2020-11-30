//
//  UserInfoReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class HXEntityData: HandyJSON {
    var created:Int?
    var modified:Int?
    var type:String?
    var uuid:String?
    var username:String?
    var activated:Bool?
    var nickname:String?
    required init() {
        
    }
}
class HXData: HandyJSON {
    var duration:Int?
    var path:String?
    var count:Int?
    var action:String?
    var url:String?
    var timestamp:Int?
    var entities:HXEntityData?
    required init() {
        
    }
}

class ServerData: HandyJSON {
    var pc_token:String?
    var create_time:String?
    var user_id:String?
    var user_name:String?
    var mobile:String?
    var is_del:Int?
    var portrait:String?
    var cli_token:String?
    var id_card:String?
    required init() {
        
    }
}

class UserInfoData: HandyJSON {
    var hx:HXData?
    var db:ServerData?
    required init() {
        
    }
}

class UserInfoReciveModel: BaseReciveModel {
    var data:UserInfoData?
    required init() {
        
    }
}
