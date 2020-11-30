//
//  GroupSendMessageVc.m
//  boxin
//
//  Created by Sea on 2019/7/20.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "GroupSendMessageVc.h"
#import "SecondaryfunctionVc.h"
#import "Chaangliao-Swift.h"
#import <SDAutoLayout/SDAutoLayout.h>

@interface GroupSendMessageVc ()<EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource>
@property (nonatomic,strong)UIView *BGVIew;

@property (nonatomic,strong)UITextView *NamesTextView;
@property (nonatomic,strong)UILabel *NumberFriendLab;

@end

@implementation GroupSendMessageVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群发";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _BGVIew = [[UIView alloc]init];
    _BGVIew.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_BGVIew];
    _BGVIew.sd_layout
    .topSpaceToView(self.view, 10)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(150)
    .maxWidthIs(self.view.frame.size.height - 50);
//    [_BGVIew setSingleLineAutoResizeWithMaxWidth:(self.view.frame.size.height - 50)];
    
    _NumberFriendLab = [[UILabel alloc]init];
    _NumberFriendLab.textColor = [UIColor lightGrayColor];
    _NumberFriendLab.font = [UIFont systemFontOfSize:14];
//    _NumberFriendLab.textAlignment = NSTextAlignmentRight;
    [_BGVIew addSubview:_NumberFriendLab];
    _NumberFriendLab.sd_layout
    .topSpaceToView(_BGVIew, 8)
    .leftSpaceToView(_BGVIew, 8)
    .widthIs(200)
    .heightIs(20);
    _NamesTextView = [[UITextView alloc]init];
    _NamesTextView.font = [UIFont systemFontOfSize:15];
//    _NamesTextView.showsVerticalScrollIndicator = NO;
    _NamesTextView.editable =NO;
    [_BGVIew addSubview:_NamesTextView];
    _NamesTextView.sd_layout
    .topSpaceToView(_NumberFriendLab, 10)
    .rightSpaceToView(_BGVIew, 8)
    .leftSpaceToView(_BGVIew, 8)
    .bottomSpaceToView(_BGVIew, 8);
    CGPoint offset = self.NamesTextView.contentOffset;
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            [self.NamesTextView setContentOffset: offset];
    }];
  
    self.NumberFriendLab.text = [NSString stringWithFormat:@"您将发消息给%lu位好友",(unsigned long)self.userIdArr.count];
    self.NamesTextView.text = _nameStr;
    
    // 点击空白处收键盘
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
    
//    EaseChatBarMoreView *chatBarMoreView = [[EaseChatBarMoreView alloc]init];
    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"照片.视频"] highlightedImage:[UIImage imageNamed:@"照片.视频"] title:@"相册" atIndex:0];
    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"位置"] highlightedImage:[UIImage imageNamed:@"位置"] title:@"位置" atIndex:1];
    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"摄像头"] highlightedImage:[UIImage imageNamed:@"摄像头"] title:@"拍照" atIndex:2];
//    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"语音聊天"] highlightedImage:[UIImage imageNamed:@"语音聊天"] title:@"语音" atIndex:3];
//    [self.chatBarMoreView updateItemWithImage:[UIImage imageNamed:@"视频聊天"] highlightedImage:[UIImage imageNamed:@"视频聊天"] title:@"视频" atIndex:3];
    [self.chatBarMoreView removeItematIndex:4];
    [self.chatBarMoreView removeItematIndex:3];
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"文件"] highlightedImage:[UIImage imageNamed:@"文件"] title:@"文件"];
    self.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEmojiChanged) name:@"onEmojiChanged" object:nil];

}
- (void)sendMessage:(EMMessage *)message isNeedUploadFile:(BOOL)isUploadFile
{
    if (message.ext) {
        if ([[message.ext objectForKey:@"NoSend"] isEqualToString:@"1"]) {
            return;
        }
    }
    
    if (message.body.type == EMMessageBodyTypeText) {
        if (message.ext) {
            if ([[message.ext objectForKey:@"jpzim_is_big_expression"] isEqualToString:@"1"]) {
                message.body = [[EMTextMessageBody alloc] initWithText:@"[自定义表情]"];
                [self sendMessageWithBody:message.body withEMmessage:message.ext];
                return;
            }
        }
        EMTextMessageBody *b1 =(EMTextMessageBody *)message.body;
        EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:[NSString stringWithFormat:@"%@_encode",[DCEncrypt Encoade_AESWithStrToEncode:b1.text]]];
        [self sendMessageWithBody:body withEMmessage:message.ext];
        return;
    }
    [self sendMessageWithBody:message.body withEMmessage:message.ext];
}
#pragma mark --收起键盘
// 滑动空白处隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

