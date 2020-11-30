//
//  GroupShakeViewController.swift
//  boxin
//
//  Created by guduzhonglao on 8/20/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

class GroupShakeViewController: UIViewController {
    
    var groupId:String?
    var groupName:String?
    var groupOwnerName:String?
    var ringPlayer:AVAudioPlayer?
    var grade:String?
    @IBOutlet weak var groupOwnerLabel: UILabel!
    
    @IBOutlet weak var groupHeadImageView: UIImageView!
    @IBOutlet weak var groupTipsLabel: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var groupAnimateImaageview: UIImageView!
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let id = groupId {
            let group = QueryFriend.shared.queryGroup(id: id)
            groupHeadImageView.sd_setImage(with: URL(string: group?.portrait ?? ""), placeholderImage: UIImage(named: "群主"), options: .retryFailed, context: nil)
            groupHeadImageView.layer.cornerRadius = 50
            groupHeadImageView.layer.shadowOpacity = 0.5
            groupHeadImageView.layer.borderWidth = 1.5
            groupHeadImageView.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "fe6726").cgColor
            groupHeadImageView.layer.shadowColor = UIColor.hexadecimalColor(hexadecimal: "c43a00").cgColor
            let attrString = NSMutableAttributedString(string: groupOwnerName ?? "")
            groupOwnerLabel.frame = CGRect(x: 120, y: 69, width: 134, height: 25)
            groupOwnerLabel.numberOfLines = 0
            let shadow = NSShadow()
            shadow.shadowColor = UIColor(red:0.15,green:0.02,blue:0.02,alpha:0.56)
            shadow.shadowBlurRadius = 5
            shadow.shadowOffset = CGSize(width: 0, height: 2)
            groupName = group?.groupName
            let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 27),.foregroundColor: UIColor(red: 1, green: 1, blue: 1,alpha:1), .shadow: shadow]
            attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
            groupOwnerLabel.attributedText = attrString
            let attr1 = NSMutableAttributedString(string: "来自群\"\(group?.groupName ?? "")\"的抖一抖")
            let attr2: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 18),.foregroundColor: UIColor(red: 0.96, green: 0.42, blue: 0.4,alpha:1)]
            attr1.addAttributes(attr2, range: NSRange(location: 0, length: attr1.length))
            groupTipsLabel.attributedText = attr1
            
            dismissBtn.sd_setImage(with: Bundle.main.url(forResource: "忽略0.1", withExtension: "gif"), for: .normal, completed: nil)
            goBtn.sd_setImage(with: Bundle.main.url(forResource: "抖一抖接听0.1", withExtension: "gif"), for: .normal, completed: nil)
            groupAnimateImaageview.sd_setImage(with: Bundle.main.url(forResource: "抖一抖4", withExtension: "gif"), completed: nil)
            let app = UIApplication.shared.delegate as! AppDelegate
            if app.player != nil {
                if app.player!.isPlaying {
                    app.player?.stop()
                }
            }
            if group?.is_pingbi == 2 {
                if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                    if UserDefaults.standard.string(forKey: "sound") == "1" {
                        do{
                            ringPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "shake", withExtension: "mp3")!)
                        }catch(let e){
                            print(e.localizedDescription)
                        }
                        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                        ringPlayer?.setVolume(1, fadeDuration: 0)
                        ringPlayer?.numberOfLoops = -1
                        if ringPlayer!.prepareToPlay() {
                            app.player = ringPlayer
                            ringPlayer?.play()
                        }
                    }
                }
            }
            timer.schedule(deadline: .now(), repeating: 1)
            timer.setEventHandler {
                DispatchQueue.main.async {
                    if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                        if UserDefaults.standard.string(forKey: "shake") == "1" {
                            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                        }
                    }
                }
            }
            if app.timer != nil {
                app.timer?.cancel()
            }
            app.timer = timer
            timer.resume()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ringPlayer?.stop()
        timer.cancel()
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismiss(animated: false) {
            let app = UIApplication.shared.delegate as? AppDelegate
            DispatchQueue.main.async {
                if let person = app?.person {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "PersonalShake") as! PersonalShakeViewController
                    vc.model = person
                    vc.modalPresentationStyle = .overFullScreen
                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                    app?.person = nil
                }
                if let apns = app?.apnsData {
                    if let group = apns.g {
                        if let chat = UIViewController.currentViewController() as? ChatViewController {
                            if chat.conversation.conversationId == group {
                                return
                            }
                            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                        }
                        UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                        let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
                        if let data = QueryFriend.shared.queryGroup(id: group) {
                            vc?.title = data.groupName
                        }else{
                            if let da = QueryFriend.shared.getGroupName(id: group){
                                vc?.title = da
                            }
                        }
                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                        app?.apnsData = nil
                    }else{
                        if let chat = UIViewController.currentViewController() as? ChatViewController {
                            if chat.conversation.conversationId == apns.f {
                                return
                            }
                            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                        }
                        UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                        let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
                        if apns.f != nil {
                            if let data = QueryFriend.shared.queryFriend(id: apns.f!) {
                                vc?.title = data.name
                            }else{
                                if let da = QueryFriend.shared.queryStronger(id: apns.f!) {
                                    vc?.title = da.name
                                }
                            }
                        }
                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                        app?.apnsData = nil
                    }
                }
            }
        }
    }
    
     @IBAction func onGo(_ sender: Any) {
        let groupid = groupId!
        if let name = groupName {
            self.dismiss(animated: false) {
                if let chat = UIViewController.currentViewController() as? ChatViewController {
                    if chat.conversation.conversationId == groupid && chat.conversation.type == EMConversationTypeGroupChat {
                        return
                    }
                    chat.navigationController?.navigationController?.popToRootViewController(animated: true)
                    
                }
                let vc = ChatViewController(conversationChatter: groupid, conversationType: EMConversationTypeGroupChat)
                UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                vc?.title = name
                UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
            }
        }else{
            BoXinUtil.getGroupOnlyInfo(groupId: groupid) { (b) in
                if b {
                    let group = QueryFriend.shared.queryGroup(id: groupid)
                    self.dismiss(animated: false) {
                        if let chat = UIViewController.currentViewController() as? ChatViewController {
                            if chat.conversation.conversationId == groupid && chat.conversation.type == EMConversationTypeGroupChat {
                                return
                            }
                            chat.navigationController?.navigationController?.popToRootViewController(animated: true)
                            
                        }
                        let vc = ChatViewController(conversationChatter: groupid, conversationType: EMConversationTypeGroupChat)
                        UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                        vc?.title = group?.groupName
                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else{
                    self.dismiss(animated: false, completion: {
                        let alert = UIAlertController(title: "没有查到该群信息", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                        alert.modalPresentationStyle = .overFullScreen
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
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
