//
//  GroupInfo.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation

class GroupInfoSendModel: UserInfoSendModel {
    var group_id:String?
    init(groupID:String) {
        super.init()
        group_id = groupID
    }
    
    required init() {
        super.init()
    }
}
