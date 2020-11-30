//
//  GroupNotifationModel.swift
//  boxin
//
//  Created by guduzhonglao on 7/30/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class GroupNotifationModel: HandyJSON {
    /// 群ID
    var group_id:String?
    /// 提示信息
    var msg:String?
    /// 群名称
    var group_name:String?
    /// 群头像
    var group_portrait:String?
    required init() {
        
    }
}
