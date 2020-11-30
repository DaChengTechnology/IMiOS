//
//  NineImageView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/9/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

/// 九宫格展示控件
class NineImageView: UICollectionView {
    /// 图片视频url
    var images = [String]() {
        didSet {
            reloadData()
        }
    }
    /// 弱引用控制器
    weak var vc:UIViewController?
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = DCUtill.SCRATIOX(5)
        layout.minimumLineSpacing = DCUtill.SCRATIOX(5)
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        self.bounces = false
        register(NineImageViewCell.self, forCellWithReuseIdentifier: "NineImageViewCell")
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
extension NineImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.count > 0 {
            if images[0].hasSuffix(".mp4") {
                return 1
            }
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NineImageViewCell", for: indexPath) as! NineImageViewCell
        if images[0].hasSuffix(".mp4") {
            for v in cell.imageIV.subviews {
                v.removeFromSuperview()
            }
            let play = UIImageView(image: UIImage(named: "playVedio"))
            cell.imageIV.addSubview(play)
            play.mas_makeConstraints { (make) in
                make?.width.height()?.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                make?.center.equalTo()(cell.imageIV)
            }
            cell.imageIV.sd_setImage(with: URL(string: images[1]), completed: nil)
            return cell
        }else{
            for v in cell.imageIV.subviews {
                v.removeFromSuperview()
            }
            cell.imageIV.sd_setImage(with: URL(string: images[indexPath.item]), completed: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 不能动态设置size
        if images.count == 1 {
            return CGSize(width: DCUtill.SCRATIOX(200), height: DCUtill.SCRATIOX(200))
        }
        if images.count == 2 {
            if images[0].hasSuffix(".mp4") {
                return CGSize(width: DCUtill.SCRATIOX(272), height: DCUtill.SCRATIOX(272))
            }else{
                return CGSize(width: DCUtill.SCRATIOX(100), height: DCUtill.SCRATIOX(100))
            }
        }
        if images.count == 4 {
            return CGSize(width: DCUtill.SCRATIOX(100), height: DCUtill.SCRATIOX(100))
        }
        return CGSize(width: DCUtill.SCRATIOX(88), height: DCUtill.SCRATIOX(88))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc1 = self.vc else {return}
        if images.count == 2 && images[0].hasSuffix(".mp4") {
            let data = DCVideoData()
            data.videoURL = URL(string: images[0])
            let browser = YBImageBrowser()
            browser.dataSourceArray = [data]
            browser.currentPage = 0
            browser.show(to: vc1.navigationController!.view)
        }else{
            let data = images.map { (url) -> DCImageData in
                let img = DCImageData()
                img.imageURL = URL(string: url)
                return img
            }
            let browser = YBImageBrowser()
            browser.dataSourceArray = data
            browser.currentPage = indexPath.item
            browser.show(to: vc1.navigationController!.view)
        }
    }
}

/// 九宫格图片展示cell
class NineImageViewCell: UICollectionViewCell {
    /// 图片控件
    lazy var imageIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.autoresizesSubviews = true
        iv.clearsContextBeforeDrawing = true
        iv.layer.cornerRadius = DCUtill.SCRATIOX(18)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageIV)
        imageIV.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(imageIV)
        imageIV.frame = bounds
    }
}
