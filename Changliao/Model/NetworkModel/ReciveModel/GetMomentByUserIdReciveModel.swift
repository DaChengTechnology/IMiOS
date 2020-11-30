//
//  GetMomentByUserIdReciveModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/24/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit
import HandyJSON

class MomentData: HandyJSON {
    var circle_id:String?
    var create_time:Double = 0
    var user_id:String?
    var content:String?
    var pic1:String?
    var pic2:String?
    var pic3:String?
    var pic4:String?
    var pic5:String?
    var pic6:String?
    var pic7:String?
    var pic8:String?
    var pic9:String?
    required init() {
        
    }
}

class GetMomentByUserIdReciveModel: BaseReciveModel {
    var data:[MomentData?]?
}
