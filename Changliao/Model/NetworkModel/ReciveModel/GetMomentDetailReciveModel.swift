//
//  GetMomentDetailReciveModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit
import HandyJSON

class MomentUserData: HandyJSON {
    var user_name:String?
    var portrait:String?
    var id_card:String?
    required init() {
        
    }
}

class MomentDetailData: HandyJSON {
    var circle_id:String?
    var create_time:String?
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
    var commentsList:[CommentData?]?
    var likeList:[LikeData?]?
    var circleUser:MomentUserData?
    var ossfileprefixurl:String?
    required init() {
        
    }
}

class GetMomentDetailReciveModel: BaseReciveModel {
    
    var data:MomentDetailData?

}
