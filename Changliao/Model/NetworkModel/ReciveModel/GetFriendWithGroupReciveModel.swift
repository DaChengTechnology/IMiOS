//
//  GetFriendWithGroupReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 11/13/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class FriendGroupData: HandyJSON{
    var fenzu_id:String?
    var fenzu_name:String?
    var feirnd_num:Int = 0
    var sort_num:Int = 0
    var friendList:[FriendData] = Array<FriendData>()
    var isShow:Bool = false
    required init() {
    }
}

class GetFriendWithGroupReciveModel: BaseReciveModel {
    var data:[FriendGroupData] = Array<FriendGroupData>()
}

class FriendGroupInfoData: HandyJSON {
    var fenzu_id:String?
    var fenzu_name:String?
    var sort_num:Int = 0
    required init() {
        
    }
}
