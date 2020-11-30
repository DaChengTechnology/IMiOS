//
//  ContactsViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage
import MJRefresh



class ContactsViewController: EaseUsersListViewController,EMUserListViewControllerDataSource,EMContactManagerDelegate,UISearchControllerDelegate,UISearchResultsUpdating {
    var isload:Bool = false
    var friendCount:Int = 0
    var data:[FriendGroupData] = Array<FriendGroupData>()
    var contact:[FriendViewModel?]?
    var searchController = UISearchController(searchResultsController: nil)
    var group:[GroupViewModel]?
    var contactData:[FriendData?]?
    var groupData:[GroupViewModel]?
    var selectFriend:FriendData?
    var selectGroup:GroupViewModel?
    override func viewWillAppear(_ animated: Bool) {
//        searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: (searchController.searchBar.bounds.width-searchController.searchBar.searchTextField.placeholderRect(forBounds: searchController.searchBar.searchTextField.bounds).width-40-40)/2, vertical: 0), for: .search)
        super.viewWillAppear(animated)
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DCUtill.setNavigationBarShadow(controller: self)
        tableView.separatorStyle = .none
        searchController.delegate=self
        searchController.searchResultsUpdater=self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor=self.navigationController?.navigationBar.tintColor
        tableView.tableHeaderView=searchController.searchBar
        tableView.register(UINib(nibName: "AddContentTableViewCell", bundle: nil), forCellReuseIdentifier: "AddContent")
        tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchContacts")
        tableView.register(UINib(nibName: "ContractCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        tableView.register(FriendGroupTitleCell.classForCoder(), forCellReuseIdentifier: "FriendGroupTitle")
        tableView.register(ContractNumCell.classForCoder(), forCellReuseIdentifier: "ContractNum")
        tableView.backgroundColor = UIColor.white
        let long = UILongPressGestureRecognizer(target: self, action: #selector(onLongPass(g:)))
        long.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(long)
        showRefreshHeader = false
        EMClient.shared()?.contactManager.add(self, delegateQueue: DispatchQueue.main)
        tableView.estimatedSectionFooterHeight = 0
        NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateFriend"), object: nil, queue: OperationQueue.main) { (n) in
            self.tableViewDidTriggerHeaderRefresh()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        let plus = UIBarButtonItem(image: UIImage(named: "添加(1)"), style: .plain, target: self, action: #selector(onPlus))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([plus], animated: false)
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem=nil
        tableViewDidTriggerHeaderRefresh()
    }
    
    @objc func onLongPass(g:UIGestureRecognizer) {
        if self.presentingViewController == nil {
            let point = g.location(in: tableView)
            let indexpath = tableView.indexPathForRow(at: point)
            if indexpath?.row != 0 {
                return
            }
            if indexpath?.section == 0 {
                return
            }
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "分组管理", style: .default, handler: { (a) in
                for i in 0 ..< self.data.count {
                    self.data[i].isShow = false
                }
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(FriendGroupMenagerViewController(), animated: true)
            }))
            sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .destructive, handler: nil))
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    override func loadView() {
        data = ([FriendGroupData].deserialize(from: UserDefaults.standard.string(forKey: "Contact1")) ?? Array<FriendGroupData>())as! [FriendGroupData]
        super.loadView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }
        return data.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return (contactData?.count ?? 0) + (groupData?.count ?? 0)
        }
        if section == 0 {
            return 4
        }
        guard section-1 < data.count else {
            return 0
        }
        let fdata = data[section-1]
        if fdata.isShow {
            return fdata.friendList.count + 1
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive {
            return 56
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 3 {
                return DCUtill.SCRATIO(x: 10)
            }
            return DCUtill.SCRATIO(x: 50)
        }
        if indexPath.row == 0 {
            return DCUtill.SCRATIO(x: 50)
        }
        return DCUtill.SCRATIO(x: 64)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContacts") as! ContactsTableViewCell
            if indexPath.row < (contactData?.count ?? 0) {
                if contactData![indexPath.row]!.user_id == "收藏" {
                    cell.headImgView.image = UIImage(named: "collectionHead")
                    cell.nickNameLabel.text = "我的收藏"
                    cell.Idlabel.isHidden = true
                    if indexPath.row == contactData!.count - 1 {
                        cell.bottonView.isHidden = true
                    }else{
                        cell.bottonView.isHidden = false
                    }
                    cell.Jiantou.isHidden=true
                    return cell
                }
                cell.headImgView.sd_setImage(with: URL(string: contactData![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                cell.nickNameLabel.text = contactData![indexPath.row]!.target_user_nickname
                cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contactData![indexPath.row]!.id_card!)
                if indexPath.row == contactData!.count - 1 {
                    cell.bottonView.isHidden = true
                }
            }else{
                if indexPath.row - (contactData?.count ?? 0) > groupData?.count ?? 0 {
                    return cell
                }
                let des = groupData![indexPath.row - (contactData?.count ?? 0)]
                cell.headImgView.sd_setImage(with: URL(string: des.portrait!), placeholderImage: UIImage(named: "群聊11111"))
                cell.nickNameLabel.text = des.groupName
                cell.Idlabel.isHidden = true
                if indexPath.row == groupData!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }
            cell.Jiantou.isHidden=true
            return cell
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddContent") as! AddContentTableViewCell
            if indexPath.row == 1 {
                cell.tittleImageView?.image = UIImage(named: "添加")
                cell.tittleLable?.text = NSLocalizedString("NewFriend", comment: "New friend")
                cell.imageView?.image = nil
                let app = UIApplication.shared.delegate as! AppDelegate
                if app.addFriendCount != 0 {
                    cell.pp.moveBadge(x: -30, y: 25)
                    cell.pp.addBadge(number: app.addFriendCount)
                }else{
                    cell.pp.hiddenBadge()
                }                
            }
            if indexPath.row == 2 {
                cell.imageView?.image = nil
                cell.tittleImageView?.image = UIImage(named: "群组")
                cell.tittleLable?.text = "群组"
                cell.pp.hiddenBadge()
            }
            if indexPath.row == 0 || indexPath.row == 3 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "HCell")
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor  = UIColor.clear
                cell.selectionStyle = .none
                return cell
            }
             return cell
        }else{
            let groupFriend = data[indexPath.section - 1]
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendGroupTitle") as! FriendGroupTitleCell
                cell.setShow(show: groupFriend.isShow)
                cell.groupTitle.text = groupFriend.fenzu_name
                cell.groupCount.text = "\(groupFriend.feirnd_num)"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContractCell
            cell.imageView?.image = nil
            if groupFriend.friendList[indexPath.row-1].portrait != nil {
                cell.headImageView.sd_setImage(with: URL(string: groupFriend.friendList[indexPath.row-1].portrait!)!, placeholderImage: UIImage(named: "moren"))
            }else{
                cell.headImageView.image = UIImage(named: "moren")
            }
            cell.idCaardLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", groupFriend.friendList[indexPath.row-1].id_card!)
            cell.nickNameLabel.text = groupFriend.friendList[indexPath.row-1].target_user_nickname
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            if indexPath.row < (self.contactData?.count ?? 0) {
                selectFriend=contactData![indexPath.row]
            }else{
                if indexPath.row - (self.contactData?.count ?? 0) >= (self.groupData?.count ?? 0) {
                    return
                }
                selectGroup = self.groupData![indexPath.row - (self.contactData?.count ?? 0)]
            }
            searchController.isActive=false
            searchController.searchBar.resignFirstResponder()
            return
        }
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let cell = tableView.cellForRow(at: indexPath)
                cell?.pp.hiddenBadge()
                let vc = InvitationFriendTableViewController()
                self.tabBarItem.pp.hiddenBadge()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 2 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = MyGroupTableViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if indexPath.section > 0 {
            if indexPath.row == 0 {
                data[indexPath.section - 1].isShow = !data[indexPath.section - 1].isShow
                tableView.reloadData()
                return
            }
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let model = data[indexPath.section-1].friendList[indexPath.row-1]
            let vc = UserDetailViewController()
            vc.type=4
            vc.model=model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableViewDidTriggerHeaderRefresh() {
        self.getFriends()
    }
    
    func getFriends() {
        if searchController.isActive {
            return
        }
        if isload {
            return
        }
        isload = true
        BoXinProvider.request(.FriendListWithFenzu(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GetFriendWithGroupReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                let friendGroupInfo = model.data.map { (f) -> FriendGroupInfoData in
                                    let fd = FriendGroupInfoData()
                                    fd.fenzu_id = f.fenzu_id
                                    fd.fenzu_name = f.fenzu_name
                                    fd.sort_num = f.sort_num
                                    return fd
                                }
                                UserDefaults.standard.set(friendGroupInfo.toJSONString(), forKey: "FriendGroup")
                                if self.data.count == model.data.count {
                                    for i in 0 ..< self.data.count {
                                        model.data[i].isShow = self.data[i].isShow
                                    }
                                }
                                dbQuese.async {
                                    for fd in model.data {
                                        for f in fd.friendList {
                                            QueryFriend.shared.addFriend(f)
                                        }
                                    }
                                }
                                UserDefaults.standard.setValue(model.data.toJSONString(), forKey: "Contact1")
                                UserDefaults.standard.synchronize()
                                self.data = model.data
                                self.isload = false
                                self.tableViewDidFinishTriggerHeader(true, reload: true)
                            }else{
                                self.isload = false
                                if (model.message?.contains("请重新登录"))! {
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
                                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                }
                                self.tableViewDidFinishTriggerHeader(true, reload: false)
                                self.view.makeToast(model.message)
                            }
                        }else{
                            self.isload = false
                            self.tableViewDidFinishTriggerHeader(true, reload: false)
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        self.isload = false
                        self.tableViewDidFinishTriggerHeader(true, reload: false)
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    self.isload = false
                    self.tableViewDidFinishTriggerHeader(true, reload: false)
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                }
            case .failure(let err):
                self.isload = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                self.tableViewDidFinishTriggerHeader(true, reload: false)
                print(err.errorDescription!)
            }
        }
        BoXinProvider.request(.FriendList(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = FriendListReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.sorted(model: model.data, Complite: nil)
                            }else{
                                if (model.message?.contains("请重新登录"))! {
                                    DispatchQueue.main.async {
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
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    
    func sorted(model :[FriendData?]?) {
        var arrt = Array<FriendViewModel>()
        QueryFriend.shared.clearFriend()
        for a in model! {
            QueryFriend.shared.addFriend(id: a!.user_id!, nickName: a!.target_user_nickname!, portrait1: a!.portrait!, card: a!.id_card!)
        }
        var data = model
        var star:FriendViewModel?
        var isEnd = false
        while !isEnd {
            if let m = data {
                if m.count == 0 {
                    isEnd = true
                    if star != nil {
                        arrt.append(star!)
                        star =  nil
                    }
                }
                for ms in 0 ..< data!.count {
                    if data![ms]?.is_star == 1 {
                        if star == nil{
                            star = FriendViewModel()
                            star?.tittle = "*"
                            star?.data = Array<FriendData>()
                            star?.data?.append(m[ms])
                        }else{
                            star?.data?.append(m[ms])
                        }
                        data?.remove(at: ms)
                        break
                    }
                    if ms == data!.count - 1 {
                        isEnd = true
                        if star != nil {
                            arrt.append(star!)
                            star =  nil
                        }
                    }
                }
            }else{
                isEnd = true
                if star != nil {
                    arrt.append(star!)
                    star =  nil
                }
            }
        }
        
        star = nil
        let arr = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R",
        "S","T","U","V","W","X","Y","Z"]
        for s in arr {
            var isEnd = false
            var lastCount:Int = 0
            while !isEnd {
                if data?.count != 0 {
                    for ms in 0 ..< data!.count {
                        let first = String((data![ms]?.target_user_nickname!.first)!)
                        if first.isIncludeChinese() {
                            if String(first.getPinyinHead().first!).uppercased() == s {
                                if star == nil{
                                    star = FriendViewModel()
                                    star?.tittle = s
                                    star?.data = Array<FriendData>()
                                    star?.data?.append(data![ms])
                                }else{
                                    star?.data?.append(data![ms])
                                }
                                data?.remove(at: ms)
                                break
                            }
                        }else{
                            if first.uppercased() == s {
                                if star == nil{
                                    star = FriendViewModel()
                                    star?.tittle = s
                                    star?.data = Array<FriendData>()
                                    star?.data?.append(data![ms])
                                }else{
                                    star?.data?.append(data![ms])
                                }
                                data?.remove(at: ms)
                                break
                            }
                        }
                        if ms == data!.count - 1 {
                            isEnd = true
                            if star != nil {
                                arrt.append(star!)
                                star =  nil
                            }
                        }
                    }
                    if star != nil {
                        if lastCount == star?.data?.count {
                            arrt.append(star!)
                            star =  nil
                        }else{
                            lastCount = star!.data!.count
                        }
                    }
                }else{
                    isEnd = true
                    if star != nil {
                        arrt.append(star!)
                        star =  nil
                    }
                }
            }
        }
        
        if data?.count != 0 {
            star = FriendViewModel()
            star?.tittle = "#"
            star?.data = data
            arrt.append(star!)
        }
        let d = arrt
        let s = d.toJSONString()
        UserDefaults.standard.setValue(s, forKey: "Contact")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.dataArray.removeAllObjects()
            for a in arrt {
                self.dataArray.add(a)
            }
            CATransaction.begin()
           CATransaction.setDisableActions(true)
            self.tableView.reloadData()
            CATransaction.commit()
        }
        self.tableViewDidFinishTriggerHeader(true, reload: false)
        DispatchQueue.main.async {
            self.isload = false
        }
    }
    
    @objc func onSearch() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        self.navigationController?.pushViewController(sb.instantiateViewController(withIdentifier: "Search"), animated: true)
    }
    
    @objc func onPlus(){
        PlusView().show()
    }
    
    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.addFriendCount += 1
        self.tabBarItem.badgeValue = String(format: "%d", app.addFriendCount)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.pp.moveBadge(x: -20, y: 25)
        cell?.pp.addBadge(number: app.addFriendCount)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        search(keyWord: searchController.searchBar.text ?? "")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.setPositionAdjustment(.zero, for: .search)
        DispatchQueue.global().async {
            self.contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
            self.group = QueryFriend.shared.getAllGroup()
        }
        search(keyWord: searchController.searchBar.text ?? "")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
//        searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: (searchController.searchBar.bounds.width-searchController.searchBar.searchTextField.placeholderRect(forBounds: searchController.searchBar.searchTextField.bounds).width-40-20)/2, vertical: 0), for: .search)
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableViewDidTriggerHeaderRefresh()
        guard let friend = selectFriend else {
            guard let des = selectGroup else {
                return
            }
            let vc = ChatViewController(conversationChatter: des.groupId, conversationType: EMConversationTypeGroupChat)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            vc?.title = des.groupName
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        if friend.user_id == "收藏" {
            let vc = CollectionViewController(conversationChatter: "collection", conversationType: EMConversationTypeChat)
             self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        let vc = ChatViewController(conversationChatter: friend.user_id, conversationType: EMConversationTypeChat)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        vc?.title = (friend.target_user_nickname?.isEmpty ?? true) ? friend.friend_self_name : friend.target_user_nickname
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func search(keyWord:String) {
        contactData  = nil
        groupData = nil
        if keyWord.isEmpty {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
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
            if "我的收藏".contains(keyWord) {
                if contactData == nil {
                    contactData = Array<FriendData>()
                }
                let f = FriendData()
                f.user_id = "收藏"
                contactData?.append(f)
            }
            if contactData != nil {
                contactData = NSSet(array: contactData!).allObjects as! [FriendData?]
            }
        }
        groupData = nil
        if group != nil {
            for g in group! {
                if g.groupName!.contains(keyWord) {
                    if groupData == nil {
                        groupData = Array<GroupViewModel>()
                    }
                    groupData?.append(g)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
