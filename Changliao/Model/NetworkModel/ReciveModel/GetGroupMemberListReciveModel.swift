//
//  GetGroupMemberListReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

@objc class GroupMemberData:NSObject, HandyJSON {
    /// 用户ID
    @objc var user_id:String?
    /// 是否管理员
    @objc var is_administrator:Int = 2
    /// 头像
    @objc var portrait:String?
    /// 群昵称
    @objc var group_user_nickname:String?
    @objc var group_id:String?
    @objc var is_shield:Int = 2
    @objc var is_manager:Int = 2
    @objc var id_card:String?
    @objc var user_name:String?
    @objc var friend_name:String?
    @objc var inv_name:String?
    required override init() {
        
    }
}
class GetGroupMemberListReciveModel: BaseReciveModel {
    var data:[GroupMemberData?]?
}
