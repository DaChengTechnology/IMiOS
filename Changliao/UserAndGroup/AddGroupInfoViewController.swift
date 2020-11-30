//
//  AddGroupInfoViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/14/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddGroupInfoViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MGAvatarImageViewDelegate{
    func imageView(_ imageView: MGAvatarImageView!, didSelect image: UIImage!) {
        let data = image!.pngData()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        let savePath = path + String(format: "/signal/%@.png", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        do{
            if !FileManager.default.fileExists(atPath: path + "/signal") {
                try FileManager.default.createDirectory(atPath: path + "/signal", withIntermediateDirectories: true, attributes: nil)
            }
            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
        }catch{
            self.headPath = nil
            return
        }
        self.headPath = savePath
    }
    

    @IBOutlet weak var groupHeadImag: MGAvatarImageView!
    
    @IBOutlet weak var groupNameTextFeild: UITextField!
    @IBOutlet weak var table: UITableView!
    var headPath:String?
    var groupMember:[FriendData?]?
    var loading:Bool = false
    var groupType:Int = 2
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        groupHeadImag.delegate = self
        groupHeadImag.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action:#selector(getHead))
        groupHeadImag.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        let complite = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next"), style: .plain, target: self, action: #selector(onComplite))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
    }
    
    override func currentViewControllerShouldPop() -> Bool {
        if loading {
            self.navigationController?.popToRootViewController(animated: false)
            return false
        }
        return true
    }
    
    @objc func getHead() {
        if groupNameTextFeild.isFirstResponder {
            groupNameTextFeild.resignFirstResponder()
        }
        groupHeadImag.show()
    }
    
    @objc func onComplite() {
        if headPath == nil {
            let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: NSLocalizedString("PlzSelGroupAvatar",  comment: "please select group avatar"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if groupNameTextFeild.text == nil {
            let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: NSLocalizedString("PlzInputGroupName",  comment: "please input group name"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if groupNameTextFeild.text!.isEmpty {
            let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: NSLocalizedString("PlzInputGroupName",  comment: "please input group name"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if groupNameTextFeild.text!.count > 25 {
            let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: NSLocalizedString("GroupNameMin",  comment: "Group name cannot exceed 25 characters"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if loading {
            return
        }
        loading = true
        if headPath == nil {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("SaveFileFailed",  comment: "Save file failed"))
            return
        }
        SVProgressHUD.show()
        let put = OSSPutObjectRequest()
        put.bucketName = "hgjt-oss"
        put.uploadingFileURL = URL(fileURLWithPath: headPath!)
        put.objectKey = String(format: "im19060501/%@", (self.headPath! as NSString).lastPathComponent)
        let app = UIApplication.shared.delegate as! AppDelegate
        let task = app.ossClient?.putObject(put)
        task?.continue({ (t) -> Any? in
            if t.error == nil {
                DispatchQueue.main.async {
                    self.createGroup(filename: (self.headPath as! NSString).lastPathComponent)
                }
            }else{
                print(t.error.debugDescription)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                }
            }
            return nil
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMember!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContactsTableViewCell
        if groupMember![indexPath.row]?.portrait != nil {
            cell.headImgView.sd_setImage(with: URL(string: groupMember![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
        }else{
            cell.headImgView.image = UIImage(named: "moren")
        }
        cell.nickNameLabel.text = groupMember![indexPath.row]?.target_user_nickname ?? groupMember![indexPath.row]!.user_id!
        cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", groupMember![indexPath.row]!.id_card!)
        if indexPath.row == groupMember!.count - 1 {
            cell.bottonView.isHidden = true
        }else{
            cell.bottonView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 27))
        headerView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        headerView.addSubview(lable)
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.text = String(format: "%d%@", groupMember!.count,NSLocalizedString("NumOfGroupMember", comment: "group members"))
        lable.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView.mas_left)?.setOffset(8)
            make?.centerY.equalTo()(headerView)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21
    }
    
    func  createGroup(filename:String?) {
        let md = CreateGroupSendModel()
        md.group_portrait = filename
        md.group_name = groupNameTextFeild.text
        md.group_type = groupType
        BoXinProvider.request(.CreateGroup(model: md)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                NotificationCenter.default.post(name: NSNotification.Name("createGroup"), object: model.data!)
                                self.insertMember(id: model.data)
                            }else{
                                if model.message == "请重新登录" {
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
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                                self.loading = false
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loading = false
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                        self.loading = false
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                    self.loading = false
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
                self.loading = false
            }
        }
    }
    
    func insertMember(id:String?) {
        let md = AddBatchSendModel()
        md.group_id = id
        md.group_user_ids = groupMember![0]?.user_id
        for i in 1 ..< groupMember!.count {
            md.group_user_ids! += ",\(groupMember![i]!.user_id!)"
        }
        BoXinProvider.request(.GroupAddBatch(model: md)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getGroupMember(groupID: id!, Complite: { (b) in
                                    if b {
                                        if UIViewController.currentViewController() is ChatViewController {
                                            return
                                        }
                                        let conversation = EMClient.shared()?.chatManager.getConversation(id, type: EMConversationTypeGroupChat, createIfNotExist: true)
                                        let msg = EaseSDKHelper.getTextMessage(NSLocalizedString("YouCreatedTheGroup",  comment: "You created the group"), to: id, messageType: EMChatTypeGroupChat, messageExt: ["em_recall":true])
                                        var err:EMError?
                                        conversation?.insert(msg, error: &err)
                                        if err != nil {
                                            print(err?.errorDescription)
                                        }
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                        NotificationCenter.default.post(Notification(name: NSNotification.Name("endGroup")))
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                            let vc = ChatViewController(conversationChatter: id!, conversationType: EMConversationTypeGroupChat)
                                            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(self.onBack))
                                            vc?.title = self.groupNameTextFeild.text
                                            self.loading = false
                                            vc?.isNeedPopToRoot = true
                                            self.navigationController?.pushViewController(vc!, animated: true)
                                        }
                                    }else
                                    {
                                        self.loading = false
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                })
                            }else{
                                if model.message == "请重新登录" {
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
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                                self.loading = false
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loading = false
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                        self.loading = false
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                    self.loading = false
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
                self.loading = false
            }
        }
    }
    
    @objc func onBack(){
        self.navigationController?.popToRootViewController(animated: true)
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
