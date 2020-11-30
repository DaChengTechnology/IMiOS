//
//  AboutViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class AboutViewController: UIViewController {
    
    var iconImageView:UIImageView?
    var appNameLabel:UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        self.view.addSubview(iconImageView!)
        iconImageView?.image = UIImage(named: "cl_logo")
        appNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        appNameLabel?.textColor = UIColor.hexadecimalColor(hexadecimal: "8a8888")
        let info = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        appNameLabel?.text = "畅聊 v\(info ?? "2.53")"
        self.view.addSubview(appNameLabel!)
        appNameLabel?.mas_makeConstraints({ (make) in
            make?.centerX.equalTo()(self.view.mas_centerX)
            make?.centerY.equalTo()(self.view.mas_centerY)
        })
        iconImageView?.mas_makeConstraints({ (make) in
            make?.bottom.equalTo()(appNameLabel?.mas_top)?.offset()(-8)
            make?.centerX.equalTo()(self.view.mas_centerX)
            make?.height.mas_equalTo()(138)
            make?.width.mas_equalTo()(140)
        })
        let banquan = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        banquan.text = "畅聊版权所有"
        banquan.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(banquan)
        banquan.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-8)
            make?.centerX.equalTo()(self.view.mas_centerX)
        }
        let ban = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        ban.text = "Copyright©2019 ChangLiao"
        ban.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(ban)
        ban.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(banquan.mas_top)?.offset()(-8)
            make?.centerX.equalTo()(self.view.mas_centerX)
        }
        let userAgreement = UIButton(type: .custom)
        userAgreement.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .normal)
        userAgreement.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .selected)
        userAgreement.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .highlighted)
        userAgreement.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .disabled)
        userAgreement.setTitle("使用条款和隐私协议", for: .normal)
        userAgreement.setTitle("使用条款和隐私协议", for: .selected)
        userAgreement.setTitle("使用条款和隐私协议", for: .highlighted)
        userAgreement.setTitle("使用条款和隐私协议", for: .disabled)
        userAgreement.addTarget(self, action: #selector(onUserAgreement), for: .touchUpInside)
        view.addSubview(userAgreement)
        userAgreement.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(ban.mas_top)?.offset()(-8)
            make?.centerX.equalTo()(self.view.mas_centerX)
        }
        title = "关于畅聊"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "渐变填充1")
    }
    
    @objc func onUserAgreement() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = UserAgreementViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
