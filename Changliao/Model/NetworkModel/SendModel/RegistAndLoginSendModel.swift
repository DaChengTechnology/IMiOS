//
//  RegistAndLoginSendModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/19/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import HandyJSON
class RegistAndLoginSendModel: HandyJSON {
    var type:Int
    var mobile:String?
    var password:String?
    required init() {
        type = 1
    }
}
