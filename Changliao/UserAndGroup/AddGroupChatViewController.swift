//
//  AddGroupChatViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD


class AddGroupChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchTextFeild: UITextField!
    var arr:[FriendViewModel?]?
    var searchArr:[FriendData?]?
    var select:[FriendData?]?
    @objc var type = 0
    var data:[GroupMemberData?]?
    var model:GroupViewModel?
    var groupType:Int = 2
    var isSelect:Bool = false
    var isLoading:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.register(UINib(nibName: "SelectUserTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectUser")
        arr = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        if type == 1 {
            for d in data! {
                for i in 0 ..< arr!.count {
                    for j in 0 ..< arr![i]!.data!.count {
                        if d?.user_id == arr![i]!.data![j]?.user_id {
                            arr![i]!.data?.remove(at: j)
                            break
                        }
                    }
                    if arr![i]!.data!.count == 0 {
                        arr!.remove(at: i)
                        break
                    }
                }
            }
        }
        
        select = Array<FriendData>()
        searchTextFeild.delegate = self
        table.delegate = self
        table.dataSource = self
        table.allowsSelectionDuringEditing = true
        searchTextFeild.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        if type == 0 {
            let next = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next"), style: .plain, target: self, action: #selector(onNext))
            self.navigationItem.rightBarButtonItem = next
        }
        if type == 1 {
            let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
            self.navigationItem.rightBarButtonItem = complite
        }
        if type == 2 {
            let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
            self.navigationItem.rightBarButtonItem = complite
            cancelBtn.setImage(UIImage.init(named: ""), for: .normal)
            cancelBtn.setTitle(NSLocalizedString("All", comment: "All"), for: .normal)
            cancelBtn.backgroundColor  = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
            cancelBtn.layer.masksToBounds = true
            cancelBtn.layer.cornerRadius = 4
            cancelBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .normal)
            cancelBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .selected)
            cancelBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .highlighted)
            cancelBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#0148ED"), for: .disabled)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == 1 {
            title = NSLocalizedString("AddGroupMember", comment: "Add group member")
        }
        if type == 2 {
            title = NSLocalizedString("SelectReciver", comment: "Select reciver")
        }
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == 2
        {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        }
    }
   
    @objc func onComplite() {
        if type != 2
        {
            if select == nil {
                let alert = UIAlertController(title: NSLocalizedString("AddGroupMember", comment: "Add group member"), message: NSLocalizedString("PlzSelMember", comment: "Please select member"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            if select!.count < 1 {
                let alert = UIAlertController(title: NSLocalizedString("AddGroupMember", comment: "Add group member"), message: NSLocalizedString("GroupMemberMinnum", comment: "Group members cannot be less than 1"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            if isLoading
            {
                return
            }
            self.isLoading = true
            SVProgressHUD.show()
            let md = AddBatchSendModel()
            md.group_id = model?.groupId
            md.group_user_ids = select![0]?.user_id
            if select!.count > 1 {
                for i in 1 ..< select!.count {
                    md.group_user_ids! += ",\(select![i]!.user_id!)"
                }
            }
            BoXinProvider.request(.GroupAddBatch(model: md)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoading = false
                                    BoXinUtil.getGroupMember(groupID: md.group_id!, Complite: { (b) in
                                        if b{
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                var dic = ["type":"qun","id":md.group_id]
                                                if self.model?.is_all_banned == 1 {
                                                    dic.updateValue("2", forKey: "grouptype")
                                                }else{
                                                    dic.updateValue("1", forKey: "grouptype")
                                                }
                                                let msg = EMMessage(conversationID: md.group_id!, from: EMClient.shared()?.currentUsername, to: md.group_id!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                SVProgressHUD.dismiss()
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        }else
                                        {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                        
                                    })
                                }else{
                                    if model.message == "请重新登录" {
                                        BoXinUtil.Logout()
                                        if (UIViewController.currentViewController() as? BootViewController) != nil {
                                            let app = UIApplication.shared.delegate as! AppDelegate
                                            app.isNeedLogin = true
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
        }else
        {
            //typeID == 2
            
            if select == nil {
                let alert = UIAlertController(title: NSLocalizedString("PlzSelectReciver", comment: "Please select reciver"), message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            if select!.count < 1 {
                let alert = UIAlertController(title: NSLocalizedString("PlzSelectReciver", comment: "Please select reciver"), message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            
            let vc = GroupSendViewController(conversationChatter: "群发", conversationType: EMConversationTypeChat)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            var UserIdArr = Array<String>()
            var str = String()
            str = select![0]!.target_user_nickname!
            UserIdArr.append(select![0]!.user_id!)
            if select!.count > 1 {
                for i in 1 ..< select!.count {
                    
                    UserIdArr.append(select![i]!.user_id!)
                    str += ",\(select![i]!.target_user_nickname!)"
                    
                }
                vc?.userNameString = str
                vc?.userIDs = UserIdArr
            }
            if 1 == select?.count {
                vc?.userNameString = str
                vc?.userIDs = UserIdArr
            }
            self.navigationController?.pushViewController(vc!, animated: true);
            
        }
       
    }
    
    @IBAction func onCanncel(_ sender: Any) {
       
        if type == 2
        {
            isSelect = !isSelect
            if isSelect
            {
                cancelBtn.setTitle(NSLocalizedString("Cancel",  comment: "Cancel"), for: .normal)
                for i in 0 ..< arr!.count {
                    for j in 0 ..< arr![i]!.data!.count
                    {
                        let index:IndexPath = IndexPath.init(row: j, section: i)
//                        self.table.selectRow(at: index as IndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.none)
                        let cell = table.cellForRow(at: index) as? SelectUserTableViewCell
                        if !searchSelectFriend(model: arr![index.section]!.data![index.row]!) {
                            cell?.selectImageView.image = UIImage(named: "对号")
                            select?.append(arr![index.section]!.data![index.row])
                        }
                    }
                }
                isSelect = true
                table.reloadData()
            }else
            {
                cancelBtn.setTitle(NSLocalizedString("All", comment: "All"), for: .normal)
                for i in 0 ..< arr!.count {
                    for j in 0 ..< arr![i]!.data!.count
                    {
                let index:IndexPath = IndexPath.init(row: j, section: i)
//                self.table.selectRow(at: index as IndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.none)
                        
                        let cell = table.cellForRow(at: index) as? SelectUserTableViewCell
                        if searchSelectFriend(model: arr![index.section]!.data![index.row]!) {
                            cell?.selectImageView.image = UIImage(named: "椭圆2")
                            removeSelect(model: arr![index.section]!.data![index.row]!)
                        }
                    }
                }
                
                isSelect = false
                table.reloadData()
            }
        }else{
            searchTextFeild.text = ""
            searchArr?.removeAll()
            table.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchTextFeild.text == "" {
            if arr == nil {
                return 0
            }
            return arr!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchTextFeild.text == "" {
            return arr![section]!.data!.count
        }
        if searchArr == nil {
            return 0
        }
        return searchArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUser") as! SelectUserTableViewCell
       
            if searchTextFeild.text == "" {
                let data = arr![indexPath.section]?.data![indexPath.row]
                if data?.portrait == nil {
                    cell.headImageView.image = UIImage(named: "moren")
                }else{
                    cell.headImageView.sd_setImage(with: URL(string: data!.portrait!), placeholderImage: UIImage(named: "moren"))
                }
                cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", (data?.id_card!)!)
                cell.nameLabel.text = data?.target_user_nickname ?? data?.friend_self_name!
                if searchSelectFriend(model: data!) {
                    cell.selectImageView.image = UIImage(named: "对号")
                }else{
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }
                if indexPath.row == (arr![indexPath.section]?.data!.count)! - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }else{
                let data = searchArr![indexPath.row]
                if data?.portrait == nil {
                    cell.headImageView.image = UIImage(named: "moren")
                }else{
                    cell.headImageView.sd_setImage(with: URL(string: data!.portrait!), placeholderImage: UIImage(named: "moren"))
                }
                cell.IdLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", (data?.id_card!)!)
                cell.nameLabel.text = data?.target_user_nickname ?? data?.friend_self_name!
                if searchSelectFriend(model: data!) {
                    cell.selectImageView.image = UIImage(named: "对号")
                }else{
                    cell.selectImageView.image = UIImage(named: "椭圆2")
                }
                if indexPath.row == searchArr!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchTextFeild.text != "" {
            return nil
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 27))
        headerView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        headerView.addSubview(lable)
        lable.font = UIFont.systemFont(ofSize: 14)
        if (arr![section] as! FriendViewModel).tittle == "*" {
            lable.text = "星标朋友"
        }else{
            lable.text = (arr![section] as! FriendViewModel).tittle
        }
        lable.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView.mas_left)?.setOffset(8)
            make?.centerY.equalTo()(headerView)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchTextFeild.text != "" {
            return 0
        }
        return 30
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchTextFeild.text != "" {
            return nil
        }
        var arr = Array<String>()
        if self.arr != nil {
            for a in self.arr! {
                arr.append(a!.tittle!)
            }
        }
        return arr
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
            let cell = tableView.cellForRow(at: indexPath) as! SelectUserTableViewCell
        if searchTextFeild.text?.isEmpty ?? true {
            if searchSelectFriend(model: arr![indexPath.section]!.data![indexPath.row]!) {
                if isSelect && type == 2 {
                    cancelBtn.setTitle(NSLocalizedString("All", comment: "All"), for: .normal)
                    isSelect = false
                }
                cell.selectImageView.image = UIImage(named: "椭圆2")
                removeSelect(model: arr![indexPath.section]!.data![indexPath.row]!)
            }else{
                cell.selectImageView.image = UIImage(named: "对号")
                select?.append(arr![indexPath.section]!.data![indexPath.row])
                if type == 2 && checkAllSelect() {
                    cancelBtn.setTitle(NSLocalizedString("Cancel",  comment: "Cancel"), for: .normal)
                    isSelect = true
                }
            }
        }else{
            if searchSelectFriend(model: searchArr![indexPath.row]!) {
                if isSelect && type == 2 {
                    cancelBtn.setTitle(NSLocalizedString("All", comment: "All"), for: .normal)
                    isSelect = false
                }
                cell.selectImageView.image = UIImage(named: "椭圆2")
                removeSelect(model: searchArr![indexPath.row]!)
            }else{
                cell.selectImageView.image = UIImage(named: "对号")
                select?.append(searchArr![indexPath.row]!)
                if type == 2 && checkAllSelect() {
                    cancelBtn.setTitle(NSLocalizedString("Cancel",  comment: "Cancel"), for: .normal)
                    isSelect = true
                }
            }
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: UITableViewCell.EditingStyle.insert.rawValue | UITableViewCell.EditingStyle.delete.rawValue)!
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        if textField.markedTextRange != nil {
            return
        }
        if textField.text!.isEmpty {
            if type != 2 {
                cancelBtn.isHidden = true
            }
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }else{
            cancelBtn.isHidden = false
            sorted(keyWord: textField.text!)
        }
    }
    
    func sorted(keyWord:String) {
        searchArr  = nil
        if arr != nil {
            for con in arr! {
                for c in (con?.data!)! {
                    if (c?.target_user_nickname?.contains(keyWord))! {
                        if searchArr == nil {
                            searchArr = Array<FriendData>()
                        }
                        searchArr?.append(c)
                    }
                    if (c?.id_card?.contains(keyWord))! {
                        if searchArr == nil {
                            searchArr = Array<FriendData>()
                        }
                        searchArr?.append(c)
                    }
                    if (c?.friend_self_name?.contains(keyWord))! {
                        if searchArr == nil {
                            searchArr = Array<FriendData>()
                        }
                        searchArr?.append(c)
                    }
                }
            }
        }
        if searchArr != nil {
            searchArr = NSSet(array: searchArr!).allObjects as! [FriendData?]
        }
        table.reloadData()
    }
    
    func searchSelectFriend(model:FriendData) -> Bool {
        for s in select! {
            if model.user_id == s?.user_id {
                return true
            }
        }
        return false
    }
    
    func removeSelect(model:FriendData) {
        var i = 0
        for s in select! {
            if s?.user_id == model.user_id {
                select?.remove(at: i)
            }
            i += 1
        }
    }
    
    @objc func onNext() {      
            if select == nil {
                let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: NSLocalizedString("PlzSelMember", comment: "Please select member"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            if select!.count < 2 {
                let alert = UIAlertController(title: NSLocalizedString("NewGroup",  comment: "New group"), message: "群组成员不能少于2人", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddGyroupInfo") as! AddGroupInfoViewController
            vc.groupMember = select
            vc.groupType = groupType
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkAllSelect() -> Bool {
        var count = 0
        for a in arr! {
            for _ in a!.data! {
                count += 1
            }
        }
        if select != nil {
            if select!.count == count {
                return true
            }
        }
        return false
    }

}
