//
//  LoginPasswordViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/18/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class LoginPasswordViewController: UIViewController,UITextFieldDelegate {
    
    private var usernameTextFeild:UITextField=UITextField(frame: .zero)
    private var passwordTextFeild=UITextField(frame: .zero)
    private var phoneLineView=UIView(frame: .zero)
    private var passwordLineView=UIView(frame: .zero)
    private var LoginBtn=UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        let bkImage = UIImageView(image: UIImage(named: "login_bk"))
        self.view.addSubview(bkImage)
        bkImage.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view)
            make?.right.equalTo()(self.view)
            make?.bottom.equalTo()(self.view)
        }
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.setImage(UIImage(named: "back"), for: .selected)
        backButton.setImage(UIImage(named: "back"), for: .highlighted)
        backButton.setImage(UIImage(named: "back"), for: .disabled)
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(10)
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            } else {
                // Fallback on earlier versions
                make?.top.offset()(0)
            }
            make?.width.mas_equalTo()(44)
            make?.height.equalTo()(backButton.mas_width)
        }
        let loginLabel = UILabel(frame: .zero)
        loginLabel.font=UIFont.systemFont(ofSize: 32)
        loginLabel.textColor=UIColor.white
        loginLabel.text = NSLocalizedString("LoginPassword", comment: "Login With Password")
        self.view.addSubview(loginLabel)
        loginLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(24)
            make?.top.equalTo()(backButton.mas_bottom)?.offset()(30)
        }
        usernameTextFeild.textColor = UIColor.white
        passwordTextFeild.textColor = UIColor.white
        usernameTextFeild.placeholder = NSLocalizedString("InputPhoneNumOrID", comment: "Please input your telephone number or Chatting ID")
        usernameTextFeild.borderStyle = .none
        usernameTextFeild.delegate = self
        self.view.addSubview(usernameTextFeild)
        usernameTextFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(24)
            make?.top.equalTo()(loginLabel.mas_bottom)?.offset()(46)
            make?.right.equalTo()(self.view.mas_right)?.offset()(-24)
            make?.height.mas_equalTo()(40)
        }
        phoneLineView.backgroundColor=UIColor.white
        phoneLineView.layer.opacity=0.51
        self.view.addSubview(phoneLineView)
        phoneLineView.mas_makeConstraints { (make) in
            make?.left.equalTo()(usernameTextFeild)
            make?.top.equalTo()(usernameTextFeild.mas_bottom)
            make?.right.equalTo()(usernameTextFeild)
            make?.height.mas_equalTo()(1)
        }
        passwordTextFeild.delegate=self
        passwordTextFeild.placeholder = NSLocalizedString("plzInputPassword", comment: "Please input password")
        passwordTextFeild.isSecureTextEntry=true
        self.view.addSubview(passwordTextFeild)
        passwordTextFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(phoneLineView)
            make?.top.equalTo()(phoneLineView.mas_bottom)?.offset()(38)
            make?.right.equalTo()(phoneLineView)
            make?.height.mas_equalTo()(40)
        }
        passwordLineView.backgroundColor=UIColor.white
        passwordLineView.layer.opacity = 0.51
        self.view.addSubview(passwordLineView)
        passwordLineView.mas_makeConstraints { (make) in
            make?.left.equalTo()(usernameTextFeild)
            make?.top.equalTo()(passwordTextFeild.mas_bottom)
            make?.right.equalTo()(usernameTextFeild)
            make?.height.mas_equalTo()(1)
        }
        LoginBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF7D")
        LoginBtn.tintColor=UIColor.white
        LoginBtn.setTitle(NSLocalizedString("login", comment: "Login"), for: .normal)
        LoginBtn.layer.masksToBounds=true
        LoginBtn.layer.cornerRadius=25
        LoginBtn.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        self.view.addSubview(LoginBtn)
        LoginBtn.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-157)
            make?.centerX.equalTo()(self.view)
            make?.width.mas_equalTo()(200)
            make?.height.mas_equalTo()(50)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden=true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden=true
    }
    
    @objc func onBack(){
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onLogin() {
        self.view.endEditing(true);
        if usernameTextFeild.text?.isEmpty ?? true {
            self.view.makeToast(NSLocalizedString("InputPhoneNumOrID", comment: "Please input your telephone number or Chatting ID"))
            return
        }
        if passwordTextFeild.text?.isEmpty ?? true {
            self.view.makeToast(NSLocalizedString("plzInputPassword", comment: "Please input password"))
            return
        }
        SVProgressHUD.show()
        let model = LoginSendModel()
        model.mobile=usernameTextFeild.text
        model.password=passwordTextFeild.text
        model.way_type=1
        DispatchQueue.global().async {
            BoXinProvider.request(.Login(model: model), callbackQueue:  DispatchQueue.main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let lm = LoginReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(lm.code ?? 0) else {
                                    return
                                }
                                if lm.code == 200{
                                    for (k,v) in (lm.data?.toJSON())! {
                                        UserDefaults.standard.setValue(v, forKey: k)
                                    }
                                    EMClient.shared()?.login(withUsername: UserDefaults.standard.object(forKey: "username") as? String, password: UserDefaults.standard.object(forKey: "password") as? String, completion: { (username, err) in
                                        if let e = err{
                                            if e.code == EMErrorUserAlreadyLogin {
                                                EMClient.shared()?.options.isAutoLogin = true
                                                BoXinUtil.getUserInfo(Complite: { (b) in
                                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LoginSuccess")))
                                                    DispatchQueue.main.async {
                                                        self.LoginBtn.isEnabled = true
                                                        self.navigationController?.clearAllModelController(animated: false, complete: nil)
                                                    }
                                                    SVProgressHUD.dismiss()
                                                })
                                                return
                                            }
                                            self.view.makeToast(e.errorDescription)
                                            self.LoginBtn.isEnabled = true
                                            SVProgressHUD.dismiss()
                                        }else{
                                            EMClient.shared()?.options.isAutoLogin = true
                                            BoXinUtil.getUserInfo(Complite: { (b) in
                                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LoginSuccess")))
                                                DispatchQueue.main.async {
                                                    self.LoginBtn.isEnabled = true
                                                    self.navigationController?.clearAllModelController(animated: false, complete: nil)
                                                }
                                                SVProgressHUD.dismiss()
                                            })
                                        }
                                    })
                                }else{
                                    self.view.makeToast(lm.message)
                                    SVProgressHUD.dismiss()
                                    self.LoginBtn.isEnabled = true
                                }
                            }else{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                                self.LoginBtn.isEnabled = true
                            }
                        }catch{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.LoginBtn.isEnabled = true
                        }
                    }else{
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                        self.LoginBtn.isEnabled = true
                    }
                case .failure(let err):
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                    self.LoginBtn.isEnabled = true
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === usernameTextFeild {
            phoneLineView.layer.opacity = 1
        }else{
            passwordLineView.layer.opacity = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === usernameTextFeild {
            phoneLineView.layer.opacity = 0.51
        }else{
            passwordLineView.layer.opacity = 0.51
        }
    }

}
