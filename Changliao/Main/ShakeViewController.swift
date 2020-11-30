//
//  ShakeViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/20/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

@objc class ShakeViewController: UIViewController {

    @IBOutlet weak var goToGroupBtn: UIButton!
    @IBOutlet weak var DismissBtn: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headTittleLabel: UILabel!
    @IBOutlet weak var groupOwnerLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var LabelBg: UIView!
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var groupId:String?
    var groupName:String?
    var groupOwnerName:String?
    var ringPlayer:AVAudioPlayer?
    var grade:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.player != nil {
            if app.player!.isPlaying {
                app.player?.stop()
            }
        }
        ringPlayer?.stop()
        if groupId != nil
        {
                let group = QueryFriend.shared.queryGroup(id: groupId!)
                if group != nil
                {
                    headTittleLabel.text = "\"\(group!.groupName!)\" 的\(grade ?? "群主")"
                    groupOwnerLabel.text = groupOwnerName
                    groupName = group?.groupName
                    if group?.is_pingbi == 2 {
                        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                            if UserDefaults.standard.string(forKey: "sound") == "1" {
                                do{
                                    ringPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "shake", withExtension: "mp3")!)
                                }catch(let e){
                                    print(e.localizedDescription)
                                }
                                ringPlayer?.setVolume(1, fadeDuration: 0.3)
                                ringPlayer?.numberOfLoops = -1
                                if ringPlayer!.prepareToPlay() {
                                    app.player = ringPlayer
                                    ringPlayer?.play()
                                }
                            }
                        }
                    }
                }
            
        }

        // Do any additional setup after loading the view.
        
        DismissBtn.layer.masksToBounds = true
        DismissBtn.layer.cornerRadius = 48
        goToGroupBtn.layer.masksToBounds = true
        goToGroupBtn.layer.cornerRadius = 48
        LabelBg.layer.borderWidth = 1
        LabelBg.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "cbcbcb").cgColor
        LabelBg.layer.masksToBounds = true
        LabelBg.layer.cornerRadius = 15
    
        timer.schedule(deadline: .now(), repeating: 2)
        timer.setEventHandler {
            DispatchQueue.main.async {
                if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                    if UserDefaults.standard.string(forKey: "shake") == "1" {
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    }
                }
                UIView.animate(withDuration: 2, animations: {
                    let offset = (UIScreen.main.bounds.width - self.animationImageView.frame.width)/2
                    self.animationImageView.frame = CGRect(x: self.animationImageView.frame.minX - offset, y: self.animationImageView.frame.minY - offset, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                }, completion: { (b) in
                    if b {
                        self.animationImageView.frame = self.logo.frame
                    }
                })
            }
        }
        if app.timer != nil {
            app.timer?.cancel()
        }
        app.timer = timer
        timer.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationImageView.frame = logo.frame
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
    @IBAction func onGoToGroup(_ sender: Any) {
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
