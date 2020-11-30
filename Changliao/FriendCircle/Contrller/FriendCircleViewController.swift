//
//  FriendCircleViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/9/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class FriendCircleViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MomentRefreshDelegate {
    
    var data:[FriendCircleData?]?
    var page:Int = 1
    var bkUrl:String = ""
    var loadding = false
    var offset = CGPoint(x: 0, y: 0)
    
    lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.headerReferenceSize = .zero
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
        collectionView.register(MomentCommentCell.classForCoder(), forCellWithReuseIdentifier: "Comment")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "NoHeader")
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "NoFooter")
        collectionView.register(MomentFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "123")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Moments", comment: "Moments")
        let camera = UIImageView(image: UIImage(named: "camera"))
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(g:)))
        camera.addGestureRecognizer(tap)
        camera.isUserInteractionEnabled = true
        let longtap = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(g:)))
        tap.require(toFail: longtap)
        longtap.minimumPressDuration = 0.5
        camera.addGestureRecognizer(longtap)
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView: camera)
//        collectionView.register(MomentFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MFooter")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.mj_header = MomentHeaderRefreshView(refreshingTarget: self, refreshingAction: #selector(loadFirst))
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.view.addSubview(collectionView)
        collectionView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.right()?.bottom()?.offset()(0)
        }
        loadFirst()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBackground()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func onTap(g:UIGestureRecognizer) {
        if g.state == .ended {
            print("点击")
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "拍摄", style: .default, handler: { (a) in
                self.takePhoto()
            }))
            alert.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { (a) in
                self.photoLibriry()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func onLongTap(g:UIGestureRecognizer) {
        if g.state == .began {
            print("长按")
            let vc = SendMomentViewController()
            vc.surpperPic = false
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
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
            let m = GetMyFriendCircleSendModel()
            m.pageIndex = self.page
            BoXinProvider.request(.GetMyFriendCircle(model: m), callbackQueue: .main, progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetFriendCircleReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                if self.page == 1 {
                                    self.data = model.data
                                    self.collectionView.mj_header?.endRefreshing()
                                    self.collectionView.mj_footer?.endRefreshing()
                                    self.collectionView.reloadData()
                                }else{
                                    let offset = self.collectionView.contentOffset
                                    if let data = model.data {
                                        self.data?.append(contentsOf: data)
                                    }
                                    self.collectionView.mj_header?.endRefreshing()
                                    self.collectionView.mj_footer?.endRefreshing()
                                    self.collectionView.reloadData()
//                                    self.collectionView.layoutIfNeeded()
//                                    self.collectionView.contentOffset = offset
                                }
//                                if self.page > 1 {
//                                    DispatchQueue.main.async {
//                                        CATransaction.begin()
//                                        CATransaction.setDisableActions(true)
//                                        self.collectionView.reloadData()
////                                        let offset = self.collectionView.contentOffset
//                                        CATransaction.commit()
////                                        self.collectionView.setContentOffset(offset, animated: false)
//                                    }
//                                }else{
//                                    self.collectionView.reloadData()
//                                }
                                
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
            let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            let m = YhjfSendModel()
            m.target_user_id = model?.db?.user_id
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
    
    // - MARK: - UICollectionViewDataSource,UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (data?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        var row = 2
        if (data?[section - 1]?.likeList?.count ?? 0) > 0 {
            row += 1
        }
        row += data?[section - 1]?.commentsList?.count ?? 0
        return row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Top", for: indexPath) as! FCTopCell
            if !bkUrl.isEmpty {
                cell.setBK(url: bkUrl)
            }
            if let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")) {
                if let avatar = model.db?.portrait {
                    cell.setHead(url: avatar)
                }
            }
            cell.isMine = true
            cell.vc = self
            return cell
        }
        let model = data?[indexPath.section-1]
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Head", for: indexPath) as! MomentHeaderCell
            cell.model = model
            cell.vc=self
            cell.nineImageView.reloadData()
            return cell
        }
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Botton", for: indexPath) as! MomentButtonCell
            cell.model = model
            cell.delegate = self
            return cell
        }
        var haslike = false
        if (model?.likeList?.count ?? 0) > 0 {
            haslike = true
        }
        if indexPath.item == 2 && haslike {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Like", for: indexPath) as! MomentLikeCell
            cell.model = model
            cell.vc = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Comment", for: indexPath) as! MomentCommentCell
        cell.model = model?.commentsList?[indexPath.item-(haslike ? 3 : 2)]
        cell.vc = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            ZZQAvatarPicker.startSelected { (image) in
                if image != nil {
                    DispatchQueue.main.async {
                        SVProgressHUD.show()
                        let filename = UUID().uuidString.replacingOccurrences(of: "-", with: "") + ".jpg"
                        let put = OSSPutObjectRequest()
                        put.bucketName = "hgjt-oss"
                        put.uploadingData = image.jpegData(compressionQuality: 0.8)!
                        put.objectKey = String(format: "im19060501/%@", filename)
                        let app = UIApplication.shared.delegate as! AppDelegate
                        let task = app.ossClient?.putObject(put)
                        task?.continue({ (t) -> Any? in
                            if t.error == nil {
                                let m = SetMomentBKSendModel()
                                m.img = filename
                                BoXinProvider.request(.SetMomentBK(model: m), callbackQueue: .main, progress: nil) { (result) in
                                    switch result {
                                    case .success(let res):
                                        if res.statusCode == 200 {
                                            if let model = SendSMSReciveModel.deserialize(from: try? res.mapString()) {
                                                if model.code == 200 {
                                                    self.bkUrl = model.data ?? ""
                                                    self.collectionView.reloadData()
                                                    SVProgressHUD.dismiss()
                                                }else{
                                                    self.view.makeToast(model.message)
                                                    SVProgressHUD.dismiss()
                                                }
                                            }else{
                                                self.view.makeToast("数据解析失败")
                                                SVProgressHUD.dismiss()
                                            }
                                        }else{
                                            self.view.makeToast("服务器链接失败")
                                            SVProgressHUD.dismiss()
                                        }
                                    case .failure(_):
                                        self.view.makeToast("网络连接失败")
                                        SVProgressHUD.dismiss()
                                    }
                                }
                            }else{
                                print(t.error.debugDescription)
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("上传图片失败")
                                }
                            }
                            return nil
                        })
                    }
                }
            }
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NoHeader", for: indexPath)
        }
        if indexPath.section == 0 {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NoFooter", for: indexPath)
        }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "123", for: indexPath) as! MomentFooterView
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        }
        return CGSize(width: collectionView.bounds.width, height: DCUtill.SCRATIOX(16))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return FCTopCell.cellForSize()
        }
         let model = data?[indexPath.section-1]
        if indexPath.item == 0 {
            return MomentHeaderCell.cellForSize(model)
        }
        if indexPath.item == 1 {
            return MomentButtonCell.cellForSize()
        }
        var haslike = false
        if (model?.likeList?.count ?? 0) > 0 {
            haslike = true
        }
        if haslike && indexPath.item == 2 {
            return MomentLikeCell.cellForSize(m: model)
        }
        return MomentCommentCell.cellForSize(m: model?.commentsList?[indexPath.item-(haslike ? 3 : 2)])
    }
    
    func needRefresh(momentId: String?) {
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
    
    func needReload() {
        loadFirst()
    }
    
    
    func takePhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.view.makeToast("无法使用相机")
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    let m = HXPhotoManager()
                    m.type = .photoAndVideo
                    m.configuration.videoMaximumDuration = 10
                    m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
                    m.configuration.sessionPreset = "AVCaptureSessionPreset1280x720"
                    let vc = HXCustomCameraViewController()
                    vc.manager = m
                    vc.delegate = self
                    vc.isOutside = true
                    let nav = HXCustomNavigationController(rootViewController: vc)
                    nav.isCamera = true
                    nav.supportRotation = false
                    nav.modalPresentationStyle = .overFullScreen
                    self.present(nav, animated: true, completion: nil)
                }else{
                    self.view.makeToast("无法使用相机")
                }
            }
        }
    }
    
    func photoLibriry() {
        let vc = HXAlbumListViewController()
        let m = HXPhotoManager()
        m.configuration.cameraCellShowPreview = false
        m.configuration.downloadICloudAsset = true
        m.configuration.openCamera = false
        m.configuration.lookGifPhoto = false
        m.configuration.lookLivePhoto = false
        m.type = .photoAndVideo
        m.configuration.saveSystemAblum = false
        m.configuration.supportRotation = false
        m.configuration.photoMaxNum = 9
        m.configuration.videoMaxNum = 1
        m.configuration.maxNum = 9
        m.configuration.hideOriginalBtn = false
        m.configuration.photoCanEdit = false
        m.configuration.videoCanEdit = false
        m.configuration.specialModeNeedHideVideoSelectBtn = true
        m.configuration.navBarBackgroudColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
        m.configuration.navigationTitleColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.videoMaximumSelectDuration = 300
        m.configuration.showDateSectionHeader = false
        vc.manager = m
        vc.delegate = self
        let nav = HXCustomNavigationController(rootViewController: vc)
        nav.supportRotation = false
        nav.navigationBar.tintColor = UIColor.white
        nav.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController()?.present(nav, animated: true, completion: nil)
    }

}

