//
//  ChangeGroupOwnerViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/19/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import Masonry
import SVProgressHUD

@objc protocol GroupAtDelegate {
     @objc func onAtClick(member:GroupMemberData?)
}

class ChangeGroupOwnerViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var model:GroupViewModel?
    var data:[GroupMemberData?]?
    var searchArr:[GroupMemberData?]?
    var user:GroupMemberData?
    var delegate:GroupAtDelegate?
    var textSearchTextFeild:UITextField?
    var table:UITableView?
    let cancelBtn = UIButton(type: .custom)
    var typeID:Int = 0 //id = 1 群主转让 id = 2 全体成员
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
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
        cancelBtn.isHidden = true
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
        table?.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        
        table?.register(UINib(nibName: "AllGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "allcell")
        if typeID == 1{
            data = data?.filter({ (d) -> Bool in
                
                if model?.administrator_id == d?.user_id {
                    return false
                }
                return true
                
            })
        }else if typeID == 2
        {
            data = data?.filter({ (d) -> Bool in
                if d?.user_id == user?.user_id
                {
                    return false
                }
                return true
            })
        }
        
        if typeID == 1{
            self.title = "更改群主"
        }else if typeID == 2
        {
            self.title = "全部成员"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        if typeID == 2 {
            DispatchQueue.main.async {
                self.table?.reloadData()
            }
        }
    }
    
    @objc func onCancel() {
        textSearchTextFeild?.text = nil
        searchArr = nil
        cancelBtn.isHidden = true
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
        searchArr = Array<GroupMemberData>()
       
      
        for d in data! {
            if d!.group_user_nickname!.contains(keyWold) {
                searchArr?.append(d)
            }
            if d!.friend_name!.contains(keyWold) {
                searchArr?.append(d)
            }
            if d!.id_card!.contains(keyWold) {
                searchArr?.append(d)
            }
            if d!.user_name!.contains(keyWold) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if typeID == 1{
            if searchArr != nil {
                return searchArr!.count
            }
            
            return data!.count
            
        }
        if searchArr != nil {
            return searchArr!.count
        }
        if data != nil
        {
            if ( user?.is_administrator == 1 || user?.is_manager == 1) {
                return data!.count + 1
            }
            return data!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContactsTableViewCell
        if typeID == 1{
            //转让群主页面
            
            
            if searchArr?.count ?? 0 > 0 {
                cell.headImgView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                
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
                cell.nickNameLabel.text = text

                cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", searchArr![indexPath.row]!.id_card!)
                if indexPath.row == searchArr!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }else{
                cell.headImgView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                
                
                
                var text:String? = ""
                if QueryFriend.shared.checkFriend(userID: (data?[indexPath.row ]!.user_id)!) {
                    
                    if data?[indexPath.row ]?.friend_name != ""
                    {
                        text = data?[indexPath.row ]?.friend_name
                    }else
                    {
                        text = data?[indexPath.row ]?.user_name
                    }
                    
                    
                    
                }else{
                    if data?[indexPath.row ]?.group_user_nickname != "" {
                        text = data?[indexPath.row ]?.group_user_nickname;
                    }else{
                        text = data?[indexPath.row ]?.user_name
                    }
                }
                cell.nickNameLabel.text = text
                cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data![indexPath.row]!.id_card!)
                if indexPath.row == data!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }
            cell.Jiantou.isHidden = true
            
        }else if typeID == 2
        {
            
            if( user?.is_administrator == 1 || user?.is_manager == 1)
            {
                if indexPath.row == 0
                {
                     let allcell = tableView.dequeueReusableCell(withIdentifier: "allcell") as! AllGroupTableViewCell
                    allcell.AllgroupLabel.text = "@全部成员";
                    return allcell
                }else
                {
                    if searchArr?.count ?? 0 > 0 {
                        cell.headImgView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                        
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
                        cell.nickNameLabel.text = text
                        
                        
                        cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", searchArr![indexPath.row]!.id_card!)
                        if indexPath.row == searchArr!.count - 1 {
                            cell.bottonView.isHidden = true
                        }else{
                            cell.bottonView.isHidden = false
                        }
                    }else{
                        cell.headImgView.sd_setImage(with: URL(string: data![indexPath.row - 1]!.portrait!), placeholderImage: UIImage(named: "moren"))
                        
                        
                        var text:String? = ""
                        if QueryFriend.shared.checkFriend(userID: (data?[indexPath.row - 1]!.user_id)!) {
                            
                            if data?[indexPath.row - 1]?.friend_name != ""
                            {
                                text = data?[indexPath.row - 1]?.friend_name
                            }else
                            {
                                text = data?[indexPath.row - 1]?.user_name
                            }
                            
                            
                            
                        }else{
                            if data?[indexPath.row - 1]?.group_user_nickname != "" {
                                text = data?[indexPath.row - 1]?.group_user_nickname;
                            }else{
                                text = data?[indexPath.row - 1]?.user_name
                            }
                        }
                        cell.nickNameLabel.text = text
                        
                        cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data![indexPath.row - 1]!.id_card!)
                        if indexPath.row == data!.count - 2 {
                            cell.bottonView.isHidden = true
                        }else{
                            cell.bottonView.isHidden = false
                        }
                    }
                }
                
                
                
            }else if (user?.is_administrator == 2 && user?.is_manager == 2){
                if searchArr?.count ?? 0 > 0 {
                    cell.headImgView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                    
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
                    cell.nickNameLabel.text = text
                    
                    
                    cell.Idlabel.isHidden=true
                    if indexPath.row == searchArr!.count - 1 {
                        cell.bottonView.isHidden = true
                    }else{
                        cell.bottonView.isHidden = false
                    }
                }else{
                    cell.headImgView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                    var text:String? = ""
                    if QueryFriend.shared.checkFriend(userID: (data?[indexPath.row ]!.user_id)!) {
                        
                        if data?[indexPath.row ]?.friend_name != ""
                        {
                            text = data?[indexPath.row ]?.friend_name
                        }else
                        {
                            text = data?[indexPath.row ]?.user_name
                        }
                        
                        
                        
                    }else{
                        if data?[indexPath.row ]?.group_user_nickname != "" {
                            text = data?[indexPath.row ]?.group_user_nickname;
                        }else{
                            text = data?[indexPath.row ]?.user_name
                        }
                    }
                    cell.nickNameLabel.text = text
                    
                    cell.Idlabel.isHidden=true
                    if indexPath.row == data!.count - 1 {
                        cell.bottonView.isHidden = true
                    }else{
                        cell.bottonView.isHidden = false
                    }
                }
                
            }
            }
            
            
            
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if typeID == 1{
            if searchArr != nil {
                let alert = UIAlertController(title: "确定转让给:", message: "\(searchArr![indexPath.row]!.user_name!)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                    self.changeOwner(id: self.searchArr![indexPath.row]!.user_id)
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancel)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "确定转让给:", message: "\(data![indexPath.row]!.user_name!)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                    self.changeOwner(id: self.data![indexPath.row]!.user_id)
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancel)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
            }
        }else if typeID == 2
        {
            if searchArr != nil {
                delegate?.onAtClick(member: searchArr![indexPath.row])
                self.navigationController?.popViewController(animated: true)
                return
            }
            if ( user?.is_administrator == 1 || user?.is_manager == 1) {
                if indexPath.row == 0
                {
                    delegate?.onAtClick(member: nil)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                delegate?.onAtClick(member: data![indexPath.row - 1])
                self.navigationController?.popViewController(animated: true)
                return
            }
            else{
                delegate?.onAtClick(member: data![indexPath.row])
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil {
            cancelBtn.isHidden = true
        }else if textField.text!.count == 0 {
            cancelBtn.isHidden = true
        }else{
            cancelBtn.isHidden = false
        }
        sorted(keyWord: textField.text!)
    }
    
    func sorted(keyWord:String) {
        searchArr  = nil
        guard let da = data else {
            return
        }
        for con in da {
            if con?.group_user_nickname?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
            if con?.id_card?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
        }
        if searchArr != nil {
            searchArr = NSSet(array: searchArr!).allObjects as! [GroupMemberData?]
        }
        table?.reloadData()
    }
    
    func changeOwner(id:String?) {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        
        let model = ChangeGroupOwnerSendModel()
        model.group_id = self.model?.groupId
        model.newowner_id = id
        BoXinProvider.request(.ChangeGroupOwner(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getGroupInfo(groupId: self.model!.groupId!, Complite: nil)
                                let body = EMCmdMessageBody(action: "")
                                let dic = ["type":"qunAdmin","id":self.model?.groupId,"userid":id,"oldadmin":self.model?.administrator_id]
                                let msg = EMMessage(conversationID: self.model!.groupId!, from: EMClient.shared()?.currentUsername, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                msg?.chatType = EMChatTypeGroupChat
                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                    
                                }, completion: { (msg, err) in
                                    if err != nil {
                                        print(err?.errorDescription)
                                    }
                                    
                                })
                                SVProgressHUD.dismiss()
                                self.navigationController?.popToRootViewController(animated: true)
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

}
