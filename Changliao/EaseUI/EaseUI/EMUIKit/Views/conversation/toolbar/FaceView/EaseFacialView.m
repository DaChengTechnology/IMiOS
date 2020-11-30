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


#import "EaseFacialView.h"
#import "EaseEmoji.h"
#import "EaseFaceView.h"
#import "EaseEmotionManager.h"
#import "UIButton+WebCache.h"
#import <SDImageCache.h>
#import "DCCollectionViewHorizontalLayout.h"
#import <UIImage+GIF.h>

@interface UIButton (UIButtonImageWithLable)
- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType;
@end

@implementation UIButton (UIButtonImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    CGSize titleSize;
    if ([NSString instancesRespondToSelector:@selector(sizeWithAttributes:)]) {
        titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    } else {
        titleSize = [title sizeWithFont:[UIFont systemFontOfSize:10]];
    }
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0,
                                              0.0,
                                              20,
                                              0)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [self setTitleColor:[UIColor blackColor] forState:stateType];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(CGRectGetHeight(self.bounds)-20,
                                              -image.size.width,
                                              0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end

@protocol EaseCollectionViewCellDelegate

@optional

- (void)didSendEmotion:(EaseEmotion*)emotion;

@end

@interface EaseCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<EaseCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) EaseEmotion *emotion;

@end

@implementation EaseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageButton.frame = self.bounds;
        _imageButton.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageButton];
    }
    return self;
}

//- (void)prepareForReuse {
//    [self.imageButton sd_cancelImageLoadForState:UIControlStateNormal];
//    [super prepareForReuse];
//}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageButton.frame = self.bounds;
}

