//
//  LoginReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/8/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class LoginReciveData: HandyJSON {
    var username:String?
    var password:String?
    var nickname:String?
    var token:String?
    required init() {
        
    }
}

class LoginReciveModel: BaseReciveModel {
    var data:LoginReciveData?
    required init() {
        
    }
}
