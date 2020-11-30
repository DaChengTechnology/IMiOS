//
//  ReportGroupOrUserViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/22/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class ReportGroupOrUserViewController: UIViewController {
    
    var id:String?
    var type:Int = 1
    var textView=UITextView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.white
        // Do any additional setup after loading the view.
        title = NSLocalizedString("Report", comment: "Report")
        let label=UILabel(frame: .zero)
        label.text="举报原因："
        label.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(16)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(10)
        }
        textView.layer.borderColor=UIColor.hexadecimalColor(hexadecimal: "666666").cgColor
        textView.layer.borderWidth=1
        textView.layer.cornerRadius = 5
        textView.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(textView)
        textView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(16)
            make?.top.equalTo()(label.mas_bottom)?.offset()(10)
            make?.right.equalTo()(self.view)?.offset()(-16)
            make?.height.mas_equalTo()(150)
        }
        let btn=UIButton(frame: .zero)
        btn.tintColor=UIColor.white
        btn.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        btn.setTitle("提交", for: .normal)
        btn.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.layer.cornerRadius=25.5
        btn.layer.masksToBounds = true
        btn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(30)
            make?.top.equalTo()(textView.mas_bottom)?.offset()(30)
            make?.right.equalTo()(self.view)?.offset()(-30)
            make?.height.mas_equalTo()(45)
        }
    }
    
    @objc func onSubmit(){
        self.view.endEditing(true)
        if textView.text.isEmpty {
            self.view.makeToast("请输入举报内容")
            return
        }
        SVProgressHUD.show()
        let model = ReportSendModel()
        model.by_inform_id=id
        model.inform_type=type
        model.other_information=textView.text
        BoXinProvider.request(.ReportUser(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            SVProgressHUD.dismiss()
                            return
                        }
                        if model.code == 200 {
                            
                            SVProgressHUD.showSuccess(withStatus: "举报成功")
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else{
                            SVProgressHUD.dismiss()
                            if (model.message?.contains("请重新登录"))! {
                                BoXinUtil.Logout()
                                DispatchQueue.main.async {
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
                                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                }
                            }
                            DispatchQueue.main.async {
                                self.view.makeToast(model.message)
                            }
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        DispatchQueue.main.async {
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        self.view.makeToast("服务器连接失败")
                    }
                }
            case .failure(_):
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
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
