//
//  SearchGroupMemberViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/6/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class SearchGroupMemberViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var textSearchTextFeild:UITextField?
    var table:UITableView?
    let cancelBtn = UIButton(type: .custom)
   var model:GroupViewModel?
    var me:GroupMemberData?
    var data:[GroupMemberData?]?
    var searchArr:[GroupMemberData?]?

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
        table?.register(UINib(nibName: "SearchMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchMember")
        self.title = "全部群成员"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
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
        if textField.text == nil {
            cancelBtn.isHidden = true
            searchArr = nil
            table?.reloadData()
            return
        }else if textField.text!.count == 0 {
            cancelBtn.isHidden = true
            searchArr = nil
            table?.reloadData()
            return
        }else{
            cancelBtn.isHidden = false
        }
        sorted(keyWord: textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidChange(textField: textField)
        return true
    }
    
    func sorted(keyWord:String) {
        searchArr  = Array<GroupMemberData?>()
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
            if con?.user_name?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
            if con?.friend_name?.contains(keyWord) ?? false {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchArr != nil {
            return searchArr!.count
        }
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMember") as! SearchMemberTableViewCell
        if searchArr?.count ?? 0 > 0 {
            cell.headImageView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            
            
            if searchArr?[indexPath.row]?.friend_name?.isEmpty ?? true
            {
                if searchArr?[indexPath.row]?.group_user_nickname?.isEmpty ?? true
                {
                    cell.nameLabel.text = searchArr?[indexPath.row ]?.user_name
                }else
                {
                    cell.nameLabel.text = searchArr?[indexPath.row ]?.group_user_nickname
                }
                
                
            }else
            {
                if searchArr![indexPath.row]?.friend_name?.isEmpty ?? true
                {
                    if searchArr![indexPath.row]?.group_user_nickname?.isEmpty ?? true
                    {
                        cell.nameLabel.text = searchArr?[indexPath.row]?.user_name
                    }else
                    {
                        cell.nameLabel.text = searchArr?[indexPath.row]?.group_user_nickname
                    }
                    
                }else
                {
                    cell.nameLabel.text = searchArr?[indexPath.row]?.friend_name
                }
            }
            
            cell.idLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", searchArr?[indexPath.row]?.id_card ?? "")
        }else{
            cell.headImageView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            
            if data?[indexPath.row]?.friend_name?.isEmpty ?? true
            {
                if data?[indexPath.row]?.group_user_nickname?.isEmpty ?? true
                {
                    cell.nameLabel.text = data?[indexPath.row ]?.user_name
                }else
                {
                    cell.nameLabel.text = data?[indexPath.row ]?.group_user_nickname
                }
                
                
            }else
            {
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
            }
            
            
            cell.idLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data?[indexPath.row]?.id_card ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchArr?.count ?? 0 > 0 {
            jumpToPersonPage(m: searchArr![indexPath.row]!)
            return
        }
        jumpToPersonPage(m: data![indexPath.row]!)
    }
    
    func jumpToPersonPage(m:GroupMemberData) {
        if m.user_id == me?.user_id {
            return
        }
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        //        let vc = UserDetailViewController()
        let vc = UserDetailViewController()
        let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        if contact == nil {
            BoXinUtil.getFriends { (b) in
                if b {
                    let con  = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                    if con != nil {
                        for c in con! {
                            for d in c!.data! {
                                if d?.user_id == m.user_id {
                                    vc.model=d
                                    vc.member=m
                                    vc.type=3
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    return
                                    
                                }
                            }
                        }
                        vc.type=2
                        vc.member=m
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        UIApplication.shared.keyWindow?.makeToast("网络请求失败")
                    }
                }else{
                    UIApplication.shared.keyWindow?.makeToast("网络请求失败")
                }
            }
            return
        }
        for c in contact! {
            for d in c!.data! {
                if d?.user_id == m.user_id {
                    vc.model=d
                    vc.member=m
                    vc.type=3
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                    
                    
                }
            }
        }
        vc.type=2
        vc.member=m
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
