//
//  QueryFriends.swift
//  boxin
//
//  Created by guduzhonglao on 6/11/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import SQLite
import Foundation

let db = try! Connection(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"/db.sqlite3")

class QueryFriend {
    
    let User = Table("users")
    let user_id = Expression<String>("user_id")
    let nick_name = Expression<String>("nick_name")
    let portrait = Expression<String>("portrait")
    let administrator_id = Expression<String>("administrator_id")
    let Group = Table("group")
    let group_id = Expression<String>("group_id")
    let is_administrator = Expression<Int>("is_administrator")
    let GroupUser = Table("GroupUser")
    let is_admin = Expression<Int>("is_admin")
    let is_manager = Expression<Int>("is_manager")
    let target_user_id = Expression<String>("target_user_id")
    let is_shield = Expression<Int>("is_shield")
    let notice = Expression<String?>("notice")
    let FocusTable = Table("FocusTable")
    let Stranger = Table("Stranger")
    let group_type = Expression<Int>("group_type")
    let is_all_banned = Expression<Int>("is_all_banned")
    let is_pingbi = Expression<Int>("is_pingbi")
    let name = Expression<String>("name")
    let id_card = Expression<String>("id_card")
    let user_name = Expression<String>("user_name")
    let friend_name = Expression<String?>("friend_name")
    let inv_name = Expression<String?>("inv_name")
    let FaceTable = Table("FaceTable")
    let FaceURL = Expression<String?>("FaceURL")
    let FaceLocal = Expression<String?>("FaceLocal")
    let GroupTemp = Table("GroupTemp")
    let ChatBK = Table("ChatBK")
    let faceW = Expression<Int?>("faceW")
    let faceH = Expression<Int?>("faceH")
    let is_star = Expression<Int>("is_star")
    let is_yhjf = Expression<Int>("is_yhjf")
    let groupUserSum = Expression<Int>("groupUserSum")
    
