//
//  GetFriendCircleReciveModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/9/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import HandyJSON

/// 我的朋友圈评论模型
class FCCommentData: HandyJSON {
    var friend_name:String?
    var comments_id:String?
    var circle_id:String?
    var create_time:String?
    var user_id:String?
    var comment:String?
    var is_friend:Int = 2
    required init() {
        
    }
}

/// 朋友圈点赞模型
class FCLikeData: HandyJSON {
    var friend_name:String?
    var like_id:String?
    var circle_id:String?
    var create_time:String?
    var user_id:String?
    var is_friend:Int = 2
    required init() {
        
    }
}

/// 我的朋友圈模型
class FriendCircleDataModel: HandyJSON {
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
    var likeList:[FCLikeData?]?
    var commentsList:[FCCommentData?]?
    required init() {
        
    }
}

class GetFriendCircleReciveModel: BaseReciveModel {
    
    var data:[FriendCircleData?]?

}
