//
//  SendMomentViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/22/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class SendMomentViewController: UIViewController {
    
    lazy var cancel:UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        btn.setTitle("取消", for: .normal)
        return btn
    }()
    
    lazy var publish:UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        btn.setTitle("发表", for: .normal)
        btn.layer.cornerRadius = DCUtill.SCRATIO(x: 8)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var titleL:UILabel = {
        let t = UILabel(frame: .zero)
        t.font = DCUtill.FONTX(18)
        t.textColor = .black
        t.textAlignment = .center
        return t
    }()
    
    lazy var textView:UITextView = {
        let t = UITextView(frame: .zero)
        t.textColor = .black
        t.backgroundColor = .clear
        t.font = DCUtill.FONTX(18)
        return t
    }()
    
    lazy var pal:UILabel = {
        let t = UILabel(frame: .zero)
        t.text = "来到畅聊写点什么吧…"
        t.textColor = UIColor.hexadecimalColor(hexadecimal: "#C1C1C1")
        return t
    }()
    
    lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: DCUtill.SCRATIOX(126), height: DCUtill.SCRATIOX(126))
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.backgroundColor = UIColor.white
        collectionView.register(SendMomentCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    var surpperPic = true
    
    var images:[UIImage] = [UIImage]()
    
    var videoUrl:String = ""
    
    var videoImage:UIImage?
    
    var onLineImage:[String] = [String]()
    
    var delegate:MomentRefreshDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        cancel.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.view.addSubview(cancel)
        cancel.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.offset()(DCUtill.SCRATIOX(16))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(80))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(48))
        }
        if surpperPic {
            titleL.text = "发表图文"
        }else{
            titleL.text = "发表文字"
        }
        self.view.addSubview(titleL)
        titleL.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(DCUtill.SCRATIOX(13))
            make?.centerX.equalTo()(self.view)
        }
        publish.addTarget(self, action: #selector(onPublish), for: .touchUpInside)
        self.view.addSubview(publish)
        publish.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(DCUtill.SCRATIOX(8))
            make?.right.offset()(DCUtill.SCRATIOX(-25))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(62))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(35))
        }
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EAEAEA")
        self.view.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.equalTo()(self.view)
            make?.top.equalTo()(publish.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
        self.view.addSubview(pal)
        pal.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(27))
            make?.top.equalTo()(line.mas_bottom)?.offset()(DCUtill.SCRATIOX(25))
        }
        textView.delegate = self
        self.view.addSubview(textView)
        textView.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(27))
            make?.top.equalTo()(line.mas_bottom)?.offset()(DCUtill.SCRATIOX(25))
            make?.right.offset()(DCUtill.SCRATIOX(-27))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(100))
        }
        if surpperPic {
            collectionView.dataSource = self
            collectionView.delegate = self
            self.view.addSubview(collectionView)
            collectionView.mas_makeConstraints { (make) in
                make?.top.equalTo()(textView.mas_bottom)
                make?.left.offset()(DCUtill.SCRATIOX(16))
                make?.right.offset()(DCUtill.SCRATIOX(-16))
                make?.height.mas_equalTo()(DCUtill.SCRATIOX(382))
            }
        }
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onPublish() {
        self.view.endEditing(true)
        if textView.text.isEmpty && images.count == 0 && videoUrl.isEmpty {
            self.view.makeToast("请输入内容")
            return
        }
        let m = SendMomentSendModel()
        m.content = textView.text
        if !videoUrl.isEmpty {
            uploadVideo {
                m.pic1 = self.onLineImage[0]
                m.pic2 = self.onLineImage[1]
                BoXinProvider.request(.SendMoment(model: m), callbackQueue: .main) { (result) in
                    SVProgressHUD.dismiss()
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                                if model.code == 200 {
                                    self.delegate?.needReload()
                                    self.onBack()
                                    UIApplication.shared.keyWindow?.makeToast("发表成功")
                                }else{
                                    self.view.makeToast(model.message)
                                }
                            }
                        }else{
                            self.view.makeToast("服务器连接失败")
                        }
                    case .failure(_):
                        self.view.makeToast("网络连接失败")
                    }
                }
            }
        }else if images.count > 0 {
            uploadImages(idx: 0) {
                if self.onLineImage.count > 0 {
                    m.pic1 = self.onLineImage[0]
                }
                if self.onLineImage.count > 1 {
                    m.pic2 = self.onLineImage[1]
                }
                if self.onLineImage.count > 2 {
                    m.pic3 = self.onLineImage[2]
                }
                if self.onLineImage.count > 3 {
                    m.pic4 = self.onLineImage[3]
                }
                if self.onLineImage.count > 4 {
                    m.pic5 = self.onLineImage[4]
                }
                if self.onLineImage.count > 5 {
                    m.pic6 = self.onLineImage[5]
                }
                if self.onLineImage.count > 6 {
                    m.pic7 = self.onLineImage[6]
                }
                if self.onLineImage.count > 7 {
                    m.pic8 = self.onLineImage[7]
                }
                if self.onLineImage.count > 8 {
                    m.pic9 = self.onLineImage[8]
                }
                BoXinProvider.request(.SendMoment(model: m), callbackQueue: .main) { (result) in
                    SVProgressHUD.dismiss()
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                                if model.code == 200 {
                                    self.delegate?.needReload()
                                    self.onBack()
                                    UIApplication.shared.keyWindow?.makeToast("发表成功")
                                }else{
                                    self.view.makeToast(model.message)
                                }
                            }
                        }else{
                            self.view.makeToast("服务器连接失败")
                        }
                    case .failure(_):
                        self.view.makeToast("网络连接失败")
                    }
                }
            }
        }else{
            BoXinProvider.request(.SendMoment(model: m), callbackQueue: .main) { (result) in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                self.delegate?.needReload()
                                self.onBack()
                                UIApplication.shared.keyWindow?.makeToast("发表成功")
                            }else{
                                self.view.makeToast(model.message)
                            }
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
    
    @objc func onDelete(btn:UIButton) {
        if btn.tag > 0 {
            images.remove(at: btn.tag - 1)
            collectionView.reloadData()
        }
    }
    
    func uploadImages(idx:Int,complite:@escaping ()->Void) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            SVProgressHUD.show()
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingData = self.images[idx].jpegData(compressionQuality: 0.8)!
            put.objectKey = String(format: "im19060501/%@.jpg", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
            let app = UIApplication.shared.delegate as! AppDelegate
            let task = app.ossClient?.putObject(put)
            let filename = String(put.objectKey.split(separator: "/")[1])
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    self.onLineImage.append(filename)
                    if self.onLineImage.count < self.images.count {
                        self.uploadImages(idx: idx + 1, complite: complite)
                    }else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        complite()
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
    
    func uploadVideo(complite:@escaping ()->Void) {
        SVProgressHUD.show()
        let put = OSSPutObjectRequest()
        put.bucketName = "hgjt-oss"
        put.uploadingFileURL = URL(string: videoUrl)!
        put.objectKey = String(format: "im19060501/%@.mp4", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        let app = UIApplication.shared.delegate as! AppDelegate
        let task = app.ossClient?.putObject(put)
        let filename = String(put.objectKey.split(separator: "/")[1])
        task?.continue({ (t) -> Any? in
            if t.error == nil {
                self.onLineImage.append(filename)
                let put1 = OSSPutObjectRequest()
                put1.bucketName = "hgjt-oss"
                put1.uploadingData = self.videoImage!.jpegData(compressionQuality: 0.8)!
                put1.objectKey = String(format: "im19060501/%@.jpg", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
                let task1 = app.ossClient?.putObject(put1)
                let filename = String(put1.objectKey.split(separator: "/")[1])
                task1?.continue({ (t) -> Any? in
                    if t.error == nil {
                        self.onLineImage.append(filename)
                        complite()
                    }else{
                        print(t.error.debugDescription)
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            UIApplication.shared.keyWindow?.makeToast("上传缩略图失败")
                        }
                    }
                    return nil
                })
            }else{
                print(t.error.debugDescription)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("上传视频失败")
                }
            }
            return nil
        })
    }

}

extension SendMomentViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !videoUrl.isEmpty {
            return 1
        }
        if images.count < 9 {
            return images.count + 1
        }
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SendMomentCell
        if !videoUrl.isEmpty {
            cell.image.image = videoImage
            cell.close.mas_remakeConstraints { (make) in
                make?.height.with()?.mas_equalTo()(DCUtill.SCRATIOX(33))
                make?.center.equalTo()(cell.image)
            }
            return cell
        }
        if indexPath.item < images.count {
            cell.resetCell()
            cell.image.image = images[indexPath.item]
            cell.close.tag = indexPath.item + 1
            cell.close.addTarget(self, action: #selector(onDelete(btn:)), for: .touchUpInside)
            return cell
        }
        cell.image.image = nil
        cell.close.setImage(UIImage(named: "addMomentPic"), for: .normal)
        cell.close.mas_remakeConstraints { (make) in
            make?.height.with()?.mas_equalTo()(DCUtill.SCRATIOX(33))
            make?.center.equalTo()(cell.image)
        }
        cell.close.tag = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !videoUrl.isEmpty {
            let data = DCVideoData()
            data.videoURL = URL(string: videoUrl)
            data.autoPlayCount = 1
            
            let browser = YBImageBrowser()
            browser.dataSourceArray = [data]
            browser.currentPage = 0
            browser.show(to: self.tabBarController!.view)
            return
        }
        if images.count > indexPath.item {
            let browser = YBImageBrowser()
            var data = [DCImageData]()
            for (idx,_) in images.enumerated() {
                let d = DCImageData()
                d.image = {
                    return self.images[browser.currentPage]
                }
                d.projectiveView = collectionView.cellForItem(at: IndexPath(item: idx, section: 0))
                data.append(d)
            }
            browser.dataSourceArray = data
            browser.currentPage = indexPath.item
            browser.show(to: self.tabBarController!.view)
        }else{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "拍摄", style: .default, handler: { (a) in
                self.takePhoto()
            }))
            alert.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { (a) in
                self.photoLibriry()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
                    m.type = self.images.count == 0 ? .photoAndVideo : .photo
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
        m.configuration.photoMaxNum = UInt(9 - images.count)
        m.configuration.videoMaxNum = images.count == 0 ? 1 : 0
        m.configuration.maxNum = UInt(9 - images.count)
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

extension SendMomentViewController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            pal.isHidden = false
        }else{
            pal.isHidden = true
        }
    }
}

