//
//  AllFaceListModel.swift
//  boxin
//
//  Created by Sea on 2019/7/15.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import HandyJSON

class FaceData: HandyJSON {
    var phiz_id:String?
    var phiz_url:String?
    var width:String?
    var high:String?
    required init() {
        
    }
}
class AllFaceListModel: BaseReciveModel {
    var data:[FaceData?]?

}
