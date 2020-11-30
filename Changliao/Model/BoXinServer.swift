//
//  BoXinServer.swift
//  boxin
//
//  Created by guduzhonglao on 6/8/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Moya
import Alamofire
import Result

let boXinURL = "https://app.2000rmb.com/im/api/"
//let boXinURL = "https://im.nongpj.cn/im/api/"
//let boXinURL = "https://clios.3nn1.com/im/api/"
let versionIndex = 6
//let versionIndex = 2
enum boXinService {
    case SendSMS(model:SendSMSSendModel)
    case VerifySMS(model:VerifySMSSendModel)
    case Login(model:LoginSendModel)
    case LoginWithCheckCode(model:LoginSendModel)
    case Upload(url:URL)
    case UserInfo(model:UserInfoSendModel)
    case FriendList(model:UserInfoSendModel)
    case GetUserByID(model:GetUserByIDSendModel)
    case GetUserByMobile(model:GetUserByMobileSendModel)
    case CreateGroup(model:CreateGroupSendModel)
    case ChangeGroup(model:ChangeGroupInfoSendModel)
    case DeleteGroup(model:DeleteGroupSendModel)
    case ApplyForUser(model:AddFriendNickNameModel)
    case AgreeApplyForUser(model:ApplyForSendModel)
    case RefuseApplyForUser(model:ApplyForSendModel)
    case InviteList(model:UserInfoSendModel)
    case DeleteFriend(model:ApplyForSendModel)
    case ChangeShield(model:ApplyForSendModel)
    case ChangeStar(model:ApplyForSendModel)
    case GetGroupInfo(model:DeleteGroupSendModel)
    case ChangeGroupOwner(model:ChangeGroupOwnerSendModel)
    case ChangePortrait(model:ChangePortraitSendModel)
    case ChangeNickName(model:ChangeNickNameSendModel)
    case ChangePhone(model:ChangePhoneSendModel)
    case CheckChatTop(model:ChatTopSendModel)
    case SetChatTop(model:ChatTopSendModel)
    case CancelChatTop(model:ChatTopSendModel)
    case ChangeFriendNickName(model:ChangeFriendNickNameSendModel)
    case GroupAddBatch(model:AddBatchSendModel)
    case GroupRemoveBatch(model:AddBatchSendModel)
    case GroupMemberList(model:DeleteGroupSendModel)
    case ChangeGroupNickName(model:ChangeGroupNickNameSendModel)
    case GetMyGroup(model:UserInfoSendModel)
    case ExitGroup(model:DeleteGroupSendModel)
    case GetChatTap(model:UserInfoSendModel)
    case SubmitNotice(model:SubmitNoticeSendModel)
    case GetGroupNotice(model:DeleteGroupSendModel)
    case AddGroupMenager(model:AddGroupMenagerSendModel)
    case DeleteGroupMenager(model:DeleteGroupMenagerSendModel)
    case SetShieldSingle(model:ShieldSigleSendModel)
    case CancelShieldSingle(model:ShieldSigleSendModel)
    case SetFocus(model:FocusSendModel)
    case CancelFocus(model:FocusSendModel)
    case SetGroupAllBanned(model:DeleteGroupSendModel)
    case CancelGroupAllBanned(model:DeleteGroupSendModel)
    case EditGroupMemberNickName(model:EditGroupChangeNickNameSendModel)
    case SetGroupSheild(model:DeleteGroupSendModel)
    case CancelGroupSheild(model:DeleteGroupSendModel)
    case GetOneGroupUserInfo(model:GetOneGroupUserInfoSendModel)
    case SaveImageForFace(model:SaveImageForFace)
    case DeleteFace(model:DeleteFaceModel)
    case AllFaceList(model:UserInfoSendModel)
    case DeleteMutibleFace(model:DeleteMutibleFaceSendModel)
    case AdvertQuery
    case DownLoad(url:String,filepath:String)
    case GetVersion
    case HeartBeat(model:UserInfoSendModel)
    case GetOnlineUser(model:GetOnlineUserSendModel)
    case GetChatBackground(model:GetChatBackgroundSendModel)
    case SetChatBackground(model:SetChatBackgroundSendModel)
    case SetYhjf(model:YhjfSendModel)
    case CancelYhjf(model:YhjfSendModel)
    case SaveRevokeMessageRecord(model:SaveRevokeMessageRecordSendModel)
    case GetLoginTrace(model:GetLoginTraceSendModel)
    case QRLogin(model:QRLoginSendModel)
    case GetUserLastOnlineTime(model:GetChatBackgroundSendModel)
    case FriendListWithFenzu(model:UserInfoSendModel)
    case ReSort(model:ReSortSendModel)
    case MoveFriendToNewGroup(model:MoveFriendToGroupSendModel)
    case getFriendGroup(model:UserInfoSendModel)
    case AddFenzu(model:AddFenzuSendModel)
    case DeleteFenzu(model:DeleteFenzuSendModel)
    case GetConllectionList(model:GetConllectionListSendModel)
    case SubmitCollection(model:SubmitCollectionSendModel)
    case DeleteCollection(model:DeleteCollectionSendModel)
    case GetLastCollection(model:UserInfoSendModel)
    case GetCollectionListBeginWithID(model:GetCollectionListBeginWithIDSendModel)
    case RegistAndLogin(model:RegistAndLoginSendModel)
    case ReportUser(model:ReportSendModel)
    case GetMyFriendCircle(model:GetMyFriendCircleSendModel)
    case GetMomentBK(model:YhjfSendModel)
    case GiveLike(model:MomentSendModel)
    case CancelLike(model:MomentSendModel)
    case DoComment(model:DoCommentSendModel)
    case ReplyCpmment(model:ReplyCommentSendModel)
    case GetMomentDetail(model:GetMomentDetailtSendModel)
    case DeleteMomentComment(model:DeleteMomentCommentSendModel)
    case DeleteMomentReply(model:DeleteMomentReplySendModel)
    case DeleteMoment(model:GetMomentDetailtSendModel)
    case SendMoment(model:SendMomentSendModel)
    case GetMomentByUserId(model:GetMomentByUserIdSendModel)
    case SetMomentBK(model:SetMomentBKSendModel)
    case GetUserBalance(model:UserInfoSendModel)
    case BankCardList(model:UserInfoSendModel)
    case DeleteBankCard(model:DeleteBankCardSendModel)
}


