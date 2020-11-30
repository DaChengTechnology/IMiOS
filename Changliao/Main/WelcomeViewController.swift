//
//  WelcomeViewController.swift
//  boxin
//
//  Created by guduzhonglao on 1/15/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        let image = UIImageView(frame: .zero)
        image.image=UIImage(named: "cl_logo")
        view.addSubview(image)
        image.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(220)
            make?.centerX.equalTo()(self.view)
            make?.width.mas_equalTo()(138)
            make?.height.mas_equalTo()(140)
        }
        let register = UIButton(type: .custom)
        register.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        register.tintColor=UIColor.white
        register.setTitle(NSLocalizedString("register", comment: "Regist"), for: .normal)
        register.setTitle(NSLocalizedString("register", comment: "Regist"), for: .selected)
        register.setTitle(NSLocalizedString("register", comment: "Regist"), for: .highlighted)
        register.setTitle(NSLocalizedString("register", comment: "Regist"), for: .disabled)
        register.addTarget(self, action: #selector(onRegister), for: .touchUpInside)
        register.layer.cornerRadius=25
        register.layer.shadowColor=UIColor.hexadecimalColor(hexadecimal: "#0148ED").cgColor
        register.layer.shadowOffset=CGSize(width: 0, height: 2)
        register.layer.shadowRadius=4
        register.layer.shadowOpacity=1
        self.view.addSubview(register)
        register.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-36)
            make?.centerX.equalTo()(self.view)
            make?.width.mas_equalTo()(200)
            make?.height.mas_equalTo()(50)
        }
        let login = UIButton(type: .custom)
        login.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        login.tintColor=UIColor.white
        login.setTitle(NSLocalizedString("login", comment: "Login"), for: .normal)
        login.setTitle(NSLocalizedString("login", comment: "Login"), for: .selected)
        login.setTitle(NSLocalizedString("login", comment: "Login"), for: .highlighted)
        login.setTitle(NSLocalizedString("login", comment: "Login"), for: .disabled)
        login.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        login.layer.cornerRadius=25
        login.layer.shadowColor=UIColor.hexadecimalColor(hexadecimal: "#FE0846").cgColor
        login.layer.shadowOffset=CGSize(width: 0, height: 2)
        login.layer.shadowRadius=4
        login.layer.shadowOpacity=1
        self.view.addSubview(login)
        login.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(register.mas_top)?.offset()(-20)
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
    
    @objc func onRegister(){
        self.navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @objc func onLogin(){
        self.navigationController?.pushViewController(LoginPhoneViewController(), animated: true)
    }

}
