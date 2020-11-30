//
//  GetUserInfoMenager.swift
//  boxin
//
//  Created by guduzhonglao on 11/20/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation

class GetUserInfoMenager {
    static let shard = GetUserInfoMenager()
    private var loadingList = Array<String>()
    private let queue = DispatchQueue(label: "cl.net.getUser")
    private let requstQueue:DispatchQueue
    
    private init () {
        requstQueue = DispatchQueue(label: "cl.net.userRequest", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    }
    
    func getUser(message:EMMessage, complite:@escaping (EMMessage?)->Void) {
        queue.async {
            if self.loadingList.contains(message.from) {
                complite(nil)
                return
            }
            if message.chatType == EMChatTypeGroupChat {
                self.requstQueue.async {
                    BoXinUtil.getGroupOneMember(groupID: message.conversationId, userID: message.from) { (b) in
                        if b {
                            complite(message)
                        }else{
                            complite(nil)
                        }
                        self.queue.async {
                            for (idx,obj) in self.loadingList.enumerated() {
                                if obj == message.from {
                                    self.loadingList.remove(at: idx)
                                    return
                                }
                            }
                        }
                    }
                }
                return
            }
            self.requstQueue.async {
                self.loadingList.append(message.from)
                let m = GetUserByIDSendModel()
                m.user_id = message.from
                BoXinProvider.request(.GetUserByID(model: m), callbackQueue: self.requstQueue) { (result) in
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            do{
                                if let mo = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(mo.code ?? 0) else {
                                        return
                                    }
                                    if mo.code == 200 {
                                        QueryFriend.shared.addStranger(id: mo.data!.user_id!, user_name: mo.data!.user_name!, portrait1: mo.data!.portrait!, card: mo.data!.id_card!)
                                        self.queue.async {
                                            for (idx,obj) in self.loadingList.enumerated() {
                                                if obj == message.from {
                                                    self.loadingList.remove(at: idx)
                                                    break
                                                }
                                            }
                                        }
                                        complite(message)
                                    }else{
                                        DispatchQueue.main.async {
                                            if mo.message == "请重新登录" {
                                                BoXinUtil.Logout()
                                                if (UIViewController.currentViewController() as? BootViewController) != nil {
                                                    let app = UIApplication.shared.delegate as! AppDelegate
                                                    app.isNeedLogin = true
                                                    return
                                                }
                                                if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPhoneViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPasswordViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is RegisterViewController {
                                                    return
                                                }
                                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                                let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                                vc.modalPresentationStyle = .overFullScreen
                                                UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                            }
                                            UIViewController.currentViewController()?.view.makeToast(mo.message)
                                        }
                                        self.queue.async {
                                            for (idx,obj) in self.loadingList.enumerated() {
                                                if obj == message.from {
                                                    self.loadingList.remove(at: idx)
                                                    break
                                                }
                                            }
                                        }
                                        complite(nil)
                                    }
                                }else{
                                    self.queue.async {
                                        for (idx,obj) in self.loadingList.enumerated() {
                                            if obj == message.from {
                                                self.loadingList.remove(at: idx)
                                                break
                                            }
                                        }
                                    }
                                    complite(nil)
                                }
                            }catch{
                                self.queue.async {
                                    for (idx,obj) in self.loadingList.enumerated() {
                                        if obj == message.from {
                                            self.loadingList.remove(at: idx)
                                            break
                                        }
                                    }
                                }
                                complite(nil)
                            }
                        }else{
                            self.queue.async {
                                for (idx,obj) in self.loadingList.enumerated() {
                                    if obj == message.from {
                                        self.loadingList.remove(at: idx)
                                        break
                                    }
                                }
                            }
                            complite(nil)
                        }
                    case .failure(let err):
                        for (idx,obj) in self.loadingList.enumerated() {
                            if obj == message.from {
                                self.loadingList.remove(at: idx)
                                break
                            }
                        }
                        complite(nil)
                        print(err.errorDescription!)
                    }
                }
            }
        }
    }
}
