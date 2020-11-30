//
//  AddFriendViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/14/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

class AddFriendViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    var searchTextFeild:UITextField?
    var cancelBtn:UIButton?
    var table:UITableView?
    var serverResult:GetUserData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "添加好友"
        self.view.backgroundColor = UIColor.white
        let searchImageView = UIImageView(image: UIImage(named: "搜索"))
        self.view.addSubview(searchImageView)
        searchTextFeild = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        searchTextFeild?.borderStyle = .none
        searchTextFeild?.placeholder = NSLocalizedString("SearchInputPhoneNumOrID", comment: "Please input telephone number or Chatting ID")
        searchTextFeild?.delegate = self
        searchTextFeild?.returnKeyType = .search
        self.view.addSubview(searchTextFeild!)
        cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        cancelBtn?.setImage(UIImage(named: "错误111"), for: .normal)
        cancelBtn?.setImage(UIImage(named: "错误111"), for: .selected)
        cancelBtn?.setImage(UIImage(named: "错误111"), for: .highlighted)
        cancelBtn?.setImage(UIImage(named: "错误111"), for: .disabled)
        cancelBtn?.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        self.view.addSubview(cancelBtn!)
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        lineView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "CECECE")
        self.view.addSubview(lineView)
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        table?.separatorStyle = .none
        table?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table?.delegate = self
        table?.dataSource = self
        table?.rowHeight = 70
        self.view.addSubview(table!)
        searchImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(16)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(15)
            make?.height.mas_equalTo()(17)
            make?.width.mas_equalTo()(15)
        }
        searchTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(searchImageView.mas_right)?.offset()(8)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(5)
            make?.height.mas_equalTo()(40)
            make?.right.equalTo()(self.cancelBtn?.mas_left)?.offset()(8)
        })
        cancelBtn?.mas_makeConstraints({ (make) in
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-16)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(8)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(40)
        })
        table?.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        cancelBtn?.isHidden = true
        lineView.mas_makeConstraints { (make) in
            make?.top.equalTo()(searchImageView.mas_bottom)?.offset()(10)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.height.mas_equalTo()(0.5)
        }
        table?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(lineView.mas_bottom)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    @objc func onCancel(){
        searchTextFeild?.text = ""
        cancelBtn?.isHidden = true
        serverResult = nil
        table?.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil {
            if !textField.text!.isEmpty {
                searchServer()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil {
            if textField.text == "" {
                cancelBtn?.isHidden = true
                return
            }
        }
        cancelBtn?.isHidden = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if serverResult == nil {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serverResult == nil {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContactsTableViewCell
        
        if serverResult != nil {
            cell.headImgView.sd_setImage(with: URL(string: serverResult!.portrait!), placeholderImage: UIImage(named: "moren"))
            cell.nickNameLabel.text = serverResult?.user_name ?? serverResult!.user_id!
            cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", serverResult!.id_card!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if serverResult != nil {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = UserDetailViewController()
            vc.model = FriendData(data: serverResult)
            vc.type = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func searchServer() {
        let model = GetUserByMobileSendModel()
        model.mobile = searchTextFeild?.text
        BoXinProvider.request(.GetUserByMobile(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let md = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(md.code ?? 0) else {
                                return
                            }
                            if md.code == 200 {
                                self.serverResult = md.data
                                self.table!.reloadData()
                            }else{
                                if md.message == "请重新登录" {
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
                                self.view.makeToast(md.message)
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    print(res.statusCode)
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                print(err.errorDescription)
            }
        }
    }

}
