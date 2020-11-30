//
//  ChatTableView.swift
//  boxin
//
//  Created by guduzhonglao on 8/25/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class ChatTableView: UITableView,UIGestureRecognizerDelegate {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer {
            if touch.view is UITextView {
                return false
            }
            if touch.view is ChatHeadView {
                return false
            }
        }
        return true
    }
}
