//
//  Get6LoginTraceReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 10/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
import HandyJSON

class GetLoginTraceData: HandyJSON {
    var create_time:String?
    var ipadd:String?
    var device:String?
    var content:String?
    required init() {
        
    }
}

class GetLoginTraceReciveModel: BaseReciveModel {
    var data:[GetLoginTraceData]?
}
