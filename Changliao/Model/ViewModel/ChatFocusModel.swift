//
//  ChatFocusModel.swift
//  boxin
//
//  Created by guduzhonglao on 6/26/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation
import SDWebImage
class ChatFocusModel: NSObject,UITableViewDelegate,UITableViewDataSource,EaseMessageCellDelegate {
    var messageDatasource:[Any] = Array<Any>()
    var dataArray:[Any] = Array<Any>()
    var currentIsInBottom:Bool = true
    weak var chat:ChatViewController?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = self.dataArray[indexPath.row]
        if msg is String {
            return chat!.timeCellHeight
        }else{
            let model = msg as! IMessageModel
            if model.message.ext != nil {
                if model.message.body.type == EMMessageBodyTypeText && model.message.ext["type"] as? String == "person" {
                    return UserCardTableViewCell.cellHeight(withModel: model)
                }
                if model.message.body.type == EMMessageBodyTypeText && model.message.ext["em_recall"] as? Bool ?? false {
                    return 30
                }
            }
            if chat?.dataSource.isEmotionMessageFormessageViewController?(chat, messageModel: model) ?? false {
                return EaseCustomMessageCell.cellHeight(model)
            }
            return EaseBaseMessageCell.cellHeight(withModel: model)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.dataArray[indexPath.row]
        if let str = obj as? String {
            let timecell = EaseMessageTimeCell(style: .default, reuseIdentifier: EaseMessageTimeCell.cellIdentifier())
            timecell.selectionStyle = .none
            timecell.title = str
            return timecell
        }
        let model = obj as! EaseMessageModel
        if let cell = chat?.messageViewController(tableView, cellFor: model) {
            return cell
        }
        if chat?.dataSource.isEmotionMessageFormessageViewController?(chat, messageModel: model) ?? false {
            var sendcell = tableView.dequeueReusableCell(withIdentifier: EaseCustomMessageCell.cellIdentifier(withModel: model)) as? EaseCustomMessageCell
            if sendcell == nil {
                sendcell = EaseCustomMessageCell(style: .default, reuseIdentifier: EaseCustomMessageCell.cellIdentifier(withModel: model), model: model)
            }
            if let emotion = chat?.dataSource.emotionURLFormessageViewController?(chat, messageModel: model) {
                if !emotion.emotionOriginal.isEmpty {
                    model.image = UIImage(contentsOfFile: emotion.emotionOriginal)
                }else{
                    model.image = nil
                }
                model.fileURLPath = emotion.emotionOriginalURL
            }
            sendcell?.selectionStyle = .none
            sendcell?.model = model
            sendcell?.delegate = chat
            return sendcell!
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: EaseBaseMessageCell.cellIdentifier(withModel: model)) as? EaseBaseMessageCell
        if cell == nil {
            cell = EaseBaseMessageCell(style: .default, reuseIdentifier: EaseBaseMessageCell.cellIdentifier(withModel: model), model: model)
        }else{
            cell?.model = model
        }
        cell?.selectionStyle = .none
        cell?.delegate = self
        return cell!
    }



    
    func messageCellSelected(_ model: IMessageModel!) {
        if model == nil {
            return
        }
        chat?.focusCellClick = true
        chat?.messageCellSelected(model)
    }
    
    func avatarViewSelcted(_ model: IMessageModel!) {
        if model == nil {
            return
        }
        chat?.avatarViewSelcted(model)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentOffSetY = scrollView.contentOffset.y
        let bottomeOffset = scrollView.contentSize.height - contentOffSetY
        if bottomeOffset <= height {
            self.currentIsInBottom = true
        }else
        {
            self.currentIsInBottom = false
        }
    }
}
