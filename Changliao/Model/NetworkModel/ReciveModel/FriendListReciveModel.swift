//
//  FriendList.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

@objc class FriendData: NSObject, HandyJSON {
    @objc   var is_shield:Int=2
    @objc   var user_id:String?
    @objc   var target_user_nickname:String?
    @objc   var is_star:Int = 2
    @objc   var portrait:String?
    @objc   var id_card:String?
    @objc   var friend_self_name:String?
    @objc   var is_yhjf:Int = 2
    required override init() {
        
    }
    
    init(data:GetUserData?) {
        is_star = 2
        is_shield = 2
        user_id = data?.user_id
        friend_self_name = data?.user_name
        portrait = data?.portrait
        id_card = data?.id_card
    }
    
    init(member:GroupMemberData?) {
        is_star = 2
        is_shield = 2
        is_yhjf = 2
        user_id = member?.user_id
        friend_self_name = member?.user_name
        portrait = member?.portrait
        id_card = member?.id_card
    }
}

class FriendListReciveModel: BaseReciveModel {
    var data:[FriendData?]?
    required init() {
        
    }
}