extension FriendCircleViewController:HXCustomCameraViewControllerDelegate {
    func customCameraViewController(_ viewController: HXCustomCameraViewController!, didDone model: HXPhotoModel!) {
        viewController.dismiss(animated: true, completion: nil)
        if model.type == .cameraPhoto {
            if let p = model.previewPhoto {
                let vc = SendMomentViewController()
                vc.images.append(p)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
                return
            }
        }
        if model.type == .cameraVideo {
            SVProgressHUD.showProgress(0)
            model.exportVideo(withPresetName: AVAssetExportPreset640x480, startRequestICloud: nil, iCloudProgressHandler: nil, exportProgressHandler: { (p, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(p)
                }
            }, success: { (url, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if let ur = url {
                        let avAsset = AVAsset(url: ur)
                         
                        //生成视频截图
                        let generator = AVAssetImageGenerator(asset: avAsset)
                        generator.appliesPreferredTrackTransform = true
                        let time = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600)
                        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
                        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
                        let frameImg = UIImage(cgImage: imageRef)
                        let vc = SendMomentViewController()
                        vc.videoUrl = ur.absoluteString
                        vc.videoImage = frameImg
                        vc.delegate = self
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        UIApplication.shared.keyWindow?.makeToast("获取缩略图失败");
                    }
                }
                
            }) { (ext, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("获取视频失败");
                }
            }
        }
    }
}

