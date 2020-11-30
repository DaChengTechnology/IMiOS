//
//  DCImageData.swift
//  boxin
//
//  Created by guduzhonglao on 8/4/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DCImageData: YBIBImageData {
    
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
