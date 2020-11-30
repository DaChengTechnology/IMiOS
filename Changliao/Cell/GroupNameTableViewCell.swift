//
//  GroupNameTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

typealias HeadClick = (UIImageView) -> Void

/// 群详情头
class GroupNameTableViewCell: UITableViewCell {
    @IBOutlet weak var Workimage1: UIImageView!
    @IBOutlet weak var WrokImage: UIImageView!
    @IBOutlet weak var headImageView: MGAvatarImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jiantou: UIImageView!
    var click:HeadClick?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 5
        headImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(gesture:)))
        headImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func onHeadClick(gesture:UIGestureRecognizer){
        if gesture.state == .ended {
            click?(headImageView)
        }
    }
    
}
