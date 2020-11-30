//
//  AdvertQueryReciveModel.swift
//  boxin
//
//  Created by guduzhonglao on 7/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON
class AdvertData: HandyJSON {
    var advert_id:String?
    var picture_url:String?
    required init() {
        
    }
}
class AdvertQueryReciveModel: BaseReciveModel {
    var data:[AdvertData?]?
}
