//
//  PersonalShakeViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/19/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage

class PersonalShakeViewController: UIViewController {
    
    @IBOutlet weak var Bgview: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    var model:SQLData?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    var ringPlayer:AVAudioPlayer?
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Bgview.layer.masksToBounds = true
        Bgview.layer.cornerRadius = 25
        Bgview.layer.borderWidth = 1
        Bgview.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "cbcbcb").cgColor
        // Do any additional setup after loading the view.
        do{
            gifImageView.showGifImage(with: try Data(contentsOf: Bundle.main.url(forResource: "dyd", withExtension: "gif")!))
        }catch(let e){
            print(e.localizedDescription)
        }
        nameLabel.text = model?.name
        tipsLabel.text = String(format: "'%@' 正在抖你", model!.name!)
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.player != nil {
            if app.player!.isPlaying {
                app.player?.stop()
            }
        }
        ringPlayer?.stop()
        guard let id = model?.id else {
            if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                if UserDefaults.standard.string(forKey: "sound") == "1" {
                    do{
                        ringPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "shake", withExtension: "mp3")!)
                    }catch(let e){
                        print(e.localizedDescription)
                    }
                    let av = AVAudioSession.sharedInstance()
                    try? av.overrideOutputAudioPort(.speaker)
                    try? av.setActive(true, options: .notifyOthersOnDeactivation)
                    ringPlayer?.volume = 1
                    ringPlayer?.numberOfLoops = -1
                    if ringPlayer!.prepareToPlay() {
                        app.player = ringPlayer
                        ringPlayer?.play()
                    }
                }
            }
            timer.schedule(deadline: .now(), repeating: 2)
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
            return
        }
        if let friend = BoXinUtil.getFriendModel(id) {
            if friend.is_shield == 1 {
                return
            }
        }
        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
            if UserDefaults.standard.string(forKey: "sound") == "1" {
                do{
                    ringPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "shake", withExtension: "mp3")!)
                }catch(let e){
                    print(e.localizedDescription)
                }
                let av = AVAudioSession.sharedInstance()
                try? av.overrideOutputAudioPort(.speaker)
                try? av.setActive(true, options: .notifyOthersOnDeactivation)
                ringPlayer?.volume = 1
                ringPlayer?.numberOfLoops = -1
                if ringPlayer!.prepareToPlay() {
                    app.player = ringPlayer
                    ringPlayer?.play()
                }
            }
        }
        timer.schedule(deadline: .now(), repeating: 2)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ringPlayer?.stop()
        timer.cancel()
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismiss(animated: false) {
            let app = UIApplication.shared.delegate as? AppDelegate
            DispatchQueue.main.async {
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
    
    @IBAction func onGoChat(_ sender: Any) {
        self.dismiss(animated: false) {
            let vc = ChatViewController(conversationChatter: self.model!.id!, conversationType: EMConversationTypeChat)
            UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            vc?.title = self.model?.name
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
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
