//
//  GroupSendViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/26/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SVProgressHUD
import Alamofire

class GroupSendViewController: ChatViewController {
    
    var userNameString:String?
    var userIDs:[String]?
    var complete:Int = 0

    override func viewDidLoad() {
        groupSend = true
        super.viewDidLoad()
        showRefreshHeader = false
        chatBarMoreView.removeItematIndex(4)
        chatBarMoreView.removeItematIndex(3)

        // Do any additional setup after loading the view.
        let bkView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        bkView.backgroundColor = UIColor.white
        self.view.addSubview(bkView)
        bkView.mas_makeConstraints { (make) in
            make?.left.equalTo()(tableView.mas_left)
            make?.top.equalTo()(tableView.mas_top)?.offset()(16)
            make?.right.equalTo()(tableView.mas_right)
            make?.bottom.lessThanOrEqualTo()(self.chatToolbar.mas_top)?.offset()(-16)
        }
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nameLabel.text = String(format: "您将发消息给%d位好友", userIDs!.count)
        nameLabel.textColor = UIColor.gray
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        bkView.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(bkView.mas_left)?.offset()(16)
            make?.top.equalTo()(bkView.mas_top)?.offset()(16)
            make?.right.equalTo()(bkView.mas_right)?.offset()(-16)
        }
        let nameTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nameTextView.isEditable = false
        nameTextView.font = UIFont.systemFont(ofSize: 17)
        nameTextView.text = userNameString
        nameTextView.isScrollEnabled = true
        bkView.addSubview(nameTextView)
        var height = DCUtill.ga_heightForComment(str: userNameString ?? ""
            , fontSize: 17, width: tableView.bounds.width - 32)
        height = height < tableView.bounds.height - 32 ? height : tableView.bounds.height - 32
        nameTextView.mas_makeConstraints { (make) in
            make?.left.equalTo()(bkView.mas_left)?.offset()(16)
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(4)
            make?.right.equalTo()(bkView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(height)
            make?.bottom.equalTo()(bkView.mas_bottom)?.offset()(-2)
        }
        self.title = "群发"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.DidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    override func moreView(_ moreView: EaseChatBarMoreView!, didItemInMoreViewAt index: Int) {
        if index == 3 {
            self.chatToolbar.endEditing(true)
            self.moreViewFileTransferAction(moreView)
        }
    }
    
    
    override func send(_ message: EMMessage!, isNeedUploadFile isUploadFile: Bool) {
        chatToolbar.endEditing(true)
        sendGroup(message.body, ext: message?.ext)
    }
    
    func sendGroup(_ body:EMMessageBody, ext:[AnyHashable:Any]?) {
        SVProgressHUD.showProgress(0)
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.networkState != NetworkReachabilityManager.NetworkReachabilityStatus.reachable(.ethernetOrWiFi) && app.networkState != NetworkReachabilityManager.NetworkReachabilityStatus.reachable(.wwan)  {
            self.view.makeToast("请链接互联网")
            SVProgressHUD.dismiss()
            return
        }
        var body1 = body
        if let b1 = body as? EMTextMessageBody {
            if !(ext?["jpzim_is_big_expression"] as? Bool ?? false) {
                body1 = EMTextMessageBody(text: "\(DCEncrypt.Encoade_AES(strToEncode: b1.text))_encode")
            }
        }
        var dic:[String:Any?] = Dictionary(dictionaryLiteral: ("AllMsg",true))
        var data1 = Array<MessageDeleteModel>()
        for user in userIDs! {
            friend = BoXinUtil.getFriendModel(user)
            var ext1 = ext
            if ext1 == nil {
                ext1 = ["em_apns_ext":"{em_oppo_push_channel_id:\"chuangliao_notification\"}"]
            }else{
                ext1?["em_apns_ext"] = "{em_oppo_push_channel_id:\"chuangliao_notification\"}"
            }
            ext1?["JPZIsFrom"] = "Chat"
            ext1?["JPZUserPortrait"] = data?.db?.portrait
            ext1?["JPZUserNikeName"] = data?.db?.user_name
            if friend == nil {
                let dat = QueryFriend.shared.queryStronger(id: conversation.conversationId)
                ext1?["JPZReceivePortrait"] = dat?.portrait
                ext1?["JPZReceiveNikeName"] = dat?.name
            }else{
                ext1?["JPZReceivePortrait"] = friend?.portrait
                ext1?["JPZReceiveNikeName"] = friend?.friend_self_name
            }
            ext1?["isFired"] = friend?.is_yhjf ?? 0
            let msg = EMMessage(conversationID: user, from: data?.db?.user_id, to: user, body: body1, ext: ext1)
            friend = nil
            EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                
            }, completion: { (msg, e) in
                if let conversation = EMClient.shared()?.chatManager.getConversation(user, type: EMConversationTypeChat, createIfNotExist: true) {
                    var err:EMError?
                    conversation.deleteMessage(withId: msg?.messageId, error: &err)
                    print(err)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                }
                let msa = MessageDeleteModel()
                msa.userid = user
                msa.mesasageId = msg?.messageId
                data1.append(msa)
                self.complete += 1
                SVProgressHUD.showProgress(Float(self.complete/self.userIDs!.count))
                if self.complete == self.userIDs!.count {
                    dic.updateValue(data1.toJSONString(), forKey: "own")
                    let cmd = EMCmdMessageBody(action: "")
                    let msg1 = EMMessage(conversationID: EMClient.shared()!.currentUsername, from: EMClient.shared()!.currentUsername, to: EMClient.shared()!.currentUsername, body: cmd, ext: dic)
                    EMClient.shared()?.chatManager.send(msg1, progress: { (p) in
                        
                    }, completion: { (m, e) in
                        SVProgressHUD.dismiss()
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
