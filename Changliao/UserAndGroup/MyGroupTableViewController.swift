//
//  MyGroupTableViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage

class MyGroupTableViewController: UITableViewController {
    
    var data:[GroupViewModel]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        tableView.separatorStyle = .none
        title = NSLocalizedString("Group", comment: "Group")
        tableView.register(UINib(nibName: "NewGroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupListTableViewCellID")
        data = QueryFriend.shared.getAllGroup()
        tableView.rowHeight = DCUtill.SCRATIO(x: 60)
        if data != nil {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        BoXinUtil.getOnlyMyGroup { (group) in
            if let g = group {
                self.data = g
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell")
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCellID", for: indexPath) as! NewGroupListTableViewCell
        // Configure the cell...
        cell.HeadImage.sd_setImage(with: URL(string: data![indexPath.row].portrait!), placeholderImage: UIImage(named: "群聊11111"))
        cell.NameLab.text = data![indexPath.row].groupName
         if data![indexPath.row].group_type == 2
        {
            cell.WorkImage.isHidden = true
        }else
        {
            cell.WorkImage.isHidden = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        let vc = ChatViewController(conversationChatter: data![indexPath.row].groupId!, conversationType: EMConversationTypeGroupChat)
        vc?.title = data![indexPath.row].groupName
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
