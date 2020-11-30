//
//  BoxinInputView.swift
//  boxin
//
//  Created by guduzhonglao on 6/13/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class BoxinInputView: UIView,UITextViewDelegate {
    
    var model:EMConversation?
    var stylyBtn:UIButton?
    var inputTextFeild:EaseTextView?
    var faceBtn:UIButton?
    var moreBtn:UIButton?
    var voiseBtn:UIButton?
    var delegate:EMChatToolbarDelegate?

    init(model:EMConversation) {
        self.model = model
        super.init(frame: CGRect(x: 0, y: Int(UIScreen.main.bounds.height-58), width: Int(UIScreen.main.bounds.width), height: 58))
        if model.type == EMConversationTypeChat {
            stylyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            stylyBtn?.setImage(UIImage(named: "录音说话声音"), for: .normal)
            stylyBtn?.setImage(UIImage(named: "键盘"), for: .highlighted)
            stylyBtn?.setImage(UIImage(named: "录音说话声音"), for: .selected)
            stylyBtn?.setImage(UIImage(named: "录音说话声音"), for: .disabled)
            stylyBtn?.addTarget(self, action: #selector(onVoice), for: .touchUpInside)
            self.addSubview(stylyBtn!)
            stylyBtn?.mas_makeConstraints({ (make) in
                make?.top.equalTo()(self.mas_top)?.offset()(9)
                make?.left.equalTo()(self.mas_left)?.offset()(16)
                make?.bottom.equalTo()(self.mas_bottom)?.offset()(-9)
                make?.width.mas_equalTo()(40)
            })
        }
        inputTextFeild = EaseTextView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        inputTextFeild?.layer.masksToBounds = true
        inputTextFeild?.layer.cornerRadius = 5
        inputTextFeild?.layer.borderWidth = 1
        inputTextFeild?.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "bbbaba").cgColor
        inputTextFeild?.placeHolder = "请输入..."
        inputTextFeild?.delegate = self
        self.addSubview(inputTextFeild!)
        faceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        faceBtn?.setImage(UIImage(named: "笑脸"), for: .normal)
        faceBtn?.setImage(UIImage(named: "笑脸"), for: .selected)
        faceBtn?.setImage(UIImage(named: "笑脸"), for: .highlighted)
        faceBtn?.setImage(UIImage(named: "笑脸"), for: .disabled)
        faceBtn?.addTarget(self, action: #selector(onFace), for: .touchUpInside)
        self.addSubview(faceBtn!)
        moreBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        moreBtn?.setImage(UIImage(named: "聊天框加号"), for: .normal)
        moreBtn?.setImage(UIImage(named: "聊天框加号"), for: .selected)
        moreBtn?.setImage(UIImage(named: "聊天框加号"), for: .highlighted)
        moreBtn?.setImage(UIImage(named: "聊天框加号"), for: .disabled)
        moreBtn?.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        self.addSubview(moreBtn!)
        inputTextFeild?.mas_makeConstraints({ (make) in
            if model.type == EMConversationTypeChat {
                make?.left.equalTo()(stylyBtn?.mas_right)?.offset()(8)
            }else{
                make?.left.equalTo()(self.mas_left)?.offset()(16)
            }
            make?.top.equalTo()(self.mas_top)?.offset()(9)
            make?.bottom.equalTo()(self.mas_bottom)?.offset()(-9)
            make?.right.equalTo()(faceBtn?.mas_left)?.offset()(-8)
        })
        faceBtn?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(inputTextFeild?.mas_right)?.offset()(8)
            make?.top.equalTo()(self.mas_top)?.offset()(9)
            make?.bottom.equalTo()(self.mas_bottom)?.offset()(-9)
            make?.right.equalTo()(moreBtn?.mas_left)?.offset()(-8)
            make?.width.mas_equalTo()(40)
        })
        moreBtn?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(faceBtn?.mas_right)?.offset()(8)
            make?.top.equalTo()(self.mas_top)?.offset()(9)
            make?.bottom.equalTo()(self.mas_bottom)?.offset()(-9)
            make?.right.equalTo()(self.mas_right)?.offset()(-8)
            make?.width.mas_equalTo()(40)
        })
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func onVoice(){
        
    }
    
    @objc func onFace(){
        
    }
    
    @objc func onMore(){
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if delegate != nil && (delegate?.responds(to: #selector(delegate?.didSendText(_:))))! {
                delegate?.didSendText?(textView.text)
            }
            inputTextFeild?.text = ""
            return false
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if delegate != nil && (delegate?.responds(to: #selector(delegate?.inputTextViewDidBeginEditing(_:))))! {
            delegate?.inputTextViewDidBeginEditing?(inputTextFeild)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if delegate != nil && (delegate?.responds(to: #selector(delegate?.inputTextViewWillBeginEditing(_:))))! {
            delegate?.inputTextViewWillBeginEditing?(inputTextFeild)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.hasSuffix("@") {
            if delegate != nil && (delegate?.responds(to: #selector(delegate?.didInputAt(inLocation:))))! {
                if (delegate?.didInputAt?(inLocation: UInt(textView.text.count-1)))! {
                    
                }
            }
        }
    }
    
}
