//
//  SubmitConlectionReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 11/16/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class SubmitConlectionData: HandyJSON {
    var id:String?
    var time:Int64?
    var type:Int?
    var content:MessgaeData?
    required init() {
        
    }
}

class SubmitConlectionReciveModel: BaseReciveModel {
    var data:SubmitConlectionData?
}
