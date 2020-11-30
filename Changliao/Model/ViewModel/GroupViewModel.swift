//
//  GroupViewModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
@objc class GroupViewModel:NSObject {
    @objc var groupId:String?
    @objc var groupName:String?
    @objc var portrait:String?
    @objc var administrator_id:String?
    @objc var is_admin:Int = 2
    @objc var is_menager:Int = 2
    @objc var group_type:Int = 2
    @objc var is_all_banned:Int = 2
    @objc var is_pingbi:Int = 2
    @objc var notice:String?
    @objc var groupUserSum:Int = 0
}
