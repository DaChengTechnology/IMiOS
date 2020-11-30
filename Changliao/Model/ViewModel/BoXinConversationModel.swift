//
//  BoXinConversationModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class BoXinConversationModel: EaseConversationModel {
    
    var noTips:Bool
    var isTop:Bool
    var isGroupType:Bool
    var isOnLine:Bool
    var isYHJF:Bool
    
    required init!(conversation: EMConversation!) {
        noTips = false
        isTop = false
        isGroupType = false
        isOnLine = false
        isYHJF = false
        super.init(conversation: conversation)
        if conversation.type == EMConversationTypeChat {
            avatarImage = UIImage(named: "moren")
        }else{
            avatarImage = UIImage(named: "moren")
        }
    }

}
