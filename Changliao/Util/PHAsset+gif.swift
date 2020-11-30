//
//  PHAsset+gif.swift
//  boxin
//
//  Created by guduzhonglao on 7/27/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation

extension PHAsset {
    var isGIF: Bool {
        let resource = PHAssetResource.assetResources(for: self).first!
        
        // 通过统一类型标识符(uniform type identifier) UTI 来判断
        let uti = resource.uniformTypeIdentifier as CFString
        return UTTypeConformsTo(uti, kUTTypeGIF)
    }
}