extension FriendCircleViewController:HXAlbumListViewControllerDelegate {
    func albumListViewController(_ albumListViewController: HXAlbumListViewController!, didDoneAllList allList: [HXPhotoModel]!, photos photoList: [HXPhotoModel]!, videos videoList: [HXPhotoModel]!, original: Bool) {
        albumListViewController.dismiss(animated: true, completion: nil)
        if videoList.count > 0 {
            SVProgressHUD.showProgress(0)
            videoList[0].exportVideo(withPresetName: AVAssetExportPreset640x480, startRequestICloud: nil, iCloudProgressHandler: nil, exportProgressHandler: { (p, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(p)
                }
            }, success: { (url, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if let ur = url {
                        let avAsset = AVAsset(url: ur)
                         
                        //生成视频截图
                        let generator = AVAssetImageGenerator(asset: avAsset)
                        generator.appliesPreferredTrackTransform = true
                        let time = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600)
                        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
                        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
                        let frameImg = UIImage(cgImage: imageRef)
                        let vc = SendMomentViewController()
                        vc.videoUrl = ur.absoluteString
                        vc.videoImage = frameImg
                        vc.delegate = self
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        UIApplication.shared.keyWindow?.makeToast("获取缩略图失败");
                    }
                }
                
            }) { (ext, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("获取视频失败");
                }
            }
        }else if photoList.count > 0 {
            let vc = SendMomentViewController()
            let imageRequestOption = PHImageRequestOptions()
            // PHImageRequestOptions是否有效
            imageRequestOption.isSynchronous = true
            // 缩略图的压缩模式设置为无
            imageRequestOption.resizeMode = .none
            imageRequestOption.deliveryMode = .highQualityFormat
            for photo in photoList {
                if let img = photo.previewPhoto {
                    vc.images.append(img)
                }else if let img = photo.thumbPhoto {
                    vc.images.append(img)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension FriendCircleViewController:UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
