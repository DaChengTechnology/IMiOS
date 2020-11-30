//
//  SettingViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/20/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var arr = ["修改昵称","修改手机号","我的二维码","重置密码","消息设置","我的银行卡"]
    var table=UITableView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let logOut = UIButton(type: .system)
        logOut.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        logOut.tintColor=UIColor.white
        logOut.setTitle("退出登录", for: .normal)
        logOut.layer.cornerRadius=25
        logOut.layer.masksToBounds = true
        logOut.addTarget(self, action: #selector(Logout), for: .touchUpInside)
        self.view.addSubview(logOut)
        logOut.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(30)
            make?.right.equalTo()(self.view)?.offset()(-30)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-200)
            make?.height.mas_equalTo()(50)
        }
        table.delegate=self
        table.dataSource=self
        table.bounces=false
        table.backgroundColor=UIColor.white
        table.separatorStyle = .none
        table.rowHeight = 50
        table.register(UINib(nibName: "SettingMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingMoreTableViewCell")
        self.view.backgroundColor=UIColor.white
        self.view.addSubview(table)
        table.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.bottom.equalTo()(logOut.mas_top)
        }
    }
    
    @objc func Logout(){
        let alert = UIAlertController(title: "你确定要退出吗？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (aa) in
            BoXinUtil.Logout()
            self.navigationController?.popToRootViewController(animated: false)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingMoreTableViewCell") as! SettingMoreTableViewCell
        cell.selectionStyle = .none
        cell.settingtitle.text=arr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==0){
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = ChangeNickNameViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row==1 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            vc.type = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 2 {
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            let m = QRcodeModel()
            m.id = model?.db?.user_id
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = ErWeiMaViewController()
            vc.jsonStr = m.toJSONString() ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row==3 {
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            let vc = ResetPasswordVc()
            vc.token =  UserDefaults.standard.object(forKey: "token") as! String
            vc.card_id = model?.db?.id_card ?? ""
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row==4 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = NewMessageNoyifitySettingViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 5 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
            let vc = MyBankCardViewController()
            self.navigationController?.pushViewController(vc, animated: true)
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
