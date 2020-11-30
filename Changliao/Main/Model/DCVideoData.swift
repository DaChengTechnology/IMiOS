//
//  DCVideoData.swift
//  boxin
//
//  Created by guduzhonglao on 8/4/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Photos

class DCVideoData: YBIBVideoData {
    
    override func yb_saveToPhotoAlbum() {
        let state = PHPhotoLibrary.authorizationStatus()
        if state == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (s) in
                if s == .authorized {
                    super.yb_saveToPhotoAlbum()
                }
            }
        }else{
            super.yb_saveToPhotoAlbum()
        }
    }

}
