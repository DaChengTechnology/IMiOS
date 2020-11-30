//
//  DIYFaceViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import SDWebImage
import Masonry

@objc class DIYFaceViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,HXAlbumListViewControllerDelegate {

    var collectionView:UICollectionView?
    var faceList:[FaceViewModel]?
    var isEdit:Bool = false
    var selectIndex:[Int]?
    var editBar:UIView?
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/4 - 2, height: UIScreen.main.bounds.width/4 - 2)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 4, height: 4), collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(UINib(nibName: "DIYFaceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DIYFace")
        collectionView?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        faceList = QueryFriend.shared.GetAllFace()
        self.view.addSubview(collectionView!)
        collectionView?.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        }
        collectionView?.reloadData()
        title = "管理表情"
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEdit {
            return (faceList?.count ?? 0)
        }
        return (faceList?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DIYFace", for: indexPath) as! DIYFaceCollectionViewCell
        if isEdit {
            cell.faceView.sd_setImage(with: URL(string: faceList![indexPath.item].url!))
            cell.selectView.isHidden = false
            if selectIndex != nil {
                var noselect = true
                for a in selectIndex! {
                    if a == indexPath.item {
                        noselect = false
                        cell.selectView.image = UIImage(named: "对号")
                        cell.faceView.layer.shadowOpacity = 0.37
                        cell.faceView.layer.shadowRadius = 5
                        cell.faceView.layer.shadowColor = UIColor.black.cgColor
                        cell.faceView.layer.shadowOffset = CGSize(width: 0, height: 0.02)
                    }
                }
                if noselect {
                    cell.selectView.image = UIImage(named: "椭圆2")
                    cell.faceView.layer.shadowOpacity = 0
                }
            }else{
                cell.selectView.image = UIImage(named: "椭圆2")
                cell.faceView.layer.shadowOpacity = 0
            }
        }else{
            if indexPath.item == 0 {
                cell.faceView.image = UIImage(named: "添加Face")
                cell.faceView.layer.shadowOpacity = 0
                cell.selectView.isHidden = true
            }else{
                cell.faceView.sd_setImage(with: URL(string: faceList![indexPath.item - 1].url!))
                cell.selectView.isHidden = true
                cell.faceView.layer.shadowOpacity = 0
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEdit {
            let cell = collectionView.cellForItem(at: indexPath) as! DIYFaceCollectionViewCell
            if selectIndex == nil {
                selectIndex = Array<Int>()
                selectIndex?.append(indexPath.item)
                cell.selectView.image = UIImage(named: "对号")
                cell.faceView.layer.shadowOpacity = 0.37
                cell.faceView.layer.shadowRadius = 5
                cell.faceView.layer.shadowColor = UIColor.black.cgColor
                cell.faceView.layer.shadowOffset = CGSize(width: 0, height: 0.02)
            }else{
                var noselect = true
                var i:Int = 0
                for a in selectIndex! {
                    if a == indexPath.item {
                        noselect = false
                        selectIndex?.remove(at: i)
                        cell.selectView.image = UIImage(named: "椭圆2")
                        cell.faceView.layer.shadowOpacity = 0
                        break
                    }
                    i += 1
                }
                if noselect {
                    selectIndex?.append(indexPath.item)
                    cell.selectView.image = UIImage(named: "对号")
                    cell.faceView.layer.shadowOpacity = 0.37
                    cell.faceView.layer.shadowRadius = 5
                    cell.faceView.layer.shadowColor = UIColor.black.cgColor
                    cell.faceView.layer.shadowOffset = CGSize(width: 0, height: 0.02)
                }
            }
        }else{
            if indexPath.item == 0 {
                goPhotoLibry()
                return
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        if isEdit {
            let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
        }else{
            let complite = UIBarButtonItem(title: "整理", style: .plain, target: self, action: #selector(onEdit))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
        }
    }
    
    func goPhotoLibry() {
        let vc = HXAlbumListViewController()
        let m = HXPhotoManager()
        m.configuration.cameraCellShowPreview = false
        m.configuration.downloadICloudAsset = true
        m.configuration.openCamera = false
        m.configuration.lookGifPhoto = true
        m.configuration.lookLivePhoto = false
        m.type = .photo
        m.configuration.saveSystemAblum = false
        m.configuration.supportRotation = false
        m.configuration.photoMaxNum = 1
        m.configuration.videoMaxNum = 0
        m.configuration.maxNum = 1
        m.configuration.hideOriginalBtn = true
        m.configuration.photoCanEdit = false
        m.configuration.specialModeNeedHideVideoSelectBtn = false
        m.configuration.navBarBackgroudColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
        m.configuration.navigationTitleColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.showDateSectionHeader = false
        vc.manager = m
        vc.delegate = self
        let nav = HXCustomNavigationController(rootViewController: vc)
        nav.supportRotation = false
        nav.navigationBar.tintColor = UIColor.white
        nav.modalPresentationStyle = .fullScreen
        UIViewController.currentViewController()?.present(nav, animated: true, completion: nil)
    }
    
    func albumListViewController(_ albumListViewController: HXAlbumListViewController!, didDoneAllList allList: [HXPhotoModel]!, photos photoList: [HXPhotoModel]!, videos videoList: [HXPhotoModel]!, original: Bool) {
        albumListViewController.dismiss(animated: true) {
            SVProgressHUD.show()
        }
        for photo in photoList {
            if let asset = photo.asset {
                if asset.isGIF {
                    addGifPicture(asset: asset)
                }else{
                    if let p = photo.previewPhoto {
                        addNormalPictrue(image: p)
                    }else{
                        let imageRequestOption = PHImageRequestOptions()
                        // PHImageRequestOptions是否有效
                        imageRequestOption.isSynchronous = true
                        // 缩略图的压缩模式设置为无
                        imageRequestOption.resizeMode = .none
                        // 缩略图的质量为高质量，不管加载时间花多少
                        imageRequestOption.deliveryMode = .highQualityFormat
                        PHImageManager.default().requestImage(for: asset, targetSize: photo.previewViewSize, contentMode: .default, options: imageRequestOption) { (image, dic) in
                            if let img = image {
                                self.addNormalPictrue(image: img)
                            }else{
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("获取图片失败")
                                }
                            }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("获取图片失败")
                }
            }
        }
    }
    
    func addGifPicture(asset:PHAsset) {
        SVProgressHUD.show()
        let imageRequestOption = PHImageRequestOptions()
        // PHImageRequestOptions是否有效
        imageRequestOption.isSynchronous = true
        // 缩略图的压缩模式设置为无
        imageRequestOption.resizeMode = .none
        // 缩略图的质量为高质量，不管加载时间花多少
        imageRequestOption.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImageData(for: asset, options: imageRequestOption) { (gifdata, name, orientation, info) in
            if let image = UIImage(data: gifdata!) {
                let put = OSSPutObjectRequest()
                put.bucketName = "hgjt-oss"
                put.uploadingData = gifdata!
                let fileName = String(format: "%@.gif", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
                put.objectKey = String(format: "im19060501/%@",fileName)
                let app = UIApplication.shared.delegate as! AppDelegate
                let task = app.ossClient?.putObject(put)
                task?.continue({ (t) -> Any? in
                    if t.error == nil {
                        self.addFace(filename: fileName, size: image.size)
                    }else{
                        print(t.error.debugDescription)
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                        }
                    }
                    return nil
                })
            }else{
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast("读取文件失败")
                }
            }
        }
    }
    
    func addNormalPictrue(image:UIImage) {
        SVProgressHUD.show()
        let put = OSSPutObjectRequest()
        put.bucketName = "hgjt-oss"
        put.uploadingData = image.jpegData(compressionQuality: 1)!
        let fileName = String(format: "%@.jpeg", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        put.objectKey = String(format: "im19060501/%@",fileName)
        let app = UIApplication.shared.delegate as! AppDelegate
        let task = app.ossClient?.putObject(put)
        task?.continue({ (t) -> Any? in
            if t.error == nil {
                SDImageCache.shared.store(image, forKey: String(format: "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/%@", fileName), completion: nil)
                self.addFace(filename: fileName, size: image.size)
            }else{
                print(t.error.debugDescription)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                }
            }
            return nil
        })
    }
    
    func addFace(filename:String,size:CGSize) {
        if isLoading {
            return
        }
        self.isLoading = true
        let model = SaveImageForFace()
        model.phiz_name = filename
        model.width = String(format: "%.0f", size.width)
        model.high = String(format: "%.0f", size.height)
        BoXinProvider.request(.SaveImageForFace(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = AddFaceReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                let m = FaceViewModel()
                                m.id = model.data?.phiz_id
                                m.url = model.data?.phiz_url
                                m.path = SDImageCache.shared.cachePath(forKey: String(format: "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/%@", filename))
                                QueryFriend.shared.AddFace(id: model.data!.phiz_id!)
                                QueryFriend.shared.updateFace(model: m)
                                BoXinUtil.GetAllFace(Complite: { (b) in
                                    if b {
                                        self.faceList?.insert(m, at: 0)
                                        DispatchQueue.main.async {
                                            self.collectionView?.reloadData()
                                            SVProgressHUD.dismiss()
                                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("AddSuccessed", comment: "Add successed"))
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            self.collectionView?.reloadData()
                                            SVProgressHUD.dismiss()
                                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("AddFalied", comment: "Add falied"))
                                        }
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
    }
    
    @objc func onEdit() {
        let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
        editBar = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        editBar?.backgroundColor = UIColor.white
        self.view.addSubview(editBar!)
        editBar?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_bottom)
            make?.height.mas_equalTo()(UIScreen.main.bounds.height >= 812 ? 97:63)
        })
        let delete = UIButton(type: .custom)
        delete.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "f15630")
        delete.setTitleColor(UIColor.white, for: .normal)
        delete.setTitleColor(UIColor.white, for: .selected)
        delete.setTitleColor(UIColor.white, for: .highlighted)
        delete.setTitleColor(UIColor.white, for: .disabled)
        delete.setTitle("删除", for: .normal)
        delete.setTitle("删除", for: .selected)
        delete.setTitle("删除", for: .highlighted)
        delete.setTitle("删除", for: .disabled)
        delete.layer.cornerRadius = 21.5
        delete.layer.shadowOpacity = 0.37
        delete.layer.shadowRadius = 5
        delete.layer.shadowColor = UIColor.black.cgColor
        delete.layer.shadowOffset = CGSize(width: 0, height: 0.02)
        delete.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
        editBar?.addSubview(delete)
        delete.mas_makeConstraints { (make) in
            make?.top.equalTo()(editBar?.mas_top)?.offset()(9)
            make?.centerX.equalTo()(editBar?.mas_centerX)
            make?.height.mas_equalTo()(43)
            make?.width.mas_equalTo()(200)
        }
        collectionView?.mas_remakeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(delete.mas_top)
        })
        isEdit = true
        collectionView?.reloadData()
    }
    
    @objc func onComplite() {
        if selectIndex == nil {
            isEdit = false
            editBar?.removeFromSuperview()
            editBar = nil
            collectionView?.mas_remakeConstraints({ (make) in
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
            })
            let complite = UIBarButtonItem(title: "整理", style: .plain, target: self, action: #selector(onEdit))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
            collectionView?.reloadData()
        }else{
            let alert = UIAlertController(title: nil, message: "你确定要放弃删除吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
                self.selectIndex = nil
                self.isEdit = false
                self.editBar?.removeFromSuperview()
                self.editBar = nil
                self.collectionView?.mas_remakeConstraints({ (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                    make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
                })
                let complite = UIBarButtonItem(title: "整理", style: .plain, target: self, action: #selector(self.onEdit))
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
                self.collectionView?.reloadData()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func onDelete(){
        if faceList == nil {
            return
        }
        if selectIndex == nil {
            let alert = UIAlertController(title: nil, message: "请选择要删除的表情", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            alert.modalPresentationStyle = .fullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if selectIndex!.count == 0 {
            let alert = UIAlertController(title: nil, message: "请选择要删除的表情", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            alert.modalPresentationStyle = .fullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = DeleteMutibleFaceSendModel()
        model.phiz_ids = faceList![selectIndex![0]].id
        if selectIndex!.count > 1 {
            for i in 1 ..< selectIndex!.count {
                model.phiz_ids! += ",\(faceList![selectIndex![i]].id!)"
            }
        }
        BoXinProvider.request(.DeleteMutibleFace(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                
                                for m in self.selectIndex! {
                                    QueryFriend.shared.deleteFace(id: self.faceList![m].id!)
                                }
                                self.selectIndex = self.selectIndex!.sorted(by: { (a, b) -> Bool in
                                    return a > b
                                })
                                for m in self.selectIndex! {
                                    self.faceList?.remove(at: m)
                                }
                                self.selectIndex = nil
                                DispatchQueue.main.async {
                                    self.isEdit = false
                                    self.editBar?.removeFromSuperview()
                                    self.editBar = nil
                                    self.collectionView?.mas_remakeConstraints({ (make) in
                                        make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                                        make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
                                        make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                                        make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
                                    })
                                    let complite = UIBarButtonItem(title: "整理", style: .plain, target: self, action: #selector(self.onEdit))
                                    self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
                                    self.collectionView?.reloadData()
                                }
                                NotificationCenter.default.post(Notification(name: Notification.Name("onEmojiChanged")))
                                self.isLoading = false
                                SVProgressHUD.dismiss()
                            }else{
                                if model.message == "请重新登录" {
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
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === collectionView {
            if let index = collectionView?.indexPathsForVisibleItems {
                collectionView?.reloadItems(at: index)
            }
        }
    }

}
