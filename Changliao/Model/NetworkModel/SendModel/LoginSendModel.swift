//
//  LoginSendModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/8/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class LoginSendModel: HandyJSON {
    var mobile:String?
    var type:Int
    var way_type:Int
    var password:String?
    required init(){
        type = 1
        way_type = 2
    }
}
