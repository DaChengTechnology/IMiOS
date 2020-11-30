//
//  GetMyGroupReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class GetMyGroupData: HandyJSON {
    var administrator_id:String?
    var group_portrait:String?
    var group_id:String?
    var group_name:String?
    var group_type:Int?
    required init() {
        
    }
    
    func toGroupModel() -> GroupViewModel {
        let g = GroupViewModel()
        g.groupId = group_id
        g.groupName = group_name
        g.group_type = group_type ?? 2
        g.portrait = group_portrait
        return g
    }
}

class GetMyGroupReciveModel: BaseReciveModel {
    var data:[GetMyGroupData?]?
}
