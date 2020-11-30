//
//  GroupNotifationViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/30/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

class GroupNotifationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var table:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var conversationID:String?
    var conversation:EMConversation?
    var dataArray:[EMMessage]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "群通知"
        table.register(UINib(nibName: "GroupNotifationTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupNotifation")
        self.view.addSubview(table)
        table.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        }
        table.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        conversation = EMClient.shared()?.chatManager.getConversation(conversationID, type: EMConversationTypeChat, createIfNotExist: true)
        conversation?.loadMessagesStart(fromId: nil, count: 20, searchDirection: EMMessageSearchDirectionUp, completion: { (msgs, err) in
            if err == nil {
                if let msgArray = msgs as? [EMMessage] {
                    if self.dataArray == nil {
                        self.dataArray = Array<EMMessage>()
                    }
                    for msg in msgArray {
                        self.dataArray?.insert(msg, at: 0)
                    }
                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
                }
            }
        })
        let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMore))
        self.navigationItem.rightBarButtonItem = more
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    @objc func onMore() {
        let aSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
        let RemoveAll = UIAlertAction(title: "清空所有通知", style: .destructive) { (a) in
            var err :EMError?
            self.conversation?.deleteAllMessages(&err)
            self.dataArray?.removeAll()
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        aSheet.addAction(RemoveAll)
        aSheet.addAction(cancel)
        aSheet.modalPresentationStyle = .overFullScreen
        self.present(aSheet, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupNotifation", for: indexPath) as! GroupNotifationTableViewCell
        if let body = dataArray![indexPath.row].body as? EMTextMessageBody {
            let json = DCEncrypt.Decode_AES(strToDecode: String(body.text.split(separator: "_")[0]))
            let data = GroupNotifationModel.deserialize(from: json)
            if data != nil && data?.group_portrait != nil {
                cell.headImageView.sd_setImage(with: URL(string: data!.group_portrait!), completed: nil)
            }
            cell.groupNameLabel.text = data?.group_name
            cell.groupMSGLabel.text = data?.msg
        }else{
            let body = dataArray![indexPath.row].body as? EMTextMessageBody
            let json = DCEncrypt.Decode_AES(strToDecode: String((body?.text.split(separator: "_")[0]) ?? ""))
            cell.groupMSGLabel.text = json
        }
        return cell
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
