//
//  DIYFaceCollectionViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 7/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DIYFaceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var faceView: UIImageView!
    @IBOutlet weak var selectView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        faceView.layer.cornerRadius = 5
        selectView.isHidden = true
    }

}