// 点击空白处收键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}
-(void)textViewDidChange:(EaseTextView *)textView
{
//    if ([textView.text isEqualToString:@"add_DIY"]) {
//        [self.chatToolbar endEditing:YES];
//        textView.text = @"";
//        DIYFaceViewController* vc = [[DIYFaceViewController alloc] init];
//        self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}
//
//- (NSArray *)emotionFormessageViewController:(EaseMessageViewController *)viewController {
//    NSMutableArray* defultface = [NSMutableArray array];
//    NSDictionary* faceDB = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotionDB" ofType:@"plist"]];
//    for (NSString* key in faceDB.allKeys) {
//        EaseEmotion* emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:[faceDB objectForKey:key] emotionThumbnail:[faceDB objectForKey:key] emotionOriginal:[faceDB objectForKey:key] emotionOriginalURL:@"" emotionType:EMEmotionDefault];
//        [defultface addObject:emotion];
//    }
//    EaseEmotionManager* defualtMenager = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[NSArray arrayWithArray:defultface]];
//    NSMutableArray* gifFace = [NSMutableArray array];
//    EaseEmotion* add = [[EaseEmotion alloc] initWithName:@"" emotionId:@"add_DIY" emotionThumbnail:@"添加Face" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionPng];
//    [gifFace addObject:add];
//    NSArray* dbFace = [BoXinUtil GetFace];
//    for (FaceViewModel* model in dbFace) {
//        [gifFace addObject:[[EaseEmotion alloc] initWithName:@"" emotionId:@"[自定义表情]" emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:model.url emotionType:EMEmotionGif]];
//    }
//    EaseEmotionManager* gifMenager = [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:5 emotions:gifFace tagImage:[UIImage imageNamed:@"心"]];
//    return [NSArray arrayWithObjects:defualtMenager,gifMenager, nil];
//}
//
//- (NSDictionary *)emotionExtFormessageViewController:(EaseMessageViewController *)viewController easeEmotion:(EaseEmotion *)easeEmotion {
//    if ([easeEmotion.emotionId isEqualToString:@"add_DIY"]) {
//        return @{@"NoSend":@"1"};
//    }
//    if ([easeEmotion.emotionId isEqualToString:@"[自定义表情]"]) {
//        return @{@"jpzim_is_big_expression":@(true),MESSAGE_ATTR_IS_BIG_EXPRESSION:@(true),@"jpzim_big_expression_path":easeEmotion.emotionOriginalURL};
//    }
//    return [NSDictionary dictionary];
//}
//
//- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController messageModel:(id<IMessageModel>)messageModel{
//    if (messageModel.bodyType == EMMessageBodyTypeText && messageModel.message.ext) {
//        if ([messageModel.message.ext objectForKey:@"jpzim_is_big_expression"]) {
//            return true;
//        }
//    }
//    return false;
//}
//
//- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
//                                      messageModel:(id<IMessageModel>)messageModel{
//    return [[EaseEmotion alloc] initWithName:@"" emotionId:@"" emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:[messageModel.message.ext objectForKey:@"jpzim_big_expression_path"] emotionType:EMEmotionGif];
//}
                 
 -(void)sendMessageWithBody:(EMTextMessageBody *)body withEMmessage:(NSDictionary *)ext
 {
     
     for (int i = 0; i < self.userIdArr.count; i ++) {
         [SVProgressHUD show];
//         NSString *messageStr = _SendMessageTextField.text;
 
//         EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:messageStr];
         NSString *from = [[EMClient sharedClient] currentUsername];
 
         //生成Message
         EMMessage *message = [[EMMessage alloc] initWithConversationID:self.userIdArr[i] from:from to:self.userIdArr[i] body:body ext:ext];
         message.chatType = EMChatTypeChat;// 设置为单聊消息
         [EMClient.sharedClient.chatManager sendMessage:message progress:^(int progress) {
 
         } completion:^(EMMessage *message, EMError *error) {
 
             if (error == nil)
             {
                 NSLog(@"成功%@",self.userIdArr[i]);
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMessage" object:nil];
             }else
             {
                 NSLog(@"%@",error.errorDescription);
             }
         }];
 
 
         if (i == self.userIdArr.count - 1) {
 
             [SVProgressHUD dismiss];
             [self.navigationController popToRootViewControllerAnimated:YES];
 
         }
 
     }
 
 }

- (void)sendImageMessage:(UIImage *)image {
    UIGraphicsBeginImageContext(CGSizeMake(800, image.size.height / image.size.width * 800));
    [image drawInRect:CGRectMake(0, 0, 800, image.size.height / image.size.width * 800)];
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [super sendImageMessage:resultImage];
}

-(void) onEmojiChanged {
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.dataSource = self;
    });
}

@end
