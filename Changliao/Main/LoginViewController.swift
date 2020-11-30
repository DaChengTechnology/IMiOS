//
//  LoginViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//
import UIKit
import Toast_Swift
import SVProgressHUD

protocol LoginDelegate {
    func onLogin()
}

@objc class LoginViewController: UIViewController,UITextFieldDelegate,XWCountryCodeControllerDelegate {

    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var codeTextFeild: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    private var countryCode:String = "86"
    private var s:Int?
    private var session_id:String?
    private var isAgree:Bool = false
    @IBOutlet weak var passwordBtn: UIButton!
    @IBOutlet weak var registBtn: UIButton!
   @objc var type:Int  = 0
    var delegate:LoginDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if type == 0 {
            self.navigationController?.navigationBar.setBackgroundImage(DCUtill.gradientRamp(beginColor: "ff9d6d", endColor: "ff695e"), for: .default)
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.hexadecimalColor(hexadecimal: "DA623E")]
        }
        if type == 1 {
            agreeBtn.isHidden = true
            readBtn.isHidden = true
            tipsLabel.isHidden = true
            self.navigationController?.navigationBar.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
        }
        phoneNumberTextField.tag = 1
        codeTextFeild.tag = 2
        phoneNumberTextField.delegate = self
        codeTextFeild.delegate = self
        getCodeBtn.layer.borderWidth = 1
        getCodeBtn.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED").cgColor
        getCodeBtn.layer.masksToBounds = true
        getCodeBtn.layer.cornerRadius = 17.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(g:)))
        countryView.addGestureRecognizer(tap)
        loginBtn.layer.cornerRadius = 25
        loginBtn.layer.masksToBounds=true
        s = 60
        if type == 1 {
            loginBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
            loginBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .selected)
            loginBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .highlighted)
            loginBtn.setTitle(NSLocalizedString("OK", comment: "OK"), for: .disabled)
            registBtn.isHidden = true
            passwordBtn.isHidden = true
            title = "修改手机号码"
        }
        self.navigationItem.title = self.title
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
    }
    
    @objc func onTap(g:UITapGestureRecognizer){
        if g.state == .ended {
            let vc = XWCountryCodeController()
            vc.deleagete = self
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: #selector(onBack))
            self.navigationController?.pushViewController(vc, animated: true)
//            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func onBack(){
        
    }
    @IBAction func onAgree(_ sender: Any) {
        isAgree = !isAgree
        if isAgree {
            agreeBtn.setImage(UIImage(named: "对号"), for: .normal)
        }else{
            agreeBtn.setImage(UIImage(named: "椭圆2"), for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !textField.isSecureTextEntry {
            if string.hasPrefix("+") {
                if let subtext = string.replacingOccurrences(of: "-", with: "").split(separator: " ") as? [Substring] {
                    if subtext.count == 2 {
                        textField.text = String(subtext[1])
                        return false
                    }
                }
            }
        }
        return true
    }

    @IBAction func onGetCode(_ sender: Any) {
        self.view.endEditing(true);
        if phoneNumberTextField.text == nil {
            view.makeToast("请填写手机号")
            return
        }
        if phoneNumberTextField.text!.isEmpty {
            view.makeToast("请填写手机号")
            return
        }
        getCodeBtn.isEnabled = false
        self.getCodeBtn.titleLabel?.text = "\(self.s!)"
        self.getCodeBtn.setTitle("\(self.s!)", for: .disabled)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        let model = SendSMSSendModel()
        model.nationcode = countryCode
        model.mobile = phoneNumberTextField.text
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
                                    self.getCodeBtn.isEnabled = true
                                    self.s = 60
                                    return
                                }
                                self.view.makeToast(model.message)
                                timer.cancel()
                                self.getCodeBtn.isEnabled = true
                                self.s = 60
                            }
                        }else{
                            timer.cancel()
                            self.getCodeBtn.isEnabled = true
                            self.s = 60
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        timer.cancel()
                        self.getCodeBtn.isEnabled = true
                        self.s = 60
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                    
                }else{
                    timer.cancel()
                    self.getCodeBtn.isEnabled = true
                    self.s = 60
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                }
            case .failure(let err):
                timer.cancel()
                self.getCodeBtn.isEnabled = true
                self.s = 60
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                
            }
        }
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler {
            self.s = self.s! - 1
            DispatchQueue.main.async {
                self.getCodeBtn.titleLabel?.text = "\(self.s!)"
                self.getCodeBtn.setTitle("\(self.s!)", for: .disabled)
                if self.s! <= 0 {
                    self.getCodeBtn.isEnabled = true
                    self.s = 60
                    timer.cancel()
                }
            }
        }
        timer.resume()
    }
    @IBAction func onLogin(_ sender: Any) {
        self.view.endEditing(true)
        if type == 0 {
            if !isAgree {
                UIApplication.shared.keyWindow?.makeToast("请先同意用户协议")
                return
            }
        }
        SVProgressHUD.show()
        let vm = VerifySMSSendModel()
        vm.session_id = session_id
        vm.code = codeTextFeild.text
        loginBtn.isEnabled = false
        BoXinProvider.request(.VerifySMS(model: vm)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200{
                    do{
                        if let model = BaseReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if self.type == 0 {
                                    self.login()
                                }
                                if self.type == 1 {
                                    self.updateMobile()
                                }
                            }else{
                                if model.message!.isEqual("请上传session_id")
                                {
                                        self.view.makeToast("请先获取验证码")
                                    SVProgressHUD.dismiss()
                                    self.loginBtn.isEnabled = true
                                    return
                                }
                                if model.message!.isEqual("请上传验证码")
                                {
                                    self.view.makeToast("请先获取验证码")
                                    SVProgressHUD.dismiss()
                                    self.loginBtn.isEnabled = true
                                    return
                                }
                                if model.message!.isEqual("验证码错误")
                                {
                                    self.view.makeToast("验证码错误")
                                    SVProgressHUD.dismiss()
                                    self.loginBtn.isEnabled = true
                                    return
                                }
                                
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                                self.loginBtn.isEnabled = true
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loginBtn.isEnabled = true
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                        self.loginBtn.isEnabled = true
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                    self.loginBtn.isEnabled = true
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
                self.loginBtn.isEnabled = true
            }
        }
    }
    
    func login() {
        let model = LoginSendModel()
        model.mobile=phoneNumberTextField.text
        BoXinProvider.request(.Login(model: model)) { (result) in
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
                                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                                DispatchQueue.global().async {
                                                    self.delegate?.onLogin()
                                                }
                                                DispatchQueue.main.async {
                                                    self.loginBtn.isEnabled = true
                                                    self.clearAllModelController(animated: false, complete: nil)
                                                }
                                                SVProgressHUD.dismiss()
                                            })
                                            return
                                        }
                                        self.view.makeToast(e.errorDescription)
                                        print(e.errorDescription)
                                        self.loginBtn.isEnabled = true
                                        SVProgressHUD.dismiss()
                                    }else{
                                        EMClient.shared()?.options.isAutoLogin = true
                                        BoXinUtil.getUserInfo(Complite: { (b) in
                                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                            DispatchQueue.global().async {
                                                self.delegate?.onLogin()
                                            }
                                            DispatchQueue.main.async {
                                                self.loginBtn.isEnabled = true
                                                self.clearAllModelController(animated: false, complete: nil)
                                            }
                                            SVProgressHUD.dismiss()
                                        })
                                    }
                                })
                            }else{
                                self.view.makeToast(lm.message)
                                SVProgressHUD.dismiss()
                                self.loginBtn.isEnabled = true
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loginBtn.isEnabled = true
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                        self.loginBtn.isEnabled = true
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                    self.loginBtn.isEnabled = true
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
                self.loginBtn.isEnabled = true
            }
        }
    }
    
    func updateMobile() {
        let model = ChangePhoneSendModel()
        model.mobile = phoneNumberTextField.text
        BoXinProvider.request(.ChangePhone(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let lm = LoginReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(lm.code ?? 0) else {
                                return
                            }
                            if lm.code == 200{
                                self.getUserInfo()
                            }else{
                                self.view.makeToast(lm.message)
                                SVProgressHUD.dismiss()
                                self.loginBtn.isEnabled = true
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loginBtn.isEnabled = true
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                        self.loginBtn.isEnabled = true
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                    self.loginBtn.isEnabled = true
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
                self.loginBtn.isEnabled = true
            }
        }
    }
    
    // MARK: - XWCountryCodeControllerDelegate
    func returnCountryName(_ countryName: String!, code: String!) {
        countryLabel.text = countryName
        countryCode = code
    }
    func getUserInfo() {
        BoXinProvider.request(.UserInfo(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = UserInfoReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                SVProgressHUD.dismiss()
                                UserDefaults.standard.set(model.data?.toJSONString(), forKey: "userInfo")
                                QueryFriend.shared.addFriend(id: (model.data?.db!.user_id)!, nickName: (model.data?.db!.user_name)!, portrait1: (model.data?.db!.portrait)!, card: model.data!.db!.id_card!)
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                if model.message == "请重新登录" {
                                    BoXinUtil.Logout()
                                    if (UIViewController.currentViewController() as? BootViewController) != nil {
                                        let app = UIApplication.shared.delegate as! AppDelegate
                                        app.isNeedLogin = true
                                        return
                                    }
                                    if let vc = UIViewController.currentViewController() as? LoginViewController {
                                        if vc.type == 0 {
                                            return
                                        }
                                    }
                                    let sb = UIStoryboard(name: "Main", bundle: nil)
                                    self.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
                                }
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }

    @IBAction func readUserLic(_ sender: Any) {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = UserAgreementViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func GochangeBtn(_ sender: Any) {
    }
    @IBAction func DismissVc(_ sender: Any) {
    }
}
