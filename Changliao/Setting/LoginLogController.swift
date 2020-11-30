//
//  LoginLogController.swift
//  boxin
//
//  Created by guduzhonglao on 10/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import MJRefresh

@objc class LoginLogController: UITableViewController {
    var dataArray:[GetLoginTraceData] = Array<GetLoginTraceData>()
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = DCUtill.SCRATIO(x: 204)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#F2F2F6")
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(onLoadFirst))
        tableView.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(onLoadMore))
        self.navigationItem.title = "登陆痕迹"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onLoadFirst()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LoginTrace") as? LginLogTableViewCell
        if cell == nil {
            cell = LginLogTableViewCell(style: .default, reuseIdentifier: "LoginTrace")
        }
        // Configure the cell...
        cell?.model = dataArray[indexPath.row]
        return cell!
    }
    
    @objc func onLoadFirst() {
        page = 1
        onLoad()
    }
    
    @objc func onLoadMore() {
        page += 1
        onLoad()
    }
    
    func onLoad() {
        DispatchQueue.global().async {
            let model = GetLoginTraceSendModel()
            model.pageIndex = self.page
            BoXinProvider.request(.GetLoginTrace(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = GetLoginTraceReciveModel.deserialize(from: try? res.mapString()) {
                            guard BoXinUtil.isTokenExpired(mo.code ?? 0) else {
                                return
                            }
                            if mo.code == 200 {
                                if self.page == 1 {
                                    self.dataArray = mo.data ?? []
                                }else{
                                    self.dataArray.append(contentsOf: mo.data ?? [])
                                }
                                if mo.data?.count ?? 0 < 10 {
                                    DispatchQueue.main.async {
                                        self.tableView.mj_header?.endRefreshing()
                                        self.tableView.mj_footer?.state = .noMoreData
                                        self.tableView.reloadData()
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        self.tableView.mj_header?.endRefreshing()
                                        self.tableView.mj_footer?.endRefreshing()
                                        self.tableView.reloadData()
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.view.makeToast(mo.message)
                                    self.tableView.mj_header?.endRefreshing()
                                    self.tableView.mj_footer?.endRefreshing()
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                self.tableView.mj_header?.endRefreshing()
                                self.tableView.mj_footer?.endRefreshing()
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            self.tableView.mj_header?.endRefreshing()
                            self.tableView.mj_footer?.endRefreshing()
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        self.tableView.mj_header?.endRefreshing()
                        self.tableView.mj_footer?.endRefreshing()
                    }
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