final class OnLinePugin :PluginType {
    let userQueue = DispatchQueue(label: "net.queue")
    func process(_ result: Swift.Result<Response, MoyaError>, target: TargetType) -> Swift.Result<Response, MoyaError> {
        userQueue.async {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastNetRequest")
            UserDefaults.standard.synchronize()
        }
        if let code = try? result.get().statusCode {
            BoXinUtil.isTokenExpired(code)
        }
        return result
    }
}

let BoXinProvider = MoyaProvider<boXinService>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter),OnLinePugin()])

extension boXinService : TargetType {
    var baseURL: URL {
        switch self {
        case .DownLoad(let url, filepath: _):
            return URL(string: url)!
        default:
            return URL(string: boXinURL)!
        }
    }
    
    var path: String {
        switch self {
        case .SendSMS(model: _):
            return "register/newSendSms"
        case .VerifySMS(model: _):
            return "register/verifySms"
        case .Login(model: _):
            return "register/loginPassword"
        case .Upload(url: _):
            return "common/updateFile"
        case .UserInfo(model: _):
            return "user/userInfo"
        case .FriendList(model:_):
            return "contacts/friendList"
        case .GetUserByID(model: _):
            return "user/getUserByUserId"
        case .GetUserByMobile(model: _):
            return "user/getUserByMobile"
        case .CreateGroup(model: _):
            return "group/create"
        case .ChangeGroup(model: _):
            return "group/edit"
        case .DeleteGroup(model: _):
            return "group/delete"
        case .ApplyForUser( _):
            return "contacts/applyFor"
        case .AgreeApplyForUser( _):
            return "contacts/agree"
        case .RefuseApplyForUser( _):
            return "contacts/refuse"
        case .InviteList( _):
            return "contacts/inviteList"
        case .DeleteFriend( _):
            return "contacts/delFriend"
        case .ChangeShield( _):
            return "contacts/changeShield"
        case .ChangeStar( _):
            return "contacts/changeStar"
        case .GetGroupInfo( _):
            return "group/detail"
        case .ChangeGroupOwner( _):
            return "group/chatgroups"
        case .ChangePortrait( _):
            return "user/updatePortrait"
        case .ChangeNickName( _):
            return "user/updateUserName"
        case .ChangePhone(model: _):
            return "user/updateMobile"
        case .CheckChatTop(_):
            return "contacts/checkZhiding"
        case .SetChatTop(_):
            return "contacts/zhiding"
        case .CancelChatTop(_):
            return "contacts/delZhiding"
        case .ChangeFriendNickName( _):
            return "contacts/editFriendNickname"
        case .GroupAddBatch( _):
            return "groupUser/addBatch"
        case .GroupRemoveBatch( _):
            return "groupUser/removeBatch"
        case .GroupMemberList( _):
            return "groupUser/groupUserList"
        case .ChangeGroupNickName(_):
            return "groupUser/editNickName"
        case .GetMyGroup( _):
            return "groupUser/getMyGroup"
        case .ExitGroup(_):
            return "groupUser/exit"
        case .GetChatTap( _):
            return "contacts/getTopData"
        case .SubmitNotice( _):
            return "group/submitNotice"
        case .GetGroupNotice( _):
            return "group/getNotice"
        case .AddGroupMenager( _):
            return "groupUser/addManager"
        case .DeleteGroupMenager( _):
            return "groupUser/delManager"
        case .SetShieldSingle( _):
            return "groupUser/setShieldSingle"
        case .CancelShieldSingle( _):
            return "groupUser/cancelShieldSingle"
        case .SetFocus( _):
            return "groupUser/setFocus"
        case .CancelFocus( _):
            return "groupUser/cancelFocus"
        case .SetGroupAllBanned( _):
            return "group/setAllBanned"
        case .CancelGroupAllBanned( _):
            return "group/cancelAllBanned"
        case .EditGroupMemberNickName( _):
            return "groupUser/editNormalNickName"
        case .SetGroupSheild( _):
            return "groupUser/setPingbi"
        case .CancelGroupSheild( _):
            return "groupUser/cancelPingbi"
        case .GetOneGroupUserInfo( _):
            return "groupUser/getOneGroupUserInfo"
        case .SaveImageForFace( _):
            return "phiz/save"
        case .DeleteFace( _):
            return "phiz/delete"
        case .AllFaceList( _):
            return "phiz/list"
        case .DeleteMutibleFace( _):
            return "phiz/delBatch"
        case .AdvertQuery:
            return "common/advertQuery"
        case .DownLoad( _, _):
            return ""
        case .GetVersion:
            return "common/getVersion"
        case .HeartBeat(model: _):
            return "common/heartbeat"
        case .GetOnlineUser( _):
            return "common/getOnlineUserId"
        case .GetChatBackground( _):
            return "user/getChatBackground"
        case .SetChatBackground( _):
            return "user/setChatBackground"
        case .SetYhjf(_):
            return "contacts/setYhjf"
        case .CancelYhjf(_):
            return "contacts/cancelYhjf"
        case .SaveRevokeMessageRecord( _):
            return "group/saveRevokeMessageRecord"
        case .GetLoginTrace(_):
            return "user/getLoginTrace"
        case .QRLogin( _):
            return "register/qrLogin"
        case .GetUserLastOnlineTime( _):
            return "user/getUserLastOnlineTime"
        case .FriendListWithFenzu( _):
            return "contacts/friendListWithFenzu"
        case .ReSort( _):
            return "contacts/reSort"
        case .MoveFriendToNewGroup(_):
            return "contacts/moveFriendToNewFenzu"
        case .getFriendGroup( _):
            return "contacts/getFenzuList"
        case .AddFenzu( _):
            return "contacts/addFenzu"
        case .DeleteFenzu( _):
            return "contacts/deleteFenzu"
        case .GetConllectionList( _):
            return "user/getCollectionList"
        case .SubmitCollection( _):
            return "user/submitCollection"
        case .DeleteCollection( _):
            return "user/deleteCollection"
        case .GetLastCollection( _):
            return "user/getLatestCollection"
        case .GetCollectionListBeginWithID( _):
            return "user/getCollectionListBeginWithID"
        case .RegistAndLogin( _):
            return "register/registerLogin"
        case .ReportUser( _):
            return "inform/create"
        case .LoginWithCheckCode( _):
            return "register/login"
        case .GetMyFriendCircle( _):
            return "friendCircle/getMyFriendCircle"
        case .GetMomentBK( _):
            return "friendCircle/getBackGround"
        case .GiveLike( _):
            return "friendCircle/giveLike"
        case .CancelLike( _):
            return "friendCircle/cancelLike"
        case .DoComment( _):
            return "friendCircle/doComment"
        case .ReplyCpmment( _):
            return "friendCircle/doReply"
        case .GetMomentDetail( _):
            return "friendCircle/getCircleDetail"
        case .DeleteMomentComment( _):
            return "friendCircle/deleteCircleComment"
        case .DeleteMomentReply( _):
            return "friendCircle/deleteCircleReply"
        case .DeleteMoment( _):
            return "friendCircle/deleteCircle"
        case .SendMoment( _):
            return "friendCircle/publish"
        case .GetMomentByUserId( _):
            return "friendCircle/getPublishByUserId"
        case .SetMomentBK( _):
            return "friendCircle/setBackGround"
        case .GetUserBalance( _):
            return "pay/getUserBalance"
        case .BankCardList( _):
            return "pay/bankcardList"
        case .DeleteBankCard( _):
            return "pay/deleteBankcard"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .Upload(url: _):
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .SendSMS(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .VerifySMS(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .Login(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .Upload(let url):
            return url.absoluteString.utf8Encoded
        case .UserInfo(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .FriendList(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetUserByID(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetUserByMobile(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CreateGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ApplyForUser(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .AgreeApplyForUser(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .RefuseApplyForUser(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .InviteList(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteFriend(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeShield(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeStar(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetGroupInfo(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeGroupOwner(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangePortrait(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeNickName(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangePhone(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CheckChatTop(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetChatTop(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelChatTop(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeFriendNickName(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GroupAddBatch(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GroupRemoveBatch(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GroupMemberList(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ChangeGroupNickName(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetMyGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ExitGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetChatTap(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SubmitNotice(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetGroupNotice(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .AddGroupMenager(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteGroupMenager(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetShieldSingle(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelShieldSingle(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetFocus(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelFocus(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetGroupAllBanned(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelGroupAllBanned(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .EditGroupMemberNickName(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetGroupSheild(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelGroupSheild(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetOneGroupUserInfo(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SaveImageForFace(let model):
            return (model.toJSONString()?.utf8Encoded)!
       
        case .DeleteFace(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .AllFaceList(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteMutibleFace(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .AdvertQuery:
            return "plain".utf8Encoded
        case .DownLoad(let url, _):
            return url.utf8Encoded
        case .GetVersion:
            return "{type:\(versionIndex)}".utf8Encoded
        case .HeartBeat(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetOnlineUser(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetChatBackground(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetChatBackground(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetYhjf(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelYhjf(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SaveRevokeMessageRecord(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetLoginTrace(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .QRLogin(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetUserLastOnlineTime(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .FriendListWithFenzu(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ReSort(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .MoveFriendToNewGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .getFriendGroup(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .AddFenzu(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteFenzu(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetConllectionList(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SubmitCollection(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteCollection(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetLastCollection(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetCollectionListBeginWithID(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .RegistAndLogin(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ReportUser(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .LoginWithCheckCode(let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetMyFriendCircle(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetMomentBK(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GiveLike(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .CancelLike(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DoComment(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .ReplyCpmment(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetMomentDetail(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteMomentComment(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteMomentReply(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .DeleteMoment(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SendMoment(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetMomentByUserId(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .SetMomentBK(model: let model):
            return (model.toJSONString()?.utf8Encoded)!
        case .GetUserBalance(model: let model):
            return "未加密数据:\(model.toJSONString() ?? "")\n已加密数据:{\n\"v\":\"\(DCEncrypt.Encoade_AES(strToEncode: model.toJSONString() ?? ""))\"}".utf8Encoded
        case .BankCardList(model: let model):
            return "未加密数据:\(model.toJSONString() ?? "")\n已加密数据:{\n\"v\":\"\(DCEncrypt.Encoade_AES(strToEncode: model.toJSONString() ?? ""))\"}".utf8Encoded
        case .DeleteBankCard(model: let model):
            return "未加密数据:\(model.toJSONString() ?? "")\n已加密数据:{\n\"v\":\"\(DCEncrypt.Encoade_AES(strToEncode: model.toJSONString() ?? ""))\"}".utf8Encoded
        }
    }
    
    var task: Task {
        switch self {
        case .SendSMS(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .VerifySMS(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .Login(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .Upload(let url):
            let multipartData = MultipartFormData(provider: .file(url), name: "file", fileName: "11.png", mimeType: "images/png")
            return .uploadMultipart([multipartData])
        case .UserInfo(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .FriendList(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetUserByID(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetUserByMobile(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CreateGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ApplyForUser(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .AgreeApplyForUser(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .RefuseApplyForUser(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .InviteList(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteFriend(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeShield(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeStar(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetGroupInfo(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeGroupOwner(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangePortrait(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeNickName(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangePhone(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CheckChatTop(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetChatTop(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelChatTop(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeFriendNickName(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GroupAddBatch(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GroupRemoveBatch(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GroupMemberList(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ChangeGroupNickName(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetMyGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ExitGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetChatTap(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SubmitNotice(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetGroupNotice(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .AddGroupMenager(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteGroupMenager(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetShieldSingle(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelShieldSingle(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetFocus(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelFocus(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetGroupAllBanned(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelGroupAllBanned(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .EditGroupMemberNickName(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetGroupSheild(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelGroupSheild(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetOneGroupUserInfo(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SaveImageForFace(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteFace(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .AllFaceList(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteMutibleFace(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .AdvertQuery:
            return .requestPlain
        case .DownLoad( _, let filepath):
            return .downloadDestination({ (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (URL(fileURLWithPath: filepath),.init(arrayLiteral: .removePreviousFile, .createIntermediateDirectories))
            })
        case .GetVersion:
            return .requestParameters(parameters: ["type" : versionIndex], encoding: URLEncoding.queryString)
        case .HeartBeat(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetOnlineUser(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetChatBackground(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetChatBackground(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetYhjf(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelYhjf(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SaveRevokeMessageRecord(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetLoginTrace(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .QRLogin(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetUserLastOnlineTime(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .FriendListWithFenzu(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ReSort(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .MoveFriendToNewGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .getFriendGroup(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .AddFenzu(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteFenzu(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetConllectionList(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SubmitCollection(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteCollection(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetLastCollection(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetCollectionListBeginWithID(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .RegistAndLogin(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ReportUser(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .LoginWithCheckCode(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetMyFriendCircle(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetMomentBK(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GiveLike(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .CancelLike(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DoComment(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .ReplyCpmment(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetMomentDetail(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteMomentComment(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteMomentReply(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .DeleteMoment(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SendMoment(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetMomentByUserId(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .SetMomentBK(model: let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: URLEncoding.queryString)
        case .GetUserBalance(model: let model):
            return .requestParameters(parameters: ["v":String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: model.toJSONString()!))], encoding: URLEncoding.default)
        case .BankCardList(model: let model):
            return .requestParameters(parameters: ["v":String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: model.toJSONString()!))], encoding: URLEncoding.default)
        case .DeleteBankCard(model: let model):
            return .requestParameters(parameters: ["v":String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: model.toJSONString()!))], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .Upload(url: _):
            return nil
        case .DownLoad(_, _):
            return nil
        default:
            let time = BoXinUtil.getTime()
            let sign = ("imToken=\(UserDefaults.standard.string(forKey: "token") ?? "")&key=4cb166efbdf94e69b494c04229a0a15d&timestamp="+time).md5()
            return ["Content-type": "application/json",
                    "Accept-Charset": "utf-8",
                    "deviceinfo":UIDevice.current.model,
                    "version":Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.00",
                    "client":"ios",
                    "imToken":(UserDefaults.standard.string(forKey: "token") ?? ""),
                    "imei":"ios:\(BoXinUtil.getIMEI())",
                "dbrand":UtilTools.deviceModel(),
                "sign":sign,
                "timestamp":time]
        }
    }
    
    
}

extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

