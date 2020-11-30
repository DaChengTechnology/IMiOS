//
//  ChangeNickNameViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SVProgressHUD


@objc class ChangeNickNameViewController: UIViewController,UITextFieldDelegate {
    
    var nickNameTextFeild:UITextField?
    var isLoading:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let bk = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        bk.backgroundColor = UIColor.white
        self.view.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            make?.height.mas_equalTo()(40)
        }
        nickNameTextFeild = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nickNameTextFeild?.borderStyle = .none
        nickNameTextFeild?.delegate = self
        nickNameTextFeild?.backgroundColor = UIColor.white
        nickNameTextFeild?.placeholder = "请输入昵称"
        self.view.addSubview(nickNameTextFeild!)
        nickNameTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(16)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-16)
            make?.height.mas_equalTo()(40)
        })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
        self.title = "修改昵称"
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden=false;
        DCUtill.setNavigationBarTittle(controller: self)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "渐变填充1")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func onComplite() {
        if nickNameTextFeild?.text == nil {
            let alert = UIAlertController(title: "修改昵称", message: "昵称不合法", preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (nickNameTextFeild?.text!.isEmpty)! {
            let alert = UIAlertController(title: "修改昵称", message: "昵称不合法", preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if nickNameTextFeild!.text!.count > 25 {
            let alert = UIAlertController(title: "修改昵称", message: "昵称不能超过25个字符", preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isLoading {
            return
        }
        isLoading = true
        SVProgressHUD.show()
        let model = ChangeNickNameSendModel()
        model.userName = nickNameTextFeild?.text
        BoXinProvider.request(.ChangeNickName(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getMyGroup({ (b) in
                                
                                })
                                BoXinUtil.getUserInfo(Complite: { (_) in
                                    SVProgressHUD.dismiss()
                                    self.isLoading = false
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
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
                                self.isLoading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
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
