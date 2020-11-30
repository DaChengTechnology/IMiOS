/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */


#import "EaseFaceView.h"

#import "EaseEmotionManager.h"
#import "EaseLocalDefine.h"

#define kButtomNum 5

@interface EaseFaceView ()
{
    UIScrollView *_bottomScrollView;
    NSInteger _currentSelectIndex;
    NSArray *_emotionManagers;
    UIButton *Facebutton;
    UIButton *sendButton;
}
@property (nonatomic, strong) UIView *emotionBgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *emotionButtons;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic) CGFloat bottomHeight;
@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, strong) EaseFacialView *facialView;

@end

@implementation EaseFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.facialView];
        [self _setupButtom];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadEmotionData];
    }
}

#pragma mark - private

- (EaseFacialView*)facialView
{
    if (_facialView == nil) {
        _facialView = [[EaseFacialView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 140)];
        _facialView.delegate = self;
    }
    return _facialView;
}

- (void)_setupButtom
{

//    _currentSelectIndex = 1000;
//    _bottomScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(_facialView.frame), 4 * CGRectGetWidth(_facialView.frame)/5, self.frame.size.height - CGRectGetHeight(_facialView.frame))];
//    _bottomScrollView.showsHorizontalScrollIndicator = NO;
//    [self addSubview:_bottomScrollView];
//    [self _setupButtonScrollView];
//
//    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    sendButton.frame = CGRectMake((kButtomNum-1)*CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetMaxY(_facialView.frame), CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetHeight(_bottomScrollView.frame));
//    [sendButton setBackgroundColor:[UIColor colorWithRed:30 / 255.0 green:167 / 255.0 blue:252 / 255.0 alpha:1.0]];
//    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
//    [sendButton addTarget:self action:@selector(sendFace) forControlEvents:UIControlEventTouchUpInside];
    
//    for (int i = 1;i < 3 ; i ++) {
//
//        Facebutton = [[UIButton alloc]init];
//        Facebutton.tag =  i +1000 ;
//        Facebutton.frame = CGRectMake( (i-1)*CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetMaxY(_facialView.frame), CGRectGetWidth(_facialView.frame)/kButtomNum -2, CGRectGetHeight(_bottomScrollView.frame));
//        [Facebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self addSubview:Facebutton];
//        NSArray *ImageArr = @[@"Face",@"心"];
//        [Facebutton setImage:[UIImage imageNamed:ImageArr[i - 1]] forState:UIControlStateNormal];
//        [Facebutton addTarget:self action:@selector(ChangeFaceView:) forControlEvents:UIControlEventTouchUpInside];
//
//    }
   
    
    _currentSelectIndex = 1000;
    
    _bottomScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(_facialView.frame), 4 * CGRectGetWidth(_facialView.frame)/5, self.frame.size.height - CGRectGetHeight(_facialView.frame))];
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bottomScrollView];
    [self _setupButtonScrollView];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake((kButtomNum-1)*CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetMaxY(_facialView.frame), CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetHeight(_bottomScrollView.frame));
    [sendButton setBackgroundColor:[UIColor colorWithRed:30 / 255.0 green:167 / 255.0 blue:252 / 255.0 alpha:1.0]];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendFace) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    
    
}
- (void)ChangeFaceView:(UIButton *)aButton
{
    if (aButton.tag == 1001 && aButton.isSelected == NO) {
        [Facebutton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    
    NSInteger tag = aButton.tag;
    
    if (self.selectedButton && self.selectedButton.tag == tag) {
        
        return;
    }
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.selectedButton = nil;
    }
    
    aButton.selected = YES;
    aButton.backgroundColor = [UIColor whiteColor];
    self.selectedButton = aButton;
    
    if (tag == 1001) {
        [self addSubview:sendButton];
        

    } else {
        [sendButton removeFromSuperview];

    }
}
- (void)_setupButtonScrollView
{
    NSInteger number = [_emotionManagers count];
    if (number <= 1) {
        return;
    }
    
    for (UIView *view in [_bottomScrollView subviews]) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < number; i++) {
        UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        defaultButton.frame = CGRectMake(i * CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), 0, CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), CGRectGetHeight(_bottomScrollView.frame));
        EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:i];
        if (emotionManager.emotionType == EMEmotionDefault) {
            EaseEmotion *emotion = [emotionManager.emotions objectAtIndex:0];
            [defaultButton setTitle:emotion.emotionOriginal forState:UIControlStateNormal];
            
        } else {
            [defaultButton setImage:emotionManager.tagImage forState:UIControlStateNormal];
            [defaultButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            defaultButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        [defaultButton setBackgroundColor:[UIColor clearColor]];
        defaultButton.layer.borderWidth = 0.5;
        defaultButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [defaultButton addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
        defaultButton.tag = 1000 + i;
        [_bottomScrollView addSubview:defaultButton];
    }
    [_bottomScrollView setContentSize:CGSizeMake(number*CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), CGRectGetHeight(_bottomScrollView.frame))];
    
    [self reloadEmotionData];
}

- (void)_clearupButtomScrollView
{
    for (UIView *view in [_bottomScrollView subviews]) {
        [view removeFromSuperview];
    }
}

#pragma mark - action

- (void)didSelect:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    UIButton *lastBtn = (UIButton*)[_bottomScrollView viewWithTag:_currentSelectIndex];
    lastBtn.selected = NO;
    
    _currentSelectIndex = btn.tag;
    btn.selected = YES;
    NSInteger index = btn.tag - 1000;
    [_facialView loadFacialViewWithPage:index];
}

- (void)reloadEmotionData
{
    NSInteger index = _currentSelectIndex - 1000;
    if (index < [_emotionManagers count]) {
        [_facialView loadFacialView:_emotionManagers size:CGSizeMake(30, 30)];
    }
}

#pragma mark - FacialViewDelegate

-(void)selectedFacialView:(NSString*)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:NO];
    }
}

-(void)deleteSelected:(NSString *)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:YES];
    }
}

- (void)sendFace
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

- (void)sendFace:(EaseEmotion *)emotion
{
    if (_delegate) {
        [_delegate sendFaceWithEmotion:emotion];
    }
}

#pragma mark - public

- (BOOL)stringIsFace:(NSString *)string
{
    if ([_facialView.faces containsObject:string]) {
        return YES;
    }
    
    return NO;
}

- (void)setEmotionManagers:(NSArray *)emotionManagers
{
    _emotionManagers = emotionManagers;
    for (EaseEmotionManager *emotionManager in _emotionManagers) {
        if (emotionManager.emotionType != EMEmotionGif) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:emotionManager.emotions];
            NSInteger maxRow = emotionManager.emotionRow;
            NSInteger maxCol = emotionManager.emotionCol;
            NSInteger count = 1;
            while (1) {
                NSInteger index = maxRow * maxCol * count - 1;
                if (index >= [array count]) {
                    [array addObject:@""];
                    break;
                } else {
                    [array insertObject:@"" atIndex:index];
                }
                count++;
            }
            emotionManager.emotions = array;
        }
    }
    [self _setupButtonScrollView];
}


@end
