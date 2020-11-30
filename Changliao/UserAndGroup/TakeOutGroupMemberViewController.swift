//
//  TakeOutGroupMemberViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/21/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class TakeOutGroupMemberViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    var textSearchTextFeild:UITextField?
    var table:UITableView?
    let cancelBtn = UIButton(type: .custom)
    var model:GroupViewModel?
    var data:[GroupMemberData?]?
    var select:[GroupMemberData?]?
    var searchArr:[GroupMemberData?]?
    var isLoading:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.title = "踢出成员"
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
        self.view.addSubview(topView)
        topView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.height.mas_equalTo()(40)
        }
        let searchImageView = UIImageView(image: UIImage(named: "搜索"))
        topView.addSubview(searchImageView)
        searchImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)?.offset()(16)
            make?.width.mas_equalTo()(15)
            make?.height.mas_equalTo()(17)
            make?.top.equalTo()(topView.mas_top)?.offset()(10)
        }
        cancelBtn.setImage(UIImage(named: "错误111"), for: .normal)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .highlighted)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .selected)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .disabled)
        cancelBtn.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.mas_makeConstraints { (make) in
            make?.right.equalTo()(topView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(40)
            make?.centerY.equalTo()(topView.mas_centerY)
        }
        cancelBtn.isHidden = true
        textSearchTextFeild = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        textSearchTextFeild?.delegate = self
        textSearchTextFeild?.borderStyle = .none
        textSearchTextFeild?.placeholder = NSLocalizedString("Search", comment: "Search")
        textSearchTextFeild?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        topView.addSubview(textSearchTextFeild!)
        textSearchTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(searchImageView.mas_right)?.offset()(8)
            make?.top.equalTo()(topView.mas_top)?.offset()(5)
            make?.right.equalTo()(cancelBtn.mas_left)?.offset()(-8)
            make?.bottom.equalTo()(topView.mas_bottom)?.offset()(-8)
        })
        let searchLine = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        topView.addSubview(searchLine)
        searchLine.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
        searchLine.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)
            make?.bottom.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(topView.mas_right)
            make?.height.mas_equalTo()(0.5)
        }
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        table?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table?.dataSource = self
        table?.delegate = self
        table?.separatorStyle = .none
        self.view.addSubview(table!)
        table?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        })
        table?.register(UINib(nibName: "SelectUserTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectUser")
        if model?.is_admin == 1 {
            data = data?.filter({ (d) -> Bool in
                if d?.is_administrator == 1 {
                    return false
                }
                return true
            })
        }
        if model?.is_menager == 1 {
            data = data?.filter({ (d) -> Bool in
                if d?.is_administrator == 1 {
                    return false
                }
                if d?.is_manager == 1 {
                    return false
                }
                return true
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .done, target: self, action: #selector(onComplite))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
    }
    
    @objc func onComplite() {
        if select == nil {
            let a = UIAlertController(title: nil, message: "请选择需要移除的人", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
            a.modalPresentationStyle = .overFullScreen
            self.present(a, animated: true, completion: nil)
            return
        }
        if select!.count < 1 {
            let a = UIAlertController(title: nil, message: "请选择需要移除的人", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
            a.modalPresentationStyle = .overFullScreen
            self.present(a, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: nil, message: "确定移除他们吗", preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
            self.remove()
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }
    
    func remove() {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = AddBatchSendModel()
        model.group_id = self.model?.groupId
        model.group_user_ids = select![0]!.user_id
        if select!.count > 1 {
            for i in 1 ..< select!.count {
                model.group_user_ids! += ",\(select![i]!.user_id!)"
            }
        }
        BoXinProvider.request(.GroupRemoveBatch(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                
                                for m in self.select! {
                                    QueryFriend.shared.deleteGroupUser(userId: m!.user_id!, groupId: m!.group_id!)
                                }
                                let body = EMCmdMessageBody(action: "")
                                var dic = ["type":"qun","id":self.model?.groupId]
                                if self.model?.is_all_banned == 1 {
                                    dic.updateValue("2", forKey: "grouptype")
                                }else{
                                    dic.updateValue("1", forKey: "grouptype")
                                }
                                let msg = EMMessage(conversationID: self.model!.groupId!, from: EMClient.shared()?.currentUsername, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                msg?.chatType = EMChatTypeGroupChat
                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                    
                                }, completion: { (msg, err) in
                                    if err != nil {
                                        print(err?.errorDescription)
                                    }
                                    
                                })
                                self.isLoading = false
                                SVProgressHUD.dismiss()
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                if model.message == "请重新登录" {
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
                                self.isLoading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func onCancel() {
        textSearchTextFeild?.text = nil
        cancelBtn.isHidden = true
        searchArr = nil
        table?.reloadData()
    }
    
    @objc func textFieldDidChange(textField:UITextField) {
        if textField.markedTextRange != nil {
            return
        }
        if textField.text != nil {
            if !textField.text!.isEmpty {
                search(keyWold: textField.text!)
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidChange(textField: textField)
        return true
    }
    func search(keyWold:String) {
        guard let da = data else{
            return
        }
        searchArr = Array<GroupMemberData>()
        for d in da {
            if d?.group_user_nickname?.contains(keyWold) ?? false {
                searchArr?.append(d)
            }
            if d?.friend_name?.contains(keyWold) ?? false {
                searchArr?.append(d)
            }
            if d?.id_card?.contains(keyWold) ?? false {
                searchArr?.append(d)
            }
            if d?.user_name?.contains(keyWold) ?? false {
                searchArr?.append(d)
            }
        }
        if searchArr != nil {
            searchArr = NSSet(array: searchArr!).allObjects as! [GroupMemberData?]
        }
        
        
        table?.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchArr != nil {
            return searchArr!.count
        }
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUser", for: indexPath) as! SelectUserTableViewCell
        if searchArr != nil {
            cell.headImageView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            
            
            var text:String? = ""
            if QueryFriend.shared.checkFriend(userID: (searchArr?[indexPath.row ]!.user_id)!) {
                
                if searchArr?[indexPath.row ]?.friend_name != ""
                {
                    text = searchArr?[indexPath.row ]?.friend_name
                }else
                {
                    text = searchArr?[indexPath.row ]?.user_name
                }
                
            }else{
                if searchArr?[indexPath.row ]?.group_user_nickname != "" {
                    text = searchArr?[indexPath.row ]?.group_user_nickname;
                }else{
                    text = searchArr?[indexPath.row ]?.user_name
                }
            }
            cell.nameLabel.text = text
            cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", searchArr![indexPath.row]!.id_card!)
            if searchSelectGroupMember(member: searchArr![indexPath.row]!) {
                cell.selectImageView.image = UIImage(named: "对号")
            }else{
                cell.selectImageView.image = UIImage(named: "椭圆2")
            }
        }else{
            cell.headImageView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            
            
            if data![indexPath.row]?.friend_name?.isEmpty ?? true
            {
                if data![indexPath.row]?.group_user_nickname?.isEmpty ?? true
                {
                    cell.nameLabel.text = data?[indexPath.row]?.user_name
                }else
                {
                    cell.nameLabel.text = data?[indexPath.row]?.group_user_nickname
                }
                
            }else
            {
                cell.nameLabel.text = data?[indexPath.row]?.friend_name
            }
            
            cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data![indexPath.row]!.id_card!)
            if searchSelectGroupMember(member: data![indexPath.row]!) {
                cell.selectImageView.image = UIImage(named: "对号")
            }else{
                cell.selectImageView.image = UIImage(named: "椭圆2")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SelectUserTableViewCell
        if searchSelectGroupMember(member: data![indexPath.row]!) {
            cell.selectImageView.image = UIImage(named: "椭圆2")
            removeSelect(model: data![indexPath.row]!)
        }else{
            cell.selectImageView.image = UIImage(named: "对号")
            if select == nil {
                select = Array<GroupMemberData>()
            }
            select?.append(data![indexPath.row])
        }
    }
    
    func searchSelectGroupMember(member:GroupMemberData) -> Bool {
        if select != nil {
            for m in select! {
                if m?.user_id == member.user_id {
                    return true
                }
            }
        }
        return false
    }
   
    
    func removeSelect(model:GroupMemberData) {
        if select != nil {
            var i = 0
            for s in select! {
                if s?.user_id == model.user_id {
                    select?.remove(at: i)
                }
                i += 1
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
