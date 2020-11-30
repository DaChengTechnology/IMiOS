//
//  UserInfoSendModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
class UserInfoSendModel: HandyJSON {
    var token:String
    var client_type:Int
    required init() {
        token = UserDefaults.standard.string(forKey: "token") ?? ""
        client_type = 1
    }
}
