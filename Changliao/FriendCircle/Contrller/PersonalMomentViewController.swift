//
//  PersonalMomentViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/23/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class PersonalMomentViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 10)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.headerReferenceSize = CGSize.zero
        flow.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: DCUtill.SCRATIOX(60))
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.backgroundColor = UIColor.white
        collectionView.register(FCTopCell.classForCoder(), forCellWithReuseIdentifier: "Top")
        collectionView.register(MomentHistoryCell.classForCoder(), forCellWithReuseIdentifier: "History")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "noHeader")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "noFooter")
        collectionView.register(MomentFooterYearView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "YearFooter")
        return collectionView
    }()
    
    var userid:String? = EMClient.shared()?.currentUsername
    var page:Int = 1
    var bkUrl:String = ""
    var data:[[MomentData?]]?
    var headURL:String?
    var loadding = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TA的朋友圈"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.mj_header = MomentHeaderRefreshView(refreshingTarget: self, refreshingAction: #selector(loadFirst))
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.view.addSubview(collectionView)
        collectionView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.right()?.bottom()?.offset()(0)
        }
        getBackground()
        loadFirst()
    }
    
    @objc func loadFirst() {
        if loadding {
            return
        }
        loadding = true
        page = 1
        loadData()
    }
    
    @objc func loadMore() {
        if loadding {
            return
        }
        loadding = true
        page += 1
        loadData()
    }
    
    func loadData() {
        DispatchQueue.global().async {
            let m = GetMomentByUserIdSendModel()
            m.target_user_id = self.userid
            m.pageIndex = self.page
            BoXinProvider.request(.GetMomentByUserId(model: m), callbackQueue: .main, progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetMomentByUserIdReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                if self.page == 1 {
                                    self.data = [[MomentData?]]()
                                    var lastYear = 0
                                    var index = 0
                                    if let mo = model.data {
                                        for m in mo {
                                            let date = Date(timeIntervalSince1970: (m?.create_time ?? 0)/1000)
                                            let calendar = Calendar.current
                                            let components = calendar.dateComponents(Set(arrayLiteral: .year), from: date)
                                            if lastYear != components.year {
                                                lastYear = components.year ?? 0
                                                self.data?.append([MomentData?]())
                                                index = (self.data?.count ?? 1) - 1
                                            }
                                            self.data?[index].append(m)
                                        }
                                    }
                                }else{
                                    if let data = model.data {
                                        if data.count == 0 {
                                           self.collectionView.reloadData()
                                            self.collectionView.mj_header?.endRefreshing()
                                            self.collectionView.mj_footer?.endRefreshing()
                                            return
                                        }
                                        let date = Date(timeIntervalSince1970: (data[0]?.create_time ?? 0)/1000)
                                        let calendar = Calendar.current
                                        let components = calendar.dateComponents(Set(arrayLiteral: .year), from: date)
                                        var lastYear = components.year ?? 0
                                        var index = (self.data?.count ?? 1) - 1
                                        if let mo = model.data {
                                            for m in mo {
                                                let date = Date(timeIntervalSince1970: (m?.create_time ?? 0)/1000)
                                                let calendar = Calendar.current
                                                let components = calendar.dateComponents(Set(arrayLiteral: .year), from: date)
                                                if lastYear != components.year {
                                                    lastYear = components.year ?? 0
                                                    self.data?.append([MomentData?]())
                                                    index = (self.data?.count ?? 1) - 1
                                                }
                                                self.data?[index].append(m)
                                            }
                                        }
                                    }
                                }
                                if self.page > 1 {
                                    DispatchQueue.main.async {
                                        let offset = self.collectionView.contentOffset
                                        CATransaction.begin()
                                        CATransaction.setDisableActions(true)
                                        self.collectionView.reloadData()
                                        CATransaction.commit()
                                        self.collectionView.contentOffset = offset
                                        self.collectionView.setContentOffset(offset, animated: false)
                                    }
                                }else{
                                    self.collectionView.reloadData()
                                }
                                self.collectionView.mj_header?.endRefreshing()
                                self.collectionView.mj_footer?.endRefreshing()
                                self.loadding = false
                            }else{
                                self.view.makeToast(model.message)
                                self.collectionView.mj_header?.endRefreshing()
                                self.collectionView.mj_footer?.endRefreshing()
                                self.loadding = false
                            }
                        }else{
                            self.view.makeToast("数据解析失败")
                            self.collectionView.mj_header?.endRefreshing()
                            self.collectionView.mj_footer?.endRefreshing()
                            self.loadding = false
                        }
                    }else{
                        self.view.makeToast("服务器链接失败")
                        self.collectionView.mj_header?.endRefreshing()
                        self.collectionView.mj_footer?.endRefreshing()
                        self.loadding = false
                    }
                case .failure(_):
                    self.view.makeToast("网络连接失败")
                    self.collectionView.mj_header?.endRefreshing()
                    self.collectionView.mj_footer?.endRefreshing()
                    self.loadding = false
                }
            }
        }
    }
    
    func getBackground() {
        DispatchQueue.global().async {
            let m = YhjfSendModel()
            m.target_user_id = self.userid
            BoXinProvider.request(.GetMomentBK(model: m), callbackQueue: .main, progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let mo = SendSMSReciveModel.deserialize(from: try? res.mapString()) {
                            self.bkUrl = mo.data ?? ""
                            DispatchQueue.main.async {
                                let offset = self.collectionView.contentOffset
                                CATransaction.begin()
                                CATransaction.setDisableActions(true)
                                self.collectionView.reloadData()
                                CATransaction.commit()
                                self.collectionView.contentOffset = offset
                                self.collectionView.setContentOffset(offset, animated: false)
                            }
                        }
                    }else{
                        self.view.makeToast("服务器链接失败")
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
    

}

extension PersonalMomentViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (data?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return data?[section - 1].count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Top", for: indexPath) as! FCTopCell
            if !bkUrl.isEmpty {
                cell.setBK(url: bkUrl)
            }
            cell.setHead(url: headURL ?? "")
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "History", for: indexPath) as! MomentHistoryCell
        cell.model = self.data?[indexPath.section-1][indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let vc = MomentDetailViewController()
            vc.circle_id = self.data?[indexPath.section-1][indexPath.item]?.circle_id
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "noHeader", for: indexPath)
            header.isHidden = true
            return header
        }
        if indexPath.section == 0 {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "YearFooter", for: indexPath) as! MomentFooterYearView
            footer.frame = .zero
            return footer
        }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "YearFooter", for: indexPath) as! MomentFooterYearView
        let date = Date(timeIntervalSince1970: (data?[indexPath.section-1][0]?.create_time ?? 0)/1000)
        let calendar = Calendar.current
        let components = calendar.dateComponents(Set(arrayLiteral: .year), from: date)
        if let year = components.year {
            footer.year.text = "\(year - 1)年"
        }else{
            footer.isHidden = true
        }
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        }
      return CGSize(width: collectionView.frame.width, height: DCUtill.SCRATIOX(60))
    }
}
