//
//  MomentLikeView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/19/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

typealias MomentMoreBlock = (Int) -> Void

class MomentLikeView: UIView {
    
    private var panl:UIView = UIView(frame: .zero)
    
    private var click:MomentMoreBlock?
    
    private var like:Bool

    init(_ btn:UIButton,_ cli:MomentMoreBlock?, _ islike:Bool) {
        like = islike
        super.init(frame: UIScreen.main.bounds)
        self.isUserInteractionEnabled = true
        click = cli
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        let rect = btn.convert(btn.bounds, to: self)
        panl.frame = CGRect(x: rect.minX - DCUtill.SCRATIOX(10), y: rect.minY - DCUtill.SCRATIOX(12), width: 2, height: DCUtill.SCRATIOX(42))
        panl.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#00000099")
        panl.layer.cornerRadius = DCUtill.SCRATIOX(5)
        panl.layer.masksToBounds = true
        self.addSubview(panl)
        let lik = UIButton(type: .system)
        lik.tintColor = .white
        if like {
            lik.setImage(UIImage(named: "moment_like"), for: .normal)
        }else{
            lik.setImage(UIImage(named: "moment_unlike"), for: .normal)
        }
        lik.setTitle("赞", for: .normal)
        lik.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        lik.addTarget(self, action: #selector(onLike), for: .touchUpInside)
        lik.frame = CGRect(x: 0, y: 0, width: DCUtill.SCRATIOX(100), height: DCUtill.SCRATIOX(42))
        panl.addSubview(lik)
        let line = UIView(frame: CGRect(x: DCUtill.SCRATIOX(100), y: DCUtill.SCRATIOX(10), width: DCUtill.SCRATIOX(1), height: DCUtill.SCRATIOX(22)))
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#7C7C7CFF")
        panl.addSubview(line)
        let conment = UIButton(type: .system)
        conment.tintColor = .white
        conment.frame = CGRect(x: DCUtill.SCRATIOX(101), y: 0, width: DCUtill.SCRATIOX(100), height: DCUtill.SCRATIOX(42))
        conment.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        conment.setTitle("评论", for: .normal)
        conment.setImage(UIImage(named: "moment_conment"), for: .normal)
        conment.addTarget(self, action: #selector(onCommit), for: .touchUpInside)
        panl.addSubview(conment)
    }
    
    required init?(coder: NSCoder) {
        like = false
        super.init(coder: coder)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.panl.frame = CGRect(x: self.panl.frame.minX - DCUtill.SCRATIOX(201), y: self.panl.frame.minY, width: DCUtill.SCRATIOX(201), height: DCUtill.SCRATIOX(42))
        }
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.panl.frame = CGRect(x: self.panl.frame.minX + DCUtill.SCRATIOX(201), y: self.panl.frame.minY, width: 0, height: DCUtill.SCRATIOX(42))
        }) { (f) in
            self.removeFromSuperview()
        }
    }
    
    @objc func onLike() {
        if let c = self.click {
            if like {
                c(2)
            }else{
                c(1)
            }
        }
        dismiss()
    }
    
    @objc func onCommit() {
        if let c = self.click {
            c(3)
        }
        dismiss()
    }

}
