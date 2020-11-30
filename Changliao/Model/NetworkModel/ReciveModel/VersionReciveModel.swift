//
//  VersionReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 8/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
class VersionData: HandyJSON {
    var apkUrl:String?
    var newVersion:String?
    required init() {
        
    }
}
class VersionReciveModel: BaseReciveModel {
    var data:VersionData?
}
