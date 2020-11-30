//
//  DiscoveryController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 2/19/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class DiscoveryController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight=DCUtill.SCRATIOX(58)
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EEEDF0")
        tableView.backgroundView?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EEEDF0")
        self.tableView.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#EEEDF0")
        tableView.sectionFooterHeight = 0
        self.tableView.bounces=false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Discovery", comment: "Discovery")
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem=nil
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem=nil
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? DiscoveryCell else {
            let cell = DiscoveryCell(style: .default, reuseIdentifier: "Cell")
            cell.titleLabel.text = NSLocalizedString("Moments", comment: "Moments")
            return cell
        }
        cell.titleLabel.text = NSLocalizedString("Moments", comment: "Moments")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(FriendCircleViewController(), animated: true)
        }
    }

}
