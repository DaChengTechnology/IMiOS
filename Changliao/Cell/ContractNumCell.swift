//
//  ContractNumCell.swift
//  boxin
//
//  Created by guduzhonglao on 9/21/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class ContractNumCell: UITableViewCell {
    
    var Number:Int {
        didSet {
            CountLabel.text = "共有\(self.Number)位联系人"
        }
    }
    private let CountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        Number = 0
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        Number = 0
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        self.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.contentView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.selectionStyle = .none
        CountLabel.font = DCUtill.FONT(x: 15)
        CountLabel.textColor = UIColor.black
        CountLabel.textAlignment = .center
        self.contentView.addSubview(CountLabel)
        CountLabel.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self.contentView)
            make?.centerY.equalTo()(self.contentView)
        }
    }

}
