//
//  UserInfoViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SVProgressHUD

protocol LogoutDelegate {
    func userLogout()
}

class UserInfoViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MGAvatarImageViewDelegate {
    
    var table:UITableView?
    var logoutBtn:UIButton?
    var delegate:LogoutDelegate?
    var headPath:String?
    var model:FriendData?
    var isloading:Bool = false
    weak var picker:UIImagePickerController?
    weak var nav:UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        table?.dataSource = self
        table?.delegate = self
        table?.separatorStyle = .none
        table?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.view.addSubview(table!)
        logoutBtn = UIButton(type: .custom)
//        logoutBtn?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        logoutBtn?.backgroundColor = UIColor.white
        logoutBtn?.layer.masksToBounds = true
        logoutBtn?.layer.cornerRadius = 5
        logoutBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .normal)
        logoutBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .selected)
        logoutBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .highlighted)
        logoutBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .disabled)
        logoutBtn?.setTitle("退出登录", for: .normal)
        logoutBtn?.setTitle("退出登录", for: .selected)
        logoutBtn?.setTitle("退出登录", for: .highlighted)
        logoutBtn?.setTitle("退出登录", for: .disabled)
        logoutBtn?.addTarget(self, action: #selector(onLogout), for: .touchUpInside)
        self.view.addSubview(logoutBtn!)
        logoutBtn?.mas_makeConstraints({ (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-20)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(0)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(0)
            make?.height.mas_equalTo()(50)
        })
        table?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(logoutBtn?.mas_top)?.offset()(-20)
        })
        table?.bounces = false
        table?.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        table?.register(UINib(nibName: "UserSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "UserSetting")
        self.title = "设置"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        table?.reloadData()
    }
    
    @objc func onLogout() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "userInfo")
        QueryFriend.shared.clearFriend()
        QueryFriend.shared.clearGroup()
        QueryFriend.shared.clearGroupUser()
        QueryFriend.shared.clearFocus()
        QueryFriend.shared.cleanFace()
        QueryFriend.shared.clearGroupTemp()
        EMClient.shared()?.logout(true)
        self.navigationController?.popToRootViewController(animated: false)
        delegate?.userLogout()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 9
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 9))
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 76
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts", for: indexPath) as! ContactsTableViewCell
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            cell.headImgView.sd_setImage(with: URL(string: (model!.db?.portrait)!)!, placeholderImage: UIImage(named: "moren"))
            cell.nickNameLabel.text = model?.db?.user_name
            cell.headImgView.delegate = self
            cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", (model?.db!.id_card!)!)
            cell.Jiantou.isHidden = true
            return cell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSetting", for: indexPath) as! UserSettingTableViewCell
            cell.settingImage.image = UIImage(named: "修改资料")
            cell.settingTittle.text = "修改昵称"
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            cell.dataLabel.text = model?.db?.user_name
            cell.dataLabel.isHidden = false
            cell.goToIcon.isHidden = false
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSetting", for: indexPath) as! UserSettingTableViewCell
            cell.settingImage.image = UIImage(named: "手机")
            cell.settingTittle.text = "修改绑定手机号"
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            cell.dataLabel.text = model?.db?.mobile
            cell.dataLabel.isHidden = false
            cell.goToIcon.isHidden = false
            return cell
        }
        if indexPath.row == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSetting", for: indexPath) as! UserSettingTableViewCell
            cell.settingImage.image = UIImage(named: "重置密码")
            cell.settingTittle.text = "重置密码"
            cell.dataLabel.isHidden = true
            cell.goToIcon.isHidden = false
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSetting", for: indexPath) as! UserSettingTableViewCell
        cell.settingImage.image = UIImage(named: "摄图网_400426144")
        cell.settingTittle.text = "我的二维码"
        cell.dataLabel.isHidden = true
        cell.goToIcon.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if isloading{
                return
            }
            isloading = true
            
            let cell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
            cell.headImgView.show()
            //更换头像
        }
        if indexPath.section == 1 && indexPath.row == 0 {
           //修改昵称
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = ChangeNickNameViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            //修改手机号
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            vc.type = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
//            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
//            let m = QRcodeModel()
//            m.id = model?.db?.user_id
//            let QRView = QRCodeShowView(qrcode: m.toJSONString()!)
//            QRView.show()
            //更换密码
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            let vc = ResetPasswordVc()
            vc.token =  UserDefaults.standard.object(forKey: "token") as! String
            vc.card_id = model?.db?.id_card ?? ""
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            let m = QRcodeModel()
            m.id = model?.db?.user_id
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = ErWeiMaViewController()
            vc.jsonStr = m.toJSONString() ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            //我的二维码
        }
    }
    
    func imageView(_ imageView: MGAvatarImageView!, didSelect image: UIImage!) {
        imageView.image = image
        let data = image!.pngData()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        let savePath = path + String(format: "/signal/%@.png", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        do{
            if !FileManager.default.fileExists(atPath: path + "/signal") {
                try FileManager.default.createDirectory(atPath: path + "/signal", withIntermediateDirectories: true, attributes: nil)
            }
            let a = FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
            print(a)
        }catch(let e){
            print(e)
            self.headPath = nil
            return
        }
        self.headPath = savePath
        self.uploadPortrait()
        
    }
    
    func uploadPortrait() {
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
                self.changePortrait(fileName: (self.headPath as! NSString).lastPathComponent)
            }else{
                print(t.error.debugDescription)
                self.isloading = false
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                }
            }
            return nil
        })
    }
    
    func changePortrait(fileName:String?) {
        let model = ChangePortraitSendModel()
        model.portrait = fileName
        BoXinProvider.request(.ChangePortrait(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getUserInfo(Complite: nil)
                                BoXinUtil.getMyGroup({ (b) in
                                    
                                })
                                self.isloading = false
                                SVProgressHUD.dismiss()
                                self.view.makeToast("修改头像成功")
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
                                self.isloading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isloading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isloading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isloading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isloading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }

}