extension SendMomentViewController:HXCustomCameraViewControllerDelegate {
    func customCameraViewController(_ viewController: HXCustomCameraViewController!, didDone model: HXPhotoModel!) {
        viewController.dismiss(animated: true, completion: nil)
        if model.type == .cameraPhoto {
            if let p = model.previewPhoto {
                images.append(p)
                collectionView.reloadData()
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
                        self.videoUrl = ur.absoluteString
                        self.videoImage = frameImg
                        self.collectionView.reloadData()
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

extension SendMomentViewController:HXAlbumListViewControllerDelegate {
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
                        self.videoUrl = ur.absoluteString
                        self.videoImage = frameImg
                        self.collectionView.reloadData()
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
            let imageRequestOption = PHImageRequestOptions()
            // PHImageRequestOptions是否有效
            imageRequestOption.isSynchronous = true
            // 缩略图的压缩模式设置为无
            imageRequestOption.resizeMode = .none
            imageRequestOption.deliveryMode = .highQualityFormat
            for photo in photoList {
                if let img = photo.previewPhoto {
                    self.images.append(img)
                }else{
                    photo.requestImage(with: imageRequestOption, targetSize: PHImageManagerMaximumSize) { (image, ext) in
                        if let img = image {
                            self.images.append(img)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}
