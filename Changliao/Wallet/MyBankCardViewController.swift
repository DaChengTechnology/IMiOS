//
//  MyBankCardViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/25/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MyBankCardViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.backgroundColor = .white
        tb.separatorStyle = .none
        return tb
    }()
    
    var data:[BankCardData?]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的银行卡"
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.right()?.bottom()?.offset()(0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    // MARK: - UITableViewDataSource,UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        btn.tintColor = .white
        btn.setTitle("添加银行卡", for: .normal)
        btn.addTarget(self, action: #selector(onAddCard), for: .touchUpInside)
        btn.layer.cornerRadius = DCUtill.SCRATIOX(22)
        v.addSubview(btn)
        btn.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(28))
            make?.right.offset()(DCUtill.SCRATIOX(-28))
            make?.top.offset()(DCUtill.SCRATIOX(40))
            make?.bottom.offset()(DCUtill.SCRATIOX(-5))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(44))
        }
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? BankCardCell else {
            let cell = BankCardCell(style: .default, reuseIdentifier: "Cell")
            cell.model = data?[indexPath.row]
            cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.hexadecimalColor(hexadecimal: "#004F9C") : UIColor.hexadecimalColor(hexadecimal: "#C42B25")
            return cell
        }
        cell.model = data?[indexPath.row]
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.hexadecimalColor(hexadecimal: "#004F9C") : UIColor.hexadecimalColor(hexadecimal: "#C42B25")
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "你确定删除该银行卡吗?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (a) in
                self.deleteCard(id: self.data?[indexPath.row]?.bank_card_id)
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // - MARK: -private
    
    @objc func onAddCard() {
        
    }
    
    func loadData() {
        DispatchQueue.global().async {
            BoXinProvider.request(.BankCardList(model: UserInfoSendModel()), callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = BankCardListReciveModel.deserialize(from: try? res.mapString()) {
                            self.data = model.data
                            self.tableView.reloadData()
                        }else{
                            self.view.makeToast("数据解析失败")
                        }
                    }else{
                        self.view.makeToast("服务器连接失败")
                    }
                case .failure(_):
                    self.view.makeToast("网络连接失败")
                }
            }
        }
    }
    
    func generateCplor() -> UIColor {
        let colors = [UIColor.hexadecimalColor(hexadecimal: "f5e855"),UIColor.hexadecimalColor(hexadecimal: "f5ab55"),UIColor.hexadecimalColor(hexadecimal: "55f5e4"),UIColor.hexadecimalColor(hexadecimal: "55bef5"),UIColor.hexadecimalColor(hexadecimal: "557bf5"),UIColor.hexadecimalColor(hexadecimal: "8a55f5"),UIColor.hexadecimalColor(hexadecimal: "d955f5"),UIColor.hexadecimalColor(hexadecimal: "f555be"),UIColor.hexadecimalColor(hexadecimal: "f58a55")]
        let idx = DCUtill.randomIntNumber(lower: 0, upper: colors.count)
        return colors[idx]
    }
    
    func deleteCard(id:String?) {
        DispatchQueue.global().async {
            let m = DeleteBankCardSendModel()
            m.bank_card_id = id
            BoXinProvider.request(.DeleteBankCard(model: m), callbackQueue: .main) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                self.loadData()
                                self.view.makeToast("删除成功")
                            }else{
                                self.view.makeToast(model.message)
                            }
                        }else{
                            self.view.makeToast("数据解析失败")
                        }
                    }else{
                        self.view.makeToast("服务器连接失败")
                    }
                case .failure(_):
                    self.view.makeToast("网络连接失败")
                }
            }
        }
    }

}
