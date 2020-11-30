//
//  LoadGroupMenaager.swift
//  boxin
//
//  Created by guduzhonglao on 7/30/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
class LoadGroupMenaager {
    static let shared = LoadGroupMenaager()
    private var maxRequest:Int = 4
    private var currtentRequest:Int = 0
    private var groupIDList:[String] = Array()
    var runningCount:Int{ return currtentRequest}
    
    private init() {
        
    }
    
    func addLoadGroup(id:String) {
        if currtentRequest < maxRequest {
            currtentRequest += 1
            BoXinUtil.getGroupInfo(groupId: id) { (b) in
                self.currtentRequest -= 1
                self.requestTemp()
            }
        }else{
            groupIDList.append(id)
        }
    }
    
    func requestTemp() {
        while currtentRequest < maxRequest && groupIDList.count > 1 {
            let groupID = groupIDList[0]
            groupIDList.remove(at: 0)
            currtentRequest += 1
            BoXinUtil.getGroupInfo(groupId: groupID) { (b) in
                self.currtentRequest -= 1
                self.requestTemp()
            }
        }
    }
}
