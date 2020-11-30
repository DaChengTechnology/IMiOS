//
//  BankCardListReciveModel.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/26/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import HandyJSON

class BankCardData: HandyJSON {
    var bank_pic:String?
    var real_name:String?
    var bank_name:String?
    var card_name:String?
    var bank_card_state:Int = 1
    var bank_card_id:String?
    var bank_card_number:String?
    required init() {
        
    }
}

class BankCardListReciveModel: BaseReciveModel {
    var data:[BankCardData?]?
}
