//
//  ShareFriendViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/17/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class ShareFriendViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var textSearchTextFeild:UITextField?
    var table:UITableView?
    let cancelBtn = UIButton(type: .custom)
    var contact:[FriendViewModel?]?
    var contactData:[FriendData?]?
    var model:FriendData?
    var isMutableSelect:Bool = false
    var selectData:[FriendData?]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
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
        textSearchTextFeild?.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        topView.addSubview(textSearchTextFeild!)
        textSearchTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(searchImageView.mas_right)?.offset()(8)
            make?.top.equalTo()(topView.mas_top)?.offset()(5)
            make?.right.equalTo()(cancelBtn.mas_left)?.offset()(-8)
            make?.bottom.equalTo()(topView.mas_bottom)?.offset()(-8)
        })
        let line = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "D9D9D9")
        topView.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView)
            make?.right.equalTo()(topView)
            make?.bottom.equalTo()(topView)
            make?.height.mas_equalTo()(1)
        }
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        table?.backgroundColor = UIColor.white
        table?.dataSource = self
        table?.delegate = self
        table?.separatorStyle = .none
        contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        var i = 0
        var j = 0
        for c in contact! {
            j = 0
            for data in c!.data! {
                if data?.user_id == model?.user_id {
                    contact?[i]?.data?.remove(at: j)
                    if contact?[i]?.data?.count == 0 {
                        contact?.remove(at: i)
                    }
                }
                j += 1
            }
            i += 1
        }
        self.view.addSubview(table!)
        table?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        })
        table?.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        table?.register(UINib(nibName: "SelectUserTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectUser")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("MutiChoice", comment: "Choice"), style: .plain, target: self, action: #selector(onMutabelSelect))
        self.title = NSLocalizedString("ShareBusiness", comment: "Share business card")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    @objc func onCancel() {
        textSearchTextFeild?.text = nil
        contactData = nil
        cancelBtn.isHidden = true
        table?.reloadData()
    }
    
    @objc func onMutabelSelect() {
        isMutableSelect = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: .plain, target: self, action: #selector(onComplite))
        onCancel()
    }
    
    @objc func onComplite() {
        guard let select = selectData else {
            let alert = UIAlertController(title: NSLocalizedString("PlzSelectContract", comment: "Please select contract"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if select.count == 0 {
            let alert = UIAlertController(title: NSLocalizedString("PlzSelectContract", comment: "Please select contract"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        SVProgressHUD.show()
        let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
        for data1 in select {
            let body = EMTextMessageBody(text: "[名片]")
            let message = EMMessage(conversationID: data1!.user_id!, from: EMClient.shared()!.currentUsername, to: data1!.user_id!, body: body, ext: ["type":"person","id":self.model!.user_id!,"JPZReceivePortrait":data1?.portrait,"JPZReceiveNikeName":data1?.friend_self_name,"JPZIsFrom":"Chat","JPZUserPortrait":data?.db?.portrait,"JPZUserNikeName":data?.db?.user_name,"isFired":data1?.is_yhjf,"username":data1!.friend_self_name,"usernum":data1!.id_card,"userhead":data1!.portrait])
            EMClient.shared()?.chatManager.send(message, progress: { (p) in
                
            }, completion: { (m, e) in
                print(e?.errorDescription)
            })
        }
        SVProgressHUD.dismiss()
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if contactData == nil && !(textSearchTextFeild?.text?.isEmpty ?? true) {
            return  0
        }
        if contactData != nil {
            return  1
        }
        return contact!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactData != nil {
            return contactData!.count
        }
        return contact![section]!.data!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isMutableSelect {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUser", for: indexPath) as! SelectUserTableViewCell
            if contactData?.count ?? 0 > 0 {
                cell.headImageView.sd_setImage(with: URL(string: contactData![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                cell.nameLabel.text = contactData![indexPath.row]!.target_user_nickname
                cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contactData![indexPath.row]!.id_card!)
                if checkSelect(friend: contactData![indexPath.row]) {
                    cell.selectImageView.image = UIImage(named: "对号")
                }else{
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }
                if indexPath.row == contactData!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }else{
                cell.headImageView.sd_setImage(with: URL(string: contact![indexPath.section]!.data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                cell.nameLabel.text = contact![indexPath.section]!.data![indexPath.row]!.target_user_nickname
                cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contact![indexPath.section]!.data![indexPath.row]!.id_card!)
                if checkSelect(friend: contact![indexPath.section]!.data![indexPath.row]) {
                    cell.selectImageView.image = UIImage(named: "对号")
                }else{
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }
                if indexPath.row == contact![indexPath.section]!.data!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContactsTableViewCell
        if contactData?.count ?? 0 > 0 {
            cell.headImgView.sd_setImage(with: URL(string: contactData![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            cell.nickNameLabel.text = contactData![indexPath.row]!.target_user_nickname
            cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contactData![indexPath.row]!.id_card!)
            if indexPath.row == contactData!.count - 1 {
                cell.bottonView.isHidden = true
            }else{
                cell.bottonView.isHidden = false
            }
        }else{
            cell.headImgView.sd_setImage(with: URL(string: contact![indexPath.section]!.data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            cell.nickNameLabel.text = contact![indexPath.section]!.data![indexPath.row]!.target_user_nickname
            cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contact![indexPath.section]!.data![indexPath.row]!.id_card!)
            if indexPath.row == contact![indexPath.section]!.data!.count - 1 {
                cell.bottonView.isHidden = true
            }else{
                cell.bottonView.isHidden = false
            }
        }
        cell.Jiantou.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if contactData != nil {
            return 0
        }
        return 21
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if contactData != nil {
            return nil
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 27))
        headerView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        headerView.addSubview(lable)
        lable.font = UIFont.systemFont(ofSize: 14)
        if contact![section]!.tittle == "*" {
            lable.text = "星标朋友"
        }else{
            lable.text = contact![section]!.tittle
        }
        lable.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView.mas_left)?.setOffset(8)
            make?.centerY.equalTo()(headerView)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isMutableSelect {
            let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            if contactData != nil {
                let alert = UIAlertController(title: NSLocalizedString("ShareBusiness", comment: "Share business card"), message: NSLocalizedString("QuestionShareTo", comment: "Are you sure share to") + contactData![indexPath.row]!.target_user_nickname!, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                    let body = EMTextMessageBody(text: "[名片]")
                    let message = EMMessage(conversationID: self.contactData![indexPath.row]!.user_id!, from: data!.db!.user_id, to: self.contactData![indexPath.row]!.user_id!, body: body, ext: ["type":"person","id":self.model!.user_id!,"JPZReceivePortrait":self.contactData![indexPath.row]!.portrait,"JPZReceiveNikeName":self.contactData![indexPath.row]!.friend_self_name,"JPZIsFrom":"Chat","JPZUserPortrait":data?.db?.portrait,"JPZUserNikeName":data?.db?.user_name,"isFired":self.contact![indexPath.section]!.data![indexPath.row]!.is_yhjf,"username":self.contactData![indexPath.row]!.friend_self_name,"usernum":self.contactData![indexPath.row]!.id_card,"userhead":self.contactData![indexPath.row]!.portrait])
                    EMClient.shared()?.chatManager.send(message, progress: { (p) in
                        
                    }, completion: { (m, e) in
                        print(e?.errorDescription)
                    })
                    self.navigationController?.popViewController(animated: true)
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancel)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: NSLocalizedString("ShareBusiness", comment: "Share business card"), message: NSLocalizedString("QuestionShareTo", comment: "Are you sure share to") + contact![indexPath.section]!.data![indexPath.row]!.target_user_nickname!, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                    let body = EMTextMessageBody(text: "[名片]")
                    print(body)
                    let message = EMMessage(conversationID: self.contact![indexPath.section]!.data![indexPath.row]!.user_id!, from: data!.db!.user_id!, to: self.contact![indexPath.section]!.data![indexPath.row]!.user_id!, body: body, ext: ["type":"person","id":self.model!.user_id!,"JPZReceivePortrait":self.contact![indexPath.section]!.data![indexPath.row]!.portrait,"JPZReceiveNikeName":self.contact![indexPath.section]!.data![indexPath.row]!.friend_self_name,"JPZIsFrom":"Chat","JPZUserPortrait":data?.db?.portrait,"JPZUserNikeName":data?.db?.user_name,"isFired":self.contact![indexPath.section]!.data![indexPath.row]!.is_yhjf,"username":self.contact![indexPath.section]!.data![indexPath.row]!.friend_self_name,"usernum":self.contact![indexPath.section]!.data![indexPath.row]!.id_card,"userhead":self.contact![indexPath.section]!.data![indexPath.row]!.portrait])
                    EMClient.shared()?.chatManager.send(message, progress: { (p) in
                        
                    }, completion: { (m, e) in
                        print(e?.errorDescription)
                    })
                    self.navigationController?.popViewController(animated: true)
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancel)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! SelectUserTableViewCell
            if contactData != nil {
                if checkSelect(friend: contactData![indexPath.row]) {
                    removeSelect(friend: contactData![indexPath.row])
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }else{
                    if selectData == nil {
                        selectData = Array<FriendData>()
                    }
                    selectData?.append(contactData![indexPath.row])
                    selectData = NSSet(array: selectData as! [Any]).allObjects as! [FriendData]
                    cell.selectImageView.image = UIImage(named: "对号")
                }
            }else{
                if checkSelect(friend: contact![indexPath.section]!.data![indexPath.row]) {
                    removeSelect(friend: contact![indexPath.section]!.data![indexPath.row])
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }else{
                    if selectData == nil {
                        selectData = Array<FriendData>()
                    }
                    selectData?.append(contact![indexPath.section]!.data![indexPath.row])
                    selectData = NSSet(array: selectData as! [Any]).allObjects as! [FriendData]
                    cell.selectImageView.image = UIImage(named: "对号")
                }
            }
        }
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        if textSearchTextFeild?.markedTextRange != nil {
            return
        }
        if textField.text == nil {
            cancelBtn.isHidden = true
        }else if textField.text!.count == 0 {
            cancelBtn.isHidden = true
        }else{
            cancelBtn.isHidden = false
        }
        sorted(keyWord: textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func sorted(keyWord:String) {
        contactData  = nil
        if contact != nil {
            for con in contact! {
                for c in (con?.data!)! {
                    if (c?.target_user_nickname?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                    if (c?.id_card?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                    if (c?.friend_self_name?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                }
            }
        }
        if contactData != nil {
            contactData = NSSet(array: contactData! as [Any]).allObjects as! [FriendData]
        }
        table?.reloadData()
    }
    
    func checkSelect(friend:FriendData?) -> Bool {
        if selectData != nil {
            for data in selectData! {
                if data?.user_id == friend?.user_id {
                    return true
                }
            }
        }
        return false
    }
    
    func removeSelect(friend:FriendData?) {
        if selectData != nil {
            var i = 0
            for data in selectData! {
                if data?.user_id == friend?.user_id {
                    selectData?.remove(at: i)
                    return
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
