//
//  RegisterViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/18/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,UITextFieldDelegate,XWCountryCodeControllerDelegate {
    
    private var countryButton=UIButton(frame: .zero)
    private var phoneTextFeild:UITextField=UITextField(frame: .zero)
    private var checkCodeTextFeild=UITextField(frame: .zero)
    private var checkCodeButton=UIButton(type: .custom)
    private var passwordTextFeild=UITextField(frame: .zero)
    private var passwordLineView=UIView(frame: .zero)
    private var phoneLineView=UIView(frame: .zero)
    private var codeLineView=UIView(frame: .zero)
    private var internationalCode = "86"
    private var LoginBtn=UIButton(type: .custom)
    private var agreeded = false
    private var agreeBtn = UIButton(type: .custom)
    private var s = 60
    private var session_id:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        let bkImage = UIImageView(image: UIImage(named: "regist_bk"))
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
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.width.mas_equalTo()(44)
            make?.height.equalTo()(backButton.mas_width)
        }
        let loginLabel = UILabel(frame: .zero)
        loginLabel.font=UIFont.systemFont(ofSize: 32)
        loginLabel.textColor=UIColor.white
        loginLabel.text = NSLocalizedString("register", comment: "Register")
        self.view.addSubview(loginLabel)
        loginLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(24)
            make?.top.equalTo()(backButton.mas_bottom)?.offset()(30)
        }
        phoneTextFeild.textColor = UIColor.white
        checkCodeTextFeild.textColor = UIColor.white
        passwordTextFeild.textColor = UIColor.white
        countryButton.setTitle(NSLocalizedString("China", comment: "China"), for: .normal)
        countryButton.tintColor=UIColor.white
        countryButton.addTarget(self, action: #selector(onChangeCountry), for: .touchUpInside)
        self.view.addSubview(countryButton)
        countryButton.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(24)
            make?.top.equalTo()(loginLabel.mas_bottom)?.offset()(46)
            make?.width.mas_equalTo()(74)
            make?.height.mas_equalTo()(40)
        }
        phoneTextFeild.placeholder = NSLocalizedString("plsInputPhoneNum", comment: "Please input your telephone number")
        phoneTextFeild.borderStyle = .none
        phoneTextFeild.delegate = self
        self.view.addSubview(phoneTextFeild)
        phoneTextFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(countryButton.mas_right)
            make?.top.equalTo()(countryButton)
            make?.right.equalTo()(self.view.mas_right)?.offset()(-24)
            make?.bottom.equalTo()(countryButton)
        }
        phoneLineView.backgroundColor=UIColor.white
        phoneLineView.layer.opacity=0.51
        self.view.addSubview(phoneLineView)
        phoneLineView.mas_makeConstraints { (make) in
            make?.left.equalTo()(countryButton)
            make?.top.equalTo()(countryButton.mas_bottom)
            make?.right.equalTo()(phoneTextFeild)
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
            make?.left.equalTo()(phoneLineView)
            make?.top.equalTo()(passwordTextFeild.mas_bottom)
            make?.right.equalTo()(phoneLineView)
            make?.height.mas_equalTo()(1)
        }
        checkCodeButton.setTitle(NSLocalizedString("GetVerificationCode", comment: "Get Verif Code"), for: .normal)
        checkCodeButton.tintColor=UIColor.white
        checkCodeButton.addTarget(self, action: #selector(getVerifationCode), for: .touchUpInside)
        self.view.addSubview(checkCodeButton)
        checkCodeButton.mas_makeConstraints { (make) in
            make?.right.equalTo()(phoneLineView)
            make?.top.equalTo()(passwordLineView.mas_bottom)?.offset()(38)
            make?.width.mas_equalTo()(124.5)
            make?.height.mas_equalTo()(40)
        }
        checkCodeTextFeild.delegate=self
        checkCodeTextFeild.placeholder = NSLocalizedString("VerificationCode", comment: "Verification Code")
        self.view.addSubview(checkCodeTextFeild)
        checkCodeTextFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(phoneLineView)
            make?.top.equalTo()(passwordLineView.mas_bottom)?.offset()(38)
            make?.right.equalTo()(checkCodeButton.mas_left)
            make?.height.mas_equalTo()(40)
        }
        codeLineView.backgroundColor=UIColor.white
        codeLineView.layer.opacity = 0.51
        self.view.addSubview(codeLineView)
        codeLineView.mas_makeConstraints { (make) in
            make?.left.equalTo()(countryButton)
            make?.top.equalTo()(checkCodeButton.mas_bottom)
            make?.right.equalTo()(phoneTextFeild)
            make?.height.mas_equalTo()(1)
        }
        let w1=DCUtill.ga_widthForComment(str: NSLocalizedString("plzReadUserAgreement", comment: "Please carefully read"), fontSize: 14, height: 20) + 20
        agreeBtn.setImage(UIImage(named: "disagree"), for: .normal)
        agreeBtn.setTitle(NSLocalizedString("plzReadUserAgreement", comment: "Please carefully read"), for: .normal)
        agreeBtn.titleLabel?.font=UIFont.systemFont(ofSize: 14)
        agreeBtn.tintColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF7F")
        agreeBtn.addTarget(self, action: #selector(onAgress), for: .touchUpInside)
        self.view.addSubview(agreeBtn)
        agreeBtn.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-15)
            make?.width.mas_equalTo()(w1)
            make?.height.mas_equalTo()(20)
            make?.centerX.equalTo()(self.view)?.offset()(-w1/2)
        }
        let agreementBtn = UIButton(type: .custom)
        let w2 = DCUtill.ga_widthForComment(str: NSLocalizedString("Agreement", comment: "《User agreement》"), fontSize: 14, height: 20)
        agreementBtn.setTitle(NSLocalizedString("Agreement", comment: "《User agreement》"), for: .normal)
        agreementBtn.tintColor=UIColor.white
        agreementBtn.titleLabel?.font=UIFont.systemFont(ofSize: 14)
        agreementBtn.addTarget(self, action: #selector(onAgreement), for: .touchUpInside)
        self.view.addSubview(agreementBtn)
        agreementBtn.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-15)
            make?.width.mas_equalTo()(w2)
            make?.height.mas_equalTo()(20)
            make?.centerX.equalTo()(self.view)?.offset()(w2/2)
        }
        LoginBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF7D")
        LoginBtn.tintColor=UIColor.white
        LoginBtn.setTitle(NSLocalizedString("login", comment: "Login"), for: .normal)
        LoginBtn.layer.masksToBounds=true
        LoginBtn.layer.cornerRadius=25
        LoginBtn.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        self.view.addSubview(LoginBtn)
        LoginBtn.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(agreementBtn.mas_top)?.offset()(-122)
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
    
    @objc func onChangeCountry(){
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = XWCountryCodeController()
        vc.deleagete = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func returnCountryName(_ countryName: String!, code: String!) {
        countryButton.setTitle(countryName, for: .normal)
        internationalCode = code
    }
    
    @objc func getVerifationCode() {
        self.view.endEditing(true);
            if phoneTextFeild.text == nil {
                view.makeToast("请填写手机号")
                return
            }
            if phoneTextFeild.text!.isEmpty {
                view.makeToast("请填写手机号")
                return
            }
            checkCodeButton.isEnabled = false
            self.checkCodeButton.titleLabel?.text = "\(self.s)"
            self.checkCodeButton.setTitle("\(self.s)", for: .disabled)
            let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            let model = SendSMSSendModel()
            model.nationcode = internationalCode
            model.mobile = phoneTextFeild.text
            BoXinProvider.request(.SendSMS(model: model)) { (result) in
                switch (result) {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.session_id = model.data
                                }else{
                                    if model.message?.contains("sig error") ?? false {
                                        self.view.makeToast("手机号格式错误")
                                        timer.cancel()
                                        self.checkCodeButton.isEnabled = true
                                        self.s = 60
                                        return
                                    }
                                    self.view.makeToast(model.message)
                                    timer.cancel()
                                    self.checkCodeButton.isEnabled = true
                                    self.s = 60
                                }
                            }else{
                                timer.cancel()
                                self.checkCodeButton.isEnabled = true
                                self.s = 60
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }catch{
                            timer.cancel()
                            self.checkCodeButton.isEnabled = true
                            self.s = 60
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                        
                    }else{
                        timer.cancel()
                        self.checkCodeButton.isEnabled = true
                        self.s = 60
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                case .failure(let err):
                    timer.cancel()
                    self.checkCodeButton.isEnabled = true
                    self.s = 60
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    
                }
            }
            timer.schedule(deadline: .now(), repeating: 1)
            timer.setEventHandler {
                self.s = self.s - 1
                DispatchQueue.main.async {
                    self.checkCodeButton.titleLabel?.text = "\(self.s)"
                    self.checkCodeButton.setTitle("\(self.s)", for: .disabled)
                    if self.s <= 0 {
                        self.checkCodeButton.isEnabled = true
                        self.s = 60
                        timer.cancel()
                    }
                }
            }
            timer.resume()
    }
    
    @objc func onAgress(){
        agreeded = !agreeded
        if agreeded {
            agreeBtn.setImage(UIImage(named: "agree"), for: .normal)
        }else{
            agreeBtn.setImage(UIImage(named: "disagree"), for: .normal)
        }
    }
    
    @objc func onAgreement(){
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = UserAgreementViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func onLogin(){
        self.view.endEditing(true)
        if !agreeded {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("PlzAgreeUserAgreement", comment: "Please agree useragreement"))
            return
        }
        if !isPassWord(string: passwordTextFeild.text ?? "") {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("passwordRex", comment: "Password must be a combination of 8-16 alphanumeric characters"))
            return
        }
        SVProgressHUD.show()
        LoginBtn.isEnabled = false
        DispatchQueue.global().async {
            let vm = VerifySMSSendModel()
            vm.session_id = self.session_id
            vm.code = self.checkCodeTextFeild.text
            BoXinProvider.request(.VerifySMS(model: vm),callbackQueue: DispatchQueue.main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200{
                        do{
                            if let model = BaseReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.login()
                                }else{
                                    if model.message!.isEqual("请上传session_id")
                                    {
                                            self.view.makeToast("请先获取验证码")
                                        SVProgressHUD.dismiss()
                                        self.LoginBtn.isEnabled = true
                                        return
                                    }
                                    if model.message!.isEqual("请上传验证码")
                                    {
                                        self.view.makeToast("请先获取验证码")
                                        SVProgressHUD.dismiss()
                                        self.LoginBtn.isEnabled = true
                                        return
                                    }
                                    if model.message!.isEqual("验证码错误")
                                    {
                                        self.view.makeToast("验证码错误")
                                        SVProgressHUD.dismiss()
                                        self.LoginBtn.isEnabled = true
                                        return
                                    }
                                    
                                    self.view.makeToast(model.message)
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
    
    func login() {
        let model = RegistAndLoginSendModel()
        model.mobile=phoneTextFeild.text
        model.password=passwordTextFeild.text
        DispatchQueue.global().async {
            BoXinProvider.request(.RegistAndLogin(model: model), callbackQueue:  DispatchQueue.main) { (result) in
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
                                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LoginSuccess0")))
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField===phoneTextFeild {
            phoneLineView.layer.opacity=1
        }else if textField===passwordTextFeild {
            passwordLineView.layer.opacity=1
        }else{
            codeLineView.layer.opacity=1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField===phoneTextFeild {
            phoneLineView.layer.opacity=0.51
        }else if textField===passwordTextFeild {
            passwordLineView.layer.opacity=0.51
        }else{
            codeLineView.layer.opacity=0.51
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func isPassWord(string: String) -> Bool {
        if string.isEmpty {
            return false
        }
        let allRegex:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^[\\x21-\\x7E]{8,16}$")
        let numberRegex:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^.*[0-9]+.*$")
        let letterRegex:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^.*[A-Za-z]+.*$")
        if numberRegex.evaluate(with: string) && letterRegex.evaluate(with: string){
            if allRegex.evaluate(with: string){
                return true
            }
        }
        return false
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
