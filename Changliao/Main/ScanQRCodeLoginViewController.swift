//
//  ScanQRCodeLoginViewController.swift
//  boxin
//
//  Created by guduzhonglao on 10/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class ScanQRCodeLoginViewController: UIViewController {
    
    @objc var qr_id:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "返回"), for: .normal)
        self.view.addSubview(backBtn)
        backBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(DCUtill.SCRATIO(x: 6))
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 30))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 30))
        }
        let icon = UIImageView(image: UIImage(named: "login_icon"))
        self.view.addSubview(icon)
        icon.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self.view)
            make?.centerY.equalTo()(self.view)?.offset()(DCUtill.SCRATIO(x: -10))
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 143))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 128))
        }
        let tipslabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tipslabel.font = DCUtill.FONT(x: 15)
        tipslabel.textColor = UIColor.hexadecimalColor(hexadecimal: "333333")
        tipslabel.text = "畅聊登陆确认"
        self.view.addSubview(tipslabel)
        tipslabel.mas_makeConstraints { (make) in
            make?.top.equalTo()(icon.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 8))
            make?.centerX.equalTo()(self.view)
        }
        let cancel = UIButton(type: .custom)
        cancel.setTitle("取消登陆", for: .normal)
        cancel.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "cccccc"), for: .normal)
        cancel.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.view.addSubview(cancel)
        cancel.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(DCUtill.SCRATIO(x: -30))
            make?.centerX.equalTo()(self.view)
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 171))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 38))
        }
        let ok = UIButton(type: .custom)
        ok.setTitle("登陆", for: .normal)
        ok.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#F6F6F6"), for: .normal)
        ok.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EC582E")
        ok.layer.cornerRadius = DCUtill.SCRATIO(x: 10)
        ok.layer.masksToBounds = true
        ok.addTarget(self, action: #selector(onAllow), for: .touchUpInside)
        self.view.addSubview(ok)
        ok.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(cancel.mas_top)?.offset()(DCUtill.SCRATIO(x: -10))
            make?.centerX.equalTo()(self.view)
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 171))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 38))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onAllow() {
        let model = QRLoginSendModel()
        model.qr_id = self.qr_id
        BoXinProvider.request(.QRLogin(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            return
                        }
                        if model.code == 200 {
                            self.onBack()
                            SVProgressHUD.showSuccess(withStatus: "登陆成功")
                        }else{
                            self.view.makeToast(model.message)
                        }
                    }else{
                        self.view.makeToast("数据解析失败")
                    }
                }else{
                    self.view.makeToast("链接服务器失败")
                }
            case .failure(_):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                
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
