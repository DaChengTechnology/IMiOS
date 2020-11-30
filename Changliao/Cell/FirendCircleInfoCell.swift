//
//  FirendCircleInfoCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 2/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

typealias FriendCircleClick = ((_ index:Int)->Void)

class FirendCircleInfoCell: UITableViewCell {
    
    var avatar:UIImageView=UIImageView(image: UIImage(named: "moren"))
    var name:UILabel=UILabel(frame: .zero)
    var content:UILabel=UILabel(frame: .zero)
    var time:UILabel=UILabel(frame: .zero)
    var moreBtn:UIButton=UIButton(type: .custom)
    var pic1:UIImageView=UIImageView(frame: .zero)
    var pic2:UIImageView=UIImageView(frame: .zero)
    var pic3:UIImageView=UIImageView(frame: .zero)
    var pic4:UIImageView=UIImageView(frame: .zero)
    var pic5:UIImageView=UIImageView(frame: .zero)
    var pic6:UIImageView=UIImageView(frame: .zero)
    var pic7:UIImageView=UIImageView(frame: .zero)
    var pic8:UIImageView=UIImageView(frame: .zero)
    var pic9:UIImageView=UIImageView(frame: .zero)
    private var likeCommit = UIView(frame: .zero)
    private var picCount = 0
    private var click:FriendCircleClick?
    var model:FriendCircleData?{
        didSet{
            if let avatarUrl = self.model?.portrait {
                avatar.sd_setImage(with: URL(string: avatarUrl), completed: nil)
            }else{
                avatar.image=UIImage(named: "moren")
            }
            name.text=self.model?.user_name
            dbQuese.async {
                if let f = QueryFriend.shared.getFriend(UserId: self.model?.user_id ?? ""){
                    DispatchQueue.main.async {
                        self.name.text = (f.target_user_nickname?.isEmpty ?? true) ? f.friend_self_name : f.target_user_nickname
                    }
                }
            }
            if !(self.model?.pic1?.isEmpty ?? true) {
                picCount=1
                pic1.sd_setImage(with: URL(string: self.model!.pic1!), completed: nil)
            }
            if !(self.model?.pic2?.isEmpty ?? true) {
                picCount=2
                pic2.sd_setImage(with: URL(string: self.model!.pic2!), completed: nil)
            }
            if !(self.model?.pic3?.isEmpty ?? true) {
                picCount=3
                pic3.sd_setImage(with: URL(string: self.model!.pic3!), completed: nil)
            }
            if !(self.model?.pic4?.isEmpty ?? true) {
                picCount=4
                pic4.sd_setImage(with: URL(string: self.model!.pic4!), completed: nil)
            }
            if !(self.model?.pic5?.isEmpty ?? true) {
                picCount=5
                pic5.sd_setImage(with: URL(string: self.model!.pic5!), completed: nil)
            }
            if !(self.model?.pic6?.isEmpty ?? true) {
                picCount=6
                pic6.sd_setImage(with: URL(string: self.model!.pic6!), completed: nil)
            }
            if !(self.model?.pic7?.isEmpty ?? true) {
                picCount=7
                pic7.sd_setImage(with: URL(string: self.model!.pic7!), completed: nil)
            }
            if !(self.model?.pic8?.isEmpty ?? true) {
                picCount=8
                pic8.sd_setImage(with: URL(string: self.model!.pic8!), completed: nil)
            }
            if !(self.model?.pic9?.isEmpty ?? true) {
                picCount=9
                pic9.sd_setImage(with: URL(string: self.model!.pic9!), completed: nil)
            }
            switch picCount {
            case 1:
                pic2.image=nil
                pic3.image=nil
                pic4.image=nil
                pic5.image=nil
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=false
                pic3.isUserInteractionEnabled=false
                pic4.isUserInteractionEnabled=false
                pic5.isUserInteractionEnabled=false
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(200))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic3.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic4.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic5.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 2:
                pic3.image=nil
                pic4.image=nil
                pic5.image=nil
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=false
                pic4.isUserInteractionEnabled=false
                pic5.isUserInteractionEnabled=false
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic4.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic5.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 3:
                pic4.image=nil
                pic5.image=nil
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=false
                pic5.isUserInteractionEnabled=false
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic5.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 4:
                pic5.image=nil
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=false
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic3.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(134))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 5:
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=true
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic4.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 6:
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=true
                pic6.isUserInteractionEnabled=true
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic6.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 7:
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=true
                pic6.isUserInteractionEnabled=true
                pic7.isUserInteractionEnabled=true
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic6.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic7.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic7.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 8:
                pic9.image=nil
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=true
                pic6.isUserInteractionEnabled=true
                pic7.isUserInteractionEnabled=true
                pic8.isUserInteractionEnabled=true
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic6.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic7.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic8.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic7.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            case 9:
                pic1.isUserInteractionEnabled=true
                pic2.isUserInteractionEnabled=true
                pic3.isUserInteractionEnabled=true
                pic4.isUserInteractionEnabled=true
                pic5.isUserInteractionEnabled=true
                pic6.isUserInteractionEnabled=true
                pic7.isUserInteractionEnabled=true
                pic8.isUserInteractionEnabled=true
                pic9.isUserInteractionEnabled=true
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic2.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic3.mas_updateConstraints { (make) in
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic4.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic5.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic6.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic1.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic7.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic8.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic1.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                pic9.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic4.mas_bottom)?.offset()(DCUtill.SCRATIOX(4))
                    make?.left.equalTo()(pic2.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                    make?.width.mas_equalTo()(DCUtill.SCRATIOX(88))
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(pic7.mas_bottom)?.offset()(DCUtill.SCRATIOX(33))
                }
            default:
                pic1.image=nil
                pic2.image=nil
                pic3.image=nil
                pic4.image=nil
                pic5.image=nil
                pic6.image=nil
                pic7.image=nil
                pic8.image=nil
                pic9.image=nil
                pic1.isUserInteractionEnabled=false
                pic2.isUserInteractionEnabled=false
                pic3.isUserInteractionEnabled=false
                pic4.isUserInteractionEnabled=false
                pic5.isUserInteractionEnabled=false
                pic6.isUserInteractionEnabled=false
                pic7.isUserInteractionEnabled=false
                pic8.isUserInteractionEnabled=false
                pic9.isUserInteractionEnabled=false
                pic1.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic2.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic3.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic4.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic5.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic6.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic7.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic8.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                pic9.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(0)
                }
                time.mas_updateConstraints { (make) in
                    make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(22))
                }
            }
            content.text=self.model?.content
            time.text=self.model?.create_time
            if let like = self.model?.likeList {
                if let comments = self.model?.commentsList {
                    clearChildView()
                    let image = UIImageView(image: UIImage(named: "like"))
                    likeCommit.addSubview(image)
                    image.mas_makeConstraints { (make) in
                        make?.left.offset()(DCUtill.SCRATIOX(11))
                        make?.top.offset()(DCUtill.SCRATIOX(15))
                        make?.width.mas_equalTo()(DCUtill.SCRATIOX(20))
                        make?.height.mas_equalTo()(DCUtill.SCRATIOX(17))
                    }
                    let likeLabel = UILabel(frame: .zero)
                    likeLabel.font = DCUtill.FONTX(16)
                    likeLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#6F7EA3")
                    var namelist = Array<String>()
                    for l in like {
                        if let n = l?.friend_name {
                            namelist.append(n)
                        }
                    }
                    likeLabel.text=namelist.joined(separator: "，")
                    likeLabel.numberOfLines=3
                    likeCommit.addSubview(likeLabel)
                    likeLabel.mas_makeConstraints { (make) in
                        make?.left.equalTo()(image.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                        make?.top.offset()(DCUtill.SCRATIOX(11))
                        make?.right.offset()(DCUtill.SCRATIOX(-11))
                    }
                    let line = UIView(frame: .zero)
                    line.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#E2E2E2")
                    likeCommit.addSubview(line)
                    line.mas_makeConstraints { (make) in
                        make?.left.offset()(0)
                        make?.right.offset()(0)
                        make?.top.equalTo()(likeLabel.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
                        make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
                    }
                    weak var temp = line
                    for c in comments {
                        let arrt = NSMutableAttributedString(string: String(format: "%@:%@", c?.friend_name ?? "",c?.comment ?? ""))
                        arrt.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: arrt.length))
                        arrt.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: 0, length: c?.friend_name?.count ?? 0))
                        let label = UILabel(frame: .zero)
                        label.font = DCUtill.FONT(x: 14)
                        label.attributedText=arrt
                        likeCommit.addSubview(label)
                        label.mas_makeConstraints { (make) in
                            make?.left.offset()(DCUtill.SCRATIOX(10))
                            make?.top.equalTo()(temp?.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
                            make?.right.offset()(DCUtill.SCRATIOX(-10))
                        }
                        temp=label
                    }
                    temp?.mas_updateConstraints({ (make) in
                        make?.bottom.offset()(DCUtill.SCRATIOX(-10))
                    })
                }else{
                    clearChildView()
                    let image = UIImageView(image: UIImage(named: "like"))
                    likeCommit.addSubview(image)
                    image.mas_makeConstraints { (make) in
                        make?.left.offset()(DCUtill.SCRATIOX(11))
                        make?.top.offset()(DCUtill.SCRATIOX(15))
                        make?.width.mas_equalTo()(DCUtill.SCRATIOX(20))
                        make?.height.mas_equalTo()(DCUtill.SCRATIOX(17))
                    }
                    let likeLabel = UILabel(frame: .zero)
                    likeLabel.font = DCUtill.FONTX(16)
                    likeLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#6F7EA3")
                    var namelist = Array<String>()
                    for l in like {
                        if let n = l?.friend_name {
                            namelist.append(n)
                        }
                    }
                    likeLabel.text=namelist.joined(separator: "，")
                    likeLabel.numberOfLines=3
                    likeCommit.addSubview(likeLabel)
                    likeLabel.mas_makeConstraints { (make) in
                        make?.left.equalTo()(image.mas_right)?.offset()(DCUtill.SCRATIOX(4))
                        make?.top.offset()(DCUtill.SCRATIOX(11))
                        make?.right.offset()(DCUtill.SCRATIOX(-11))
                        make?.bottom.offset()(DCUtill.SCRATIOX(-11))
                    }
                }
            }else{
                if let comments = self.model?.commentsList {
                    weak var temp = likeCommit
                    for c in comments {
                        let arrt = NSMutableAttributedString(string: String(format: "%@:%@", c?.friend_name ?? "",c?.comment ?? ""))
                        arrt.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: arrt.length))
                        arrt.addAttribute(.foregroundColor, value: UIColor.hexadecimalColor(hexadecimal: "#6F7EA3"), range: NSRange(location: 0, length: c?.friend_name?.count ?? 0))
                        let label = UILabel(frame: .zero)
                        label.font = DCUtill.FONT(x: 14)
                        label.attributedText=arrt
                        likeCommit.addSubview(label)
                        label.mas_makeConstraints { (make) in
                            make?.left.offset()(DCUtill.SCRATIOX(10))
                            if temp === likeCommit {
                                make?.top.equalTo()(temp?.mas_bottom)?.offset()(DCUtill.SCRATIOX(11))
                            }else{
                                make?.top.equalTo()(temp?.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
                            }
                            make?.right.offset()(DCUtill.SCRATIOX(-10))
                        }
                        temp=label
                    }
                    temp?.mas_updateConstraints({ (make) in
                        make?.bottom.offset()(DCUtill.SCRATIOX(-10))
                    })
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatar.layer.cornerRadius=DCUtill.SCRATIOX(47/2)
        avatar.layer.masksToBounds=true
        avatar.isUserInteractionEnabled = true
        avatar.tag = 1
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        avatar.addGestureRecognizer(avatarTap)
        self.contentView.addSubview(avatar)
        avatar.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIOX(33))
            make?.left.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIOX(16))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(47))
            make?.height.equalTo()(make?.width)
        }
        name.textColor = UIColor.hexadecimalColor(hexadecimal: "#576A93")
        name.font=DCUtill.FONTX(18)
        name.tag=2
        name.isUserInteractionEnabled=true
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        name.addGestureRecognizer(nameTap)
        self.contentView.addSubview(name)
        name.mas_makeConstraints { (make) in
            make?.top.equalTo()(avatar)
            make?.left.equalTo()(avatar.mas_right)?.offset()(DCUtill.SCRATIOX(12))
        }
        content.textColor=UIColor.black
        content.font=DCUtill.FONTX(18)
        content.tag=3
        content.numberOfLines = 3
        let contentTap=UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        content.isUserInteractionEnabled=true
        content.addGestureRecognizer(contentTap)
        self.contentView.addSubview(content)
        content.mas_makeConstraints { (make) in
            make?.left.equalTo()(avatar.mas_right)?.offset()(DCUtill.SCRATIOX(12))
            make?.top.equalTo()(name.mas_bottom)?.offset()(DCUtill.SCRATIOX(10))
            make?.right.lessThanOrEqualTo()(self.contentView)?.offset()(DCUtill.SCRATIOX(-15))
        }
        time.textColor=UIColor.hexadecimalColor(hexadecimal: "979797")
        time.font=DCUtill.FONTX(14)
        self.contentView.addSubview(time)
        time.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.bottom.equalTo()(likeCommit.mas_top)?.offset()(DCUtill.SCRATIOX(-10))
        }
        moreBtn.setImage(UIImage(named: "more_button"), for: .normal)
        moreBtn.addTarget(self, action: #selector(onMoreClick(_:)), for: .touchUpInside)
        self.contentView.addSubview(moreBtn)
        moreBtn.mas_makeConstraints { (make) in
            make?.right.offset()(DCUtill.SCRATIOX(22))
            make?.centerY.equalTo()(time)
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(36))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(22))
        }
        likeCommit.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#F3F3F4")
        likeCommit.layer.cornerRadius=DCUtill.SCRATIOX(6)
        likeCommit.layer.masksToBounds=true
        let likeCommitTap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        likeCommit.tag=30
        likeCommit.isUserInteractionEnabled=true
        likeCommit.addGestureRecognizer(likeCommitTap)
        self.contentView.addSubview(likeCommit)
        likeCommit.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.bottom.offset()(DCUtill.SCRATIOX(-5))
            make?.height.mas_equalTo()(0)
        }
        pic1.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic1.layer.masksToBounds=true
        pic1.contentMode = .scaleAspectFill
        pic1.tag=11
        let pic1Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic1.addGestureRecognizer(pic1Tap)
        self.contentView.addSubview(pic1)
        pic1.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic2.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic2.layer.masksToBounds=true
        pic2.contentMode = .scaleAspectFill
        pic2.tag=12
        let pic2Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic2.addGestureRecognizer(pic2Tap)
        self.contentView.addSubview(pic2)
        pic2.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic3.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic3.layer.masksToBounds=true
        pic3.contentMode = .scaleAspectFill
        pic3.tag=13
        let pic3Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic3.addGestureRecognizer(pic3Tap)
        self.contentView.addSubview(pic3)
        pic3.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic4.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic4.layer.masksToBounds=true
        pic4.contentMode = .scaleAspectFill
        pic4.tag=14
        let pic4Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic4.addGestureRecognizer(pic4Tap)
        self.contentView.addSubview(pic4)
        pic4.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic5.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic5.layer.masksToBounds=true
        pic5.contentMode = .scaleAspectFill
        pic5.tag=15
        let pic5Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic5.addGestureRecognizer(pic5Tap)
        self.contentView.addSubview(pic5)
        pic5.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic7.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic7.layer.masksToBounds=true
        pic7.contentMode = .scaleAspectFill
        pic7.tag=17
        let pic7Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic7.addGestureRecognizer(pic7Tap)
        self.contentView.addSubview(pic7)
        pic7.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic6.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic6.layer.masksToBounds=true
        pic6.contentMode = .scaleAspectFill
        pic6.tag=16
        let pic6Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic6.addGestureRecognizer(pic6Tap)
        self.contentView.addSubview(pic6)
        pic6.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic8.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic8.layer.masksToBounds=true
        pic8.contentMode = .scaleAspectFill
        pic8.tag=18
        let pic8Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic8.addGestureRecognizer(pic8Tap)
        self.contentView.addSubview(pic8)
        pic8.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
        pic9.layer.cornerRadius=DCUtill.SCRATIOX(6)
        pic9.layer.masksToBounds=true
        pic9.contentMode = .scaleAspectFill
        pic9.tag=19
        let pic9Tap = UITapGestureRecognizer(target: self, action: #selector(onHeadClick(_:)))
        pic9.addGestureRecognizer(pic9Tap)
        self.contentView.addSubview(pic9)
        pic9.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(75))
            make?.top.equalTo()(content.mas_bottom)?.offset()(DCUtill.SCRATIOX(12))
            make?.width.mas_equalTo()(0)
            make?.height.equalTo()(make?.width)
        }
    }
    
    @objc func onHeadClick(_ g:UIGestureRecognizer){
        if g.state == .ended {
            click?(g.view?.tag ?? 0)
        }
    }
    
    @objc func onMoreClick(_ btn:UIButton){
        click?(40)
    }
    
    func setClick(_ c:@escaping FriendCircleClick) {
        click=c
    }
    
    func clearChildView() {
        for v in likeCommit.subviews {
            v.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
