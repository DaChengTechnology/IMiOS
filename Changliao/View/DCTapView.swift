//
//  DCTapView.swift
//  boxin
//
//  Created by guduzhonglao on 8/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DCTapView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var selectList:[Selector]?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(forName: UIMenuController.didHideMenuNotification, object: nil, queue: nil) { (n) in
            UIMenuController.shared.menuItems = nil
        }
        backgroundColor = UIColor.clear
        isEditable = false
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var canBecomeFirstResponder: Bool{
        return  true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let list = selectList {
            for s in list {
                if action == s {
                    return true
                }
            }
        }
        if action == #selector(copy(_:)) {
            return true
        }
        if action == #selector(selectAll(_:)) {
            if self.selectedRange.length != self.text.count {
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
