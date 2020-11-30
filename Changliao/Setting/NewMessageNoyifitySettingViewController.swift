//
//  NewMessageNoyifitySettingViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/3/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class NewMessageNoyifitySettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var table:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(table)
        table.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_bottom)
        }
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table.separatorStyle = .none
        table.register(UINib(nibName: "UserDetailSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailSetting")
        title = "消息设置"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "渐变填充1")
        self.navigationController?.navigationBar.isTranslucent=false;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = "新消息提示"
            cell.tittleLable.font=DCUtill.FONT(x: 14)
            if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onNewTips(sender:)), for: .touchUpInside)
            return cell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = "声音"
            cell.tittleLable.font=DCUtill.FONT(x: 14)

            if UserDefaults.standard.string(forKey: "sound") == "1" {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            if UserDefaults.standard.string(forKey: "newMessage") == "2" {
                cell.settingSwitch.isEnabled = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onSound(sender:)), for: .touchUpInside)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
        cell.tittleLable.text = "震动"
        cell.tittleLable.font=DCUtill.FONT(x: 14)

        if UserDefaults.standard.string(forKey: "shake") == "1" {
            cell.settingSwitch.isOn = true
        }else{
            cell.settingSwitch.isOn = false
        }
        if UserDefaults.standard.string(forKey: "newMessage") == "2" {
            cell.settingSwitch.isEnabled = false
        }
        cell.settingSwitch.addTarget(self, action: #selector(onShake(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func onNewTips(sender:UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set("1", forKey: "newMessage")
            let soundCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as? UserDetailSettingTableViewCell
            soundCell?.settingSwitch.isEnabled = true
            let shakeCell = table.cellForRow(at: IndexPath(row: 1, section: 1)) as? UserDetailSettingTableViewCell
            shakeCell?.settingSwitch.isEnabled = true
        }else{
            UserDefaults.standard.set("2", forKey: "newMessage")
            let soundCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as? UserDetailSettingTableViewCell
            soundCell?.settingSwitch.isEnabled = false
            let shakeCell = table.cellForRow(at: IndexPath(row: 1, section: 1)) as? UserDetailSettingTableViewCell
            shakeCell?.settingSwitch.isEnabled = false
        }
        UserDefaults.standard.synchronize()
    }
    
    @objc func onSound(sender:UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set("1", forKey: "sound")
        }else {
            UserDefaults.standard.set("2", forKey: "sound")
        }
        UserDefaults.standard.synchronize()
    }
    
    @objc func onShake(sender:UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set("1", forKey: "shake")
        }else {
            UserDefaults.standard.set("2", forKey: "shake")
        }
        UserDefaults.standard.synchronize()
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
