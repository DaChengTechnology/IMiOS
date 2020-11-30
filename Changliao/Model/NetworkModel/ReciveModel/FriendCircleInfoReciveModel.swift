//
//  FriendCircleInfoReciveModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 2/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import HandyJSON

class CommentReplyData: HandyJSON {
    var friend_name:String?
    var reply_id:String?
    var create_time:String?
    var to_reply_id:String?
    var comment_id:String?
    var comment:String?
    var user_id:String?
    var reply_name:String?
    required init() {
        
    }
}

class CommentData: HandyJSON {
    var comments_id:String?
    var comment:String?
    var friend_name:String?
    var user_id:String?
    var circle_id:String?
    var replyList:[CommentReplyData?]?
    required init() {
        
    }
}

class LikeData: HandyJSON {
    var user_id:String?
    var circle_id:String?
    var like_id:String?
    var friend_name:String?
    required init() {
        
    }
}

class FriendCircleData: HandyJSON {
    var circle_id:String?
    var create_time:String?
    var user_id:String?
    var user_name:String?
    var portrait:String?
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
    required init() {
        
    }
}

class FriendCircleInfoReciveModel: BaseReciveModel {
    var data:[FriendCircleData?]?
}