- (void)setEmotion:(EaseEmotion *)emotion
{
    _emotion = emotion;
    if ([emotion isKindOfClass:[EaseEmotion class]]) {
        if (emotion.emotionType == EMEmotionGif) {
            NSLog(@"GIF");
            SDWebImageManager* m = [SDWebImageManager sharedManager];
            UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[m cacheKeyForURL:[NSURL URLWithString:emotion.emotionOriginalURL]]];
            if (image) {
                [_imageButton setImage:image forState:UIControlStateNormal];
            }else{
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[m cacheKeyForURL:[NSURL URLWithString:emotion.emotionOriginalURL]]];
                if (image) {
                    [_imageButton setImage:image forState:UIControlStateNormal];
                }else{
                    [_imageButton sd_setImageWithURL:[NSURL URLWithString:emotion.emotionOriginalURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadding_face"] options:SDWebImageRetryFailed];
                }
            }
            _imageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [_imageButton setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        } else if (emotion.emotionType == EMEmotionPng) {
            [_imageButton setImage:[UIImage imageNamed:emotion.emotionThumbnail] forState:UIControlStateNormal];
            _imageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [_imageButton setTitle:nil forState:UIControlStateNormal];
            [_imageButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [_imageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        } else {
            [_imageButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:23.0]];
            [_imageButton setTitle:emotion.emotionOriginal forState:UIControlStateNormal];
            [_imageButton setImage:nil forState:UIControlStateNormal];
            [_imageButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [_imageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        [_imageButton addTarget:self action:@selector(sendEmotion:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_imageButton setTitle:nil forState:UIControlStateNormal];
        [_imageButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_imageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_imageButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/faceDelete"] forState:UIControlStateNormal];
        [_imageButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/faceDelete_select"] forState:UIControlStateHighlighted];
        [_imageButton addTarget:self action:@selector(sendEmotion:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)sendEmotion:(id)sender
{
    if (_delegate) {
        if ([_emotion isKindOfClass:[EaseEmotion class]]) {
            [_delegate didSendEmotion:_emotion];
        } else {
            [_delegate didSendEmotion:nil];
        }
    }
}

@end

@interface CollectionCell : UICollectionViewCell

@end

@implementation CollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end


@interface EaseFacialView () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,EaseCollectionViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    CGFloat _itemWidth;
    CGFloat _itemHeight;
}
@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *emotionManagers;

@end

@implementation EaseFacialView
- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
    }
    return _picker;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageControl = [[UIPageControl alloc] init];
        DCCollectionViewHorizontalLayout *flowLayout = [[DCCollectionViewHorizontalLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        [self.collectionView registerClass:[EaseCollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
        [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"Cell"];
//        _collectionView.contentInset = UIEdgeInsetsMake(0, -50, 0, 0);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.userInteractionEnabled = YES;
//        [self addSubview:_scrollview];
        [self addSubview:_pageControl];
        [self addSubview:_collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section < [_emotionManagers count]) {
        EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:section];
        NSInteger count = [emotionManager.emotions count];
        while (count % (emotionManager.emotionCol * emotionManager.emotionRow) != 0) {
            ++ count;
        }
        return count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_emotionManagers == nil || [_emotionManagers count] == 0) {
        return 1;
    }
    return [_emotionManagers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"collectionCell";
    EaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (!cell) {
        
    }
    
    [cell sizeToFit];
    EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:indexPath.section];
    if (indexPath.row >= [emotionManager.emotions count]) {
        CollectionCell* nomalCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        return nomalCell;
    }
    EaseEmotion *emotion = [emotionManager.emotions objectAtIndex:indexPath.row];
    cell.emotion = emotion;
    cell.delegate = self;
    cell.userInteractionEnabled = YES;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
//    EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:section];
//    CGFloat itemWidth = self.frame.size.width / emotionManager.emotionCol;
//    NSInteger pageSize = emotionManager.emotionRow*emotionManager.emotionCol;
//    NSInteger lastPage = (pageSize - [emotionManager.emotions count]%pageSize);
//    if (lastPage < emotionManager.emotionRow ||[emotionManager.emotions count]%pageSize == 0) {
//        return CGSizeMake(0, 0);
//    } else{
//        NSInteger size = lastPage/emotionManager.emotionRow;
//        return CGSizeMake(size*itemWidth, self.frame.size.height);
//    }
    return CGSizeMake(0, 0);
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:indexPath.section];
    NSInteger maxRow = emotionManager.emotionRow;
    NSInteger maxCol = emotionManager.emotionCol;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = (self.frame.size.height) / maxRow;
//#pragma mark smallpngface
//    float width = (CGRectGetWidth(self.frame)-10*2-(emotionManager.emotionCol-1)*15)/emotionManager.emotionCol;
//    if (emotionManager.emotionType == EMEmotionPng) {
//        return CGSizeMake(width,width);
//    }
    return CGSizeMake(itemWidth, itemHeight);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:section];
//    if (emotionManager.emotionType == EMEmotionPng) {
//        return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
//    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    #pragma mark smallpngface
//    EaseEmotionManager *emotionManager = [_emotionManagers objectAtIndex:section];
//    if (emotionManager.emotionType == EMEmotionPng) {
//        return 15.f;
//    }
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma makr - EaseCollectionViewCellDelegate
//if判断里面加了png格式的发送
#pragma mark smallpngface
- (void)didSendEmotion:(EaseEmotion *)emotion
{
    if (emotion) {
        if (emotion.emotionType == EMEmotionDefault || emotion.emotionType == EMEmotionPng) {
            if (_delegate) {
                [_delegate selectedFacialView:emotion.emotionId];
            }
        } else {
            if (_delegate) {
                    [_delegate sendFace:emotion];
            }
        }
    } else {
        [_delegate deleteSelected:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //    获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    self.image.image = image;
    //    获取图片后返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//按取消按钮时候的功能
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)loadFacialView:(NSArray*)emotionManagers size:(CGSize)size
{
    for (UIView *view in [self.scrollview subviews]) {
        [view removeFromSuperview];
    }
    DCCollectionViewHorizontalLayout* layout = (DCCollectionViewHorizontalLayout*)_collectionView.collectionViewLayout;
    layout.allEmotion = emotionManagers;
    _collectionView.collectionViewLayout = layout;
    _emotionManagers = emotionManagers;
    [_collectionView reloadData];
}

-(void)loadFacialViewWithPage:(NSInteger)page
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:page]
                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                    animated:NO];
    CGPoint offSet = _collectionView.contentOffset;
    if (page == 0) {
        [_collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    } else {
        [_collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*((int)(offSet.x/CGRectGetWidth(self.frame))+1), 0) animated:NO];
    }
//    [_collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*2, 0) animated:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x > self.frame.size.width *5) {
        NSArray<NSIndexPath*>* arr = [_collectionView indexPathsForVisibleItems];
        [_collectionView reloadItemsAtIndexPaths:arr];
    }
}

@end