    private init(){
        do {
            try db.run(User.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(user_id)
                t.column(nick_name)
                t.column(portrait)
                t.column(id_card)
                t.column(friend_name)
                t.column(is_shield)
                t.column(is_star)
                t.column(is_yhjf)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(Group.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(user_id)
                t.column(nick_name)
                t.column(portrait)
                t.column(administrator_id)
                t.column(is_admin)
                t.column(is_manager)
                t.column(notice)
                t.column(is_pingbi)
                t.column(is_all_banned)
                t.column(group_type)
                t.column(groupUserSum)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(GroupUser.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(user_id)
                t.column(nick_name)
                t.column(portrait)
                t.column(group_id)
                t.column(is_administrator)
                t.column(is_shield)
                t.column(is_manager)
                t.column(id_card)
                t.column(user_name)
                t.column(friend_name)
                t.column(inv_name)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(FocusTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(group_id)
                t.column(user_id)
                t.column(target_user_id)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(Stranger.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(user_id)
                t.column(nick_name)
                t.column(portrait)
                t.column(group_id)
                t.column(id_card)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(FaceTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(FaceURL)
                t.column(user_id)
                t.column(FaceLocal)
                t.column(faceH)
                t.column(faceW)
            }))
        }catch(let e)
        {
            print(e.localizedDescription)
        }
        do{
            try db.run(GroupTemp.create(temporary: false, ifNotExists: true, withoutRowid: false,block: { (t) in
                t.column(group_id)
                t.column(name)
                t.column(portrait)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            try db.run(ChatBK.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (t) in
                t.column(user_id)
                t.column(FaceURL)
            }))
        }catch(let e){
            print(e.localizedDescription)
        }
        checkDBUpdate()
    }
    static let shared = QueryFriend()
    
    func queryFriend(id:String) -> SQLData? {
        let d = User.filter(user_id == id)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let da = SQLData()
        da.name = res[0][nick_name]
        da.portrait = res[0][portrait]
        da.id = res[0][user_id]
        da.id_card = res[0][id_card]
        da.friend_name = res[0][friend_name]
        return da
    }
    
    func getAllFriend() -> [SQLData] {
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(User).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        var data = Array<SQLData>()
        for r in res {
            let da = SQLData()
            da.name = r[nick_name]
            da.portrait = r[portrait]
            da.id = r[user_id]
            da.id_card = r[id_card]
            da.friend_name = r[friend_name]
            data.append(da)
        }
        return data
    }
    
    func isNeedLoadGroup(id:String) -> Bool {
        let d = Group.filter(user_id == id)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e) {
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return true
        }
        return false
    }
    
    func queryGroup(id:String) -> GroupViewModel? {
        let d = Group.filter(user_id == id)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e) {
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let da = GroupViewModel()
        da.groupId = res[0][user_id]
        da.groupName = res[0][nick_name]
        da.portrait = res[0][portrait]
        da.administrator_id = res[0][administrator_id]
        da.is_admin = res[0][is_admin]
        da.is_menager = res[0][is_manager]
        da.notice = res[0][notice]
        da.group_type = res[0][group_type]
        da.is_pingbi = res[0][is_pingbi]
        da.is_all_banned = res[0][is_all_banned]
        da.groupUserSum = res[0][groupUserSum]
        return da
    }
    
    func addStranger(id:String,user_name:String,portrait1:String,card:String) {
        do{
            if try db.prepare(Stranger.filter(group_id == "self" && user_id == id)).filter({ (r) -> Bool in
                return true
            }).count > 0 {
                try db.run(Stranger.filter(group_id == "self" && user_id == id).update(nick_name <- user_name, portrait <- portrait1, id_card <- card))
            }else{
                try db.run(Stranger.insert(group_id <- "self", user_id <- id, nick_name <- user_name, portrait <- portrait1, id_card <- card))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func addFriend(id:String, nickName:String, portrait1:String, card:String) {
        do{
            if try db.prepare(User.filter(user_id == id)).filter({ (a) -> Bool in
                return true
            }).count >= 1 {
                try db.run(User.filter(user_id == id).update(nick_name <- nickName, portrait <- portrait1, id_card <- card))
                
            }else{
                try db.run(User.insert(user_id <- id,nick_name <- nickName, portrait <- portrait1, id_card <- card))
            }
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func addFriend(_ friend:FriendData) {
        guard let id = friend.user_id else {
            return
        }
        guard let friendName = friend.friend_self_name else {
            return
        }
        let nickName = friend.target_user_nickname ?? friendName
        guard let portrait1 = friend.portrait else {
            return
        }
        guard let card = friend.id_card else {
            return
        }
         do{
            if try db.prepare(User.filter(user_id == id)).filter({ (a) -> Bool in
                       return true
                   }).count >= 1 {
                try db.run(User.filter(user_id == id).update(nick_name <- nickName, portrait <- portrait1, id_card <- card, friend_name <- friendName, is_shield <- friend.is_shield, is_star <- friend.is_star, is_yhjf <- friend.is_yhjf))
                       
                   }else{
                       try db.run(User.insert(user_id <- id,nick_name <- nickName, portrait <- portrait1, id_card <- card, friend_name <- friendName, is_shield <- friend.is_shield, is_star <- friend.is_star, is_yhjf <- friend.is_yhjf))
                   }
               }catch(let e) {
                   print(e.localizedDescription)
               }
    }
    
    func getFriend(UserId:String) -> FriendData? {
        let d = User.filter(user_id == UserId)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let friend = FriendData()
        friend.user_id = UserId
        friend.friend_self_name = res[0][friend_name]
        friend.target_user_nickname = res[0][nick_name]
        friend.portrait = res[0][portrait]
        friend.id_card = res[0][id_card]
        friend.is_shield = res[0][is_shield]
        friend.is_star = res[0][is_star]
        friend.is_yhjf = res[0][is_yhjf]
        return friend
    }
    
    func checkFriend(userID:String) -> Bool {
        do{
            if try db.prepare(User.filter(user_id == userID)).filter({ (a) -> Bool in
                return true
            }).count >= 1 {
                return true
                
            }
        }catch(let e) {
            print(e.localizedDescription)
        }
        return false
    }
    
    func deleteFriend(id:String) {
        do{
            try db.run(User.filter(user_id == id).delete())
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func addGroup(id:String, nickName:String, portrait1:String, admin_id:String, is_admin1:Int, is_mg:Int, notice1:String?, type:Int, allMute:Int, pingbi:Int,userSum:Int) {
        
        do{
            if try db.prepare(Group.filter(user_id == id)).filter({ (a) -> Bool in
                return true
            }).count >= 1 {
                try db.run(Group.filter(user_id == id).update(nick_name <- nickName, portrait <- portrait1, administrator_id <- admin_id, is_admin <- is_admin1, is_manager <- is_mg, notice <- notice1, group_type <- type, is_pingbi <- pingbi, is_all_banned <- allMute, groupUserSum <- userSum))
            }else{
                try db.run(Group.insert(user_id <- id,nick_name <- nickName, portrait <- portrait1, administrator_id <- admin_id, is_admin <- is_admin1, is_manager <- is_mg, notice <- notice1, group_type <- type, is_pingbi <- pingbi, is_all_banned <- allMute, groupUserSum <- userSum))
            }
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func addGroupTemp(group:GetMyGroupData?) {
        if group?.group_id == nil {
            return
        }
        if group?.group_name == nil {
            return
        }
        var res = Array<Row>()
        do{
            res = try db.prepare(GroupTemp.filter(group_id == group!.group_id!)).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count > 0 {
            do{
                try db.run(GroupTemp.filter(group_id == group!.group_id!).update(name <- group!.group_name!, portrait <- group!.group_portrait!))
            }catch(let e){
                print(e.localizedDescription)
            }
        }else{
            do{
                try db.run(GroupTemp.insert(group_id <- group!.group_id!, name <- group!.group_name!, portrait <- group!.group_portrait!))
            }catch(let e){
                print(e.localizedDescription)
            }
        }
    }
    
    func clearGroupTemp() {
        do{
            try db.run(GroupTemp.delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func getGroupName(id:String) -> String? {
        var res = Array<Row>()
        do{
            res = try db.prepare(GroupTemp.filter(group_id == id)).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count > 0 {
            return res[0][name]
        }
        return nil
    }
    
    func getAllGroup() -> [GroupViewModel] {
        var res = Array<Row>()
        do{
            res = try db.prepare(Group).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        var data = Array<GroupViewModel>()
        for r in res {
            let d = GroupViewModel()
            d.groupId = r[user_id]
            d.groupName = r[nick_name]
            d.administrator_id = r[administrator_id]
            d.portrait = r[portrait]
            d.is_admin = r[is_admin]
            d.is_menager = r[is_manager]
            d.notice = r[notice]
            d.group_type = r[group_type]
            d.is_all_banned = r[is_all_banned]
            d.is_pingbi = r[is_pingbi]
            d.groupUserSum = r[groupUserSum]
            data.append(d)
        }
        return data
    }
    
    func deleteGroup(id:String) {
        do{
            try db.run(Group.filter(user_id == id).delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func clearFriend() {
        do{
            try db.run(User.delete())
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func clearGroup() {
        do{
            try db.run(Group.delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func clearGroupUser() {
        do{
            try db.run(GroupUser.delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func deleteGroupMember(id:String) {
        do{
            try db.run(GroupUser.filter(group_id == id).delete())
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func addGroupUser(model:GroupMemberData?) {
        if model == nil {
            return
        }
        if model?.user_id == nil {
            return
        }
        if model?.group_id == nil {
            return
        }
        if model?.group_user_nickname == nil {
            return
        }
        if model?.portrait == nil {
            return
        }
        if model?.is_administrator == nil {
            return
        }
        if model?.is_manager == nil {
            return
        }
        if model?.is_shield == nil {
            return
        }
        if model?.id_card == nil {
            return
        }
        if model?.user_name == nil {
            return
        }
//        objc_sync_enter(threadObj)
        do{
            if try db.prepare(GroupUser.filter(user_id == model!.user_id! && group_id == model!.group_id!)).filter({ (a) -> Bool in
                return true
            }).count >= 1 {
                try db.run(GroupUser.filter(user_id == model!.user_id!).filter(group_id == model!.group_id!).delete())
                try db.run(GroupUser.insert(user_id <- model!.user_id! , group_id <- model!.group_id!, nick_name <- model!.group_user_nickname!, portrait <- model!.portrait!, is_administrator <- model!.is_administrator, is_shield <- model!.is_shield, is_manager <- model!.is_manager, id_card <- model!.id_card!,user_name <- model!.user_name!, friend_name <- model!.friend_name, inv_name <- model?.inv_name))
                return
            }else{
                try db.run(GroupUser.insert(user_id <- model!.user_id! , group_id <- model!.group_id!, nick_name <- model!.group_user_nickname!, portrait <- model!.portrait!, is_administrator <- model!.is_administrator, is_shield <- model!.is_shield, is_manager <- model!.is_manager, id_card <- model!.id_card!,user_name <- model!.user_name!, friend_name <- model!.friend_name, inv_name <- model?.inv_name))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
//        objc_sync_exit(threadObj)
    }
    
    func getGroupUser(userId:String,groupId:String) -> GroupMemberData? {
        let d = GroupUser.filter(user_id == userId && group_id == groupId)
        var res = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let da = GroupMemberData()
        da.group_id = res[0][group_id]
        da.user_id = res[0][user_id]
        da.group_user_nickname = res[0][nick_name]
        da.portrait = res[0][portrait]
        da.is_administrator = res[0][is_administrator]
        da.is_manager = res[0][is_manager]
        da.is_shield = res[0][is_shield]
        da.id_card = res[0][id_card]
        da.user_name = res[0][user_name]
        da.friend_name = res[0][friend_name]
        da.inv_name = res[0][inv_name]
        return da
    }
    
    func getGroupMembers(groupId:String) -> [GroupMemberData?]? {
        let d = GroupUser.filter(group_id == groupId)
        var res = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        var arr = Array<GroupMemberData?>()
        for r in res {
            let da = GroupMemberData()
            da.group_id = r[group_id]
            da.user_id = r[user_id]
            da.group_user_nickname = r[nick_name]
            da.portrait = r[portrait]
            da.is_administrator = r[is_administrator]
            da.is_shield = r[is_shield]
            da.is_manager = r[is_manager]
            da.id_card = r[id_card]
            da.user_name = r[user_name]
            da.friend_name = r[friend_name]
            da.inv_name = r[inv_name]
            arr.append(da)
        }
        return arr
    }
    
    func deleteGroupUser(userId:String,groupId:String) {
        do{
            try db.run(GroupUser.filter(user_id == userId && group_id == groupId).delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func clearFocus() {
        do{
            try db.run(FocusTable.delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func addFocus(groupId:String,id:String,target:String) {
        do{
            if try db.prepare(FocusTable.filter(target_user_id == target).filter(group_id == groupId)).filter({ (a) -> Bool in
                return true
            }).count >= 1 {
                return
            }else{
                try db.run(FocusTable.insert(user_id <- id, group_id <- groupId, target_user_id <- target))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func queryFocus(id:String, groupId:String) -> [String]? {
        let d = FocusTable.filter(group_id == groupId)
        var res = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        var arr = Array<String>()
        for r in res {
            arr.append(r[target_user_id])
        }
        return arr
    }
    
    func deleteFocus(userId:String, groupId:String) {
        do{
            try db.run(FocusTable.filter(target_user_id == userId).filter(group_id == groupId).delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func deleteFocus(groupId:String) {
        do{
            try db.run(FocusTable.filter(group_id == groupId).delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    
    func checkFocus(userId:String, groupId:String) -> Bool {
        let d = FocusTable.filter(group_id == groupId && target_user_id == userId && user_id == EMClient.shared()!.currentUsername)
        var res = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return false
        }
        return true
    }
    
    func addStronger(member:GroupMemberData) {
        if member.group_id == nil {
            return
        }
        if member.user_id == nil {
            return
        }
        if member.user_name == nil{
            return
        }
        if member.portrait == nil {
            return
        }
        if member.id_card == nil {
            return
        }
        do{
            if try db.prepare(Stranger.filter(group_id == member.group_id! && user_id == member.user_id!)).filter({ (r) -> Bool in
                return true
            }).count > 0 {
                try db.run(Stranger.filter(group_id == member.group_id! && user_id == member.user_id!).update(nick_name <- member.user_name!, portrait <- member.portrait!, id_card <- member.id_card!))
            }else{
                try db.run(Stranger.insert(user_id <- member.user_id!, group_id <- member.group_id!, nick_name <- member.user_name!, portrait <- member.portrait!, id_card <- member.id_card!))
            }
        }catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func queryStronger(groupId:String,id:String) -> SQLData? {
        let d = Stranger.filter(user_id == id && groupId == group_id)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let da = SQLData()
        da.name = res[0][nick_name]
        da.portrait = res[0][portrait]
        da.id = res[0][user_id]
        da.id_card = res[0][id_card]
        return da
    }
    
    func queryStronger(id:String) -> SQLData? {
        let d = Stranger.filter(user_id == id)
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(d.filter(group_id == "self")).filter({ (r) -> Bool in
                return true
            })
            if res.count > 0 {
                let da = SQLData()
                da.name = res[0][nick_name]
                da.portrait = res[0][portrait]
                da.id = res[0][user_id]
                da.id_card = res[0][id_card]
                return da
            }
            res = try db.prepare(d).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count < 1 {
            return nil
        }
        let da = SQLData()
        da.name = res[0][nick_name]
        da.portrait = res[0][portrait]
        da.id = res[0][user_id]
        da.id_card = res[0][id_card]
        return da
    }
    func AddFace(id:String) {
        do
        {
            try db.run(FaceTable.insert(user_id <- id))
            
        }catch (let e)
        {
            print(e.localizedDescription)
        }
    }
    
    func updateFace(model:FaceViewModel) {
        do{
            try db.run(FaceTable.filter(user_id == model.id!).update(FaceURL <- model.url!,FaceLocal <- model.path,faceW <- model.faceW, faceH <- model.faceH))
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    func GetAllFace() -> [FaceViewModel] {
        var data = Array<FaceViewModel>()
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(FaceTable).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        for d in res
        {
            let f = FaceViewModel()
            f.id = d[user_id]
            f.url = d[FaceURL]
            f.path = d[FaceLocal]
            f.faceH = d[faceH] ?? 0
            f.faceW = d[faceW] ?? 0
            data.append(f)
        }
        return data
    }
    
    func checkFace(id:String) -> Bool {
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(FaceTable.filter(user_id == id)).filter({ (a) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count > 0 {
            if let path = res[0][FaceLocal] {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
        }
        return false
    }
    
    func deleteFace(id:String) {
        do{
            try db.run(FaceTable.filter(user_id == id).delete())
        }catch(let e){
            print(e.localizedDescription)
        }
    }
    func cleanFace()  {
        do{
            try db.run(FaceTable.delete())
        }catch (let e)
        {
            print(e.localizedDescription)
        }
        
    }
    
    func cleanChatBK() {
        do{
            try db.run(ChatBK.delete())
        }catch (let e)
        {
            print(e.localizedDescription)
        }
    }
    
    func addChatBK(_ conversationId:String?, _ bk:String?) {
        dbQuese.async {
            guard let id = conversationId else{
                return
            }
            do{
                let res = try db.prepare(self.ChatBK.filter(self.user_id == id)).filter({ (b) -> Bool in
                    return true
                })
                if res.count > 0 {
                    try db.run(self.ChatBK.filter(self.user_id == id).update(self.FaceURL <- bk))
                }else{
                    try db.run(self.ChatBK.insert(self.user_id <- id, self.FaceURL <- bk))
                }
            }catch (let e)
            {
                print(e.localizedDescription)
            }
        }
    }
    
    func getChatBK(_ conversationId:String) -> String? {
        var res:[Row] = Array<Row>()
        do{
            res = try db.prepare(ChatBK.filter(user_id == conversationId)).filter({ (b) -> Bool in
                return true
            })
        }catch(let e){
            print(e.localizedDescription)
        }
        if res.count > 0 {
            return res[0][FaceURL]
        }
        return nil
    }
    
    func checkDBUpdate() {
        do{
            if try db.exists(column: "user_id", in: "users") == false {
                try db.run(User.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "nick_name", in: "users") == false {
                try db.run(User.addColumn(nick_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "portrait", in: "users") == false {
                try db.run(User.addColumn(portrait, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "id_card", in: "users") == false {
                try db.run(User.addColumn(id_card, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "friend_name", in: "users") == false {
                try db.run(User.addColumn(friend_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_shield", in: "users") == false {
                try db.run(User.addColumn(is_shield, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_star", in: "users") == false {
                try db.run(User.addColumn(is_star, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_yhjf", in: "users") == false {
                try db.run(User.addColumn(is_yhjf, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "portrait", in: "group") == false {
                try db.run(Group.addColumn(portrait, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "group") == false {
                try db.run(Group.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "nick_name", in: "group") == false {
                try db.run(Group.addColumn(nick_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_admin", in: "group") == false {
                try db.run(Group.addColumn(is_admin, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_manager", in: "group") == false {
                try db.run(Group.addColumn(is_manager, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "administrator_id", in: "group") == false {
                try db.run(Group.addColumn(administrator_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "notice", in: "group") == false {
                try db.run(Group.addColumn(notice))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "group_type", in: "group") == false {
                try db.run(Group.addColumn(group_type, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_all_banned", in: "group") == false {
                try db.run(Group.addColumn(is_all_banned, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_pingbi", in: "group") == false {
                try db.run(Group.addColumn(is_pingbi, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "groupUserSum", in: "group") == false {
                try db.run(Group.addColumn(groupUserSum, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "nick_name", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(nick_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "portrait", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(portrait, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "group_id", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(group_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_shield", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(is_shield, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_administrator", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(is_administrator, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "is_manager", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(is_manager, defaultValue: 2))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "id_card", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(id_card, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_name", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(user_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "friend_name", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(friend_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "inv_name", in: "GroupUser") == false {
                try db.run(GroupUser.addColumn(inv_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "FocusTable") == false {
                try db.run(FocusTable.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "group_id", in: "FocusTable") == false {
                try db.run(FocusTable.addColumn(group_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "target_user_id", in: "FocusTable") == false {
                try db.run(FocusTable.addColumn(target_user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "Stranger") == false {
                try db.run(Stranger.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "group_id", in: "Stranger") == false {
                try db.run(Stranger.addColumn(group_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "portrait", in: "Stranger") == false {
                try db.run(Stranger.addColumn(portrait, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "nick_name", in: "Stranger") == false {
                try db.run(Stranger.addColumn(nick_name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "id_card", in: "Stranger") == false {
                try db.run(Stranger.addColumn(id_card, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "FaceURL", in: "FaceTable") == false {
                try db.run(FaceTable.addColumn(FaceURL, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "FaceLocal", in: "FaceTable") == false {
                try db.run(FaceTable.addColumn(FaceLocal))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "faceH", in: "FaceTable") == false {
                try db.run(FaceTable.addColumn(faceH))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "faceW", in: "FaceTable") == false {
                try db.run(FaceTable.addColumn(faceW))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "GroupTemp") == false {
                try db.run(GroupTemp.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "name", in: "GroupTemp") == false {
                try db.run(GroupTemp.addColumn(name, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "portrait", in: "GroupTemp") == false {
                try db.run(GroupTemp.addColumn(portrait, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "user_id", in: "ChatBK") == false {
                try db.run(ChatBK.addColumn(user_id, defaultValue: ""))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
        do{
            if try db.exists(column: "FaceURL", in: "ChatBK") == false {
                try db.run(ChatBK.addColumn(FaceURL))
            }
        }catch(let e){
            print(e.localizedDescription)
        }
    }
}


