//
//  MomentDetailViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit
import HandyJSON

class MomentDetailViewController: UIViewController {
    
    var circle_id:String?
    
    var data:MomentDetailData?
    
    var comment:[HandyJSON] = [HandyJSON]()
    
    lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 10)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.backgroundColor = UIColor.white
        collectionView.register(FCTopCell.classForCoder(), forCellWithReuseIdentifier: "Top")
        collectionView.register(MomentHeaderCell.classForCoder(), forCellWithReuseIdentifier: "Head")
        collectionView.register(MomentButtonCell.classForCoder(), forCellWithReuseIdentifier: "Botton")
        collectionView.register(MomentLikeCell.classForCoder(), forCellWithReuseIdentifier: "Like")
        collectionView.register(MomentDetailCommentCell.classForCoder(), forCellWithReuseIdentifier: "Comment")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "朋友圈详情"
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
        }
        loadData()
    }
    
    func loadData() {
        DispatchQueue.global().async {
            let m = GetMomentDetailtSendModel()
            m.circle_id = self.circle_id
            BoXinProvider.request(.GetMomentDetail(model: m), callbackQueue: .main, progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetMomentDetailReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                self.data = model.data
                                self.collectionView.reloadData()
                                if model.data?.user_id == EMClient.shared()?.currentUsername {
                                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "MomentDelete"), style: .plain, target: self, action: #selector(self.deleteMoment))
                                }
                            }else{
                                self.view.makeToast(model.message)
                            }
                        }else{
                            self.view.makeToast("数据格式错误")
                        }
                    }else{
                        self.view.makeToast("链接服务器错误")
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
    
    @objc func deleteMoment() {
        let alert = UIAlertController(title: "你确定删除这条朋友圈吗", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (a) in
            DispatchQueue.global().async {
                let m = GetMomentDetailtSendModel()
                m.circle_id = self.circle_id
                BoXinProvider.request(.DeleteMoment(model: m), callbackQueue: .main, progress: nil) { (result) in
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let model = GetMomentDetailReciveModel.deserialize(from: try? res.mapString()) {
                                if model.code == 200 {
                                    self.navigationController?.popViewController(animated: true)
                                }else{
                                    self.view.makeToast(model.message)
                                }
                            }else{
                                self.view.makeToast("数据格式错误")
                            }
                        }else{
                            self.view.makeToast("链接服务器错误")
                        }
                    case .failure(_):
                        return
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension MomentDetailViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var row = 2
        if data?.likeList?.count ?? 0 > 0 {
            row += 1
        }
        comment.removeAll()
        if let c = data?.commentsList {
            for com in c {
                if let cm = com {
                    comment.append(cm)
                    if let crml = cm.replyList {
                        for cr in crml {
                            guard let r = cr else{
                                continue
                            }
                            r.reply_name = cm.friend_name
                            comment.append(r)
                        }
                    }
                }
            }
        }
        row += comment.count
        return row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Head", for: indexPath) as! MomentHeaderCell
            cell.data = data
            cell.vc=self
            return cell
        }
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Botton", for: indexPath) as! MomentButtonCell
            cell.data = data
            cell.delegate = self
            return cell
        }
        var haslike = false
        if (data?.likeList?.count ?? 0) > 0 {
            haslike = true
        }
        if indexPath.item == 2 && haslike {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Like", for: indexPath) as! MomentLikeCell
            cell.data = data
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Comment", for: indexPath) as! MomentDetailCommentCell
        cell.model = comment[indexPath.item-(haslike ? 3 : 2)]
        cell.delegate = self
        cell.ownerID = data?.user_id
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

extension MomentDetailViewController: MomentRefreshDelegate {
    func needRefresh(momentId: String?) {
        collectionView.reloadData()
    }
    func needReload() {
        loadData()
    }
}
