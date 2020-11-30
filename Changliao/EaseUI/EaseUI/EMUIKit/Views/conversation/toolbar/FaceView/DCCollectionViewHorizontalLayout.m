//
//  BCCollectionViewHorizontalLayout.m
//  Sanjieyou
//
//  Created by 王佳敏 on 2018/4/11.
//  Copyright © 2018年 王佳敏. All rights reserved.
//

#import "DCCollectionViewHorizontalLayout.h"
@implementation DCCollectionViewHorizontalLayout
@synthesize allEmotion;
- (void)prepareLayout
{
    [super prepareLayout];
    self.allAttributes = [NSMutableArray array];
    for (int i = 0; i<[self.collectionView numberOfSections]; i++) {
        NSUInteger count = [self.collectionView numberOfItemsInSection:i];
        for (NSUInteger j = 0; j<count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.allAttributes addObject:attributes];
        }
    }
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger x;
    NSUInteger y;
    [self targetPositionResultX:&x resultY:&y index:indexPath];
    NSUInteger item2 = [self originItemAtX:x y:y index:indexPath];
    NSIndexPath *theNewIndexPath = [NSIndexPath indexPathForItem:item2 inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *theNewAttr = [super layoutAttributesForItemAtIndexPath:theNewIndexPath];
    theNewAttr.indexPath = indexPath;
    return theNewAttr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        for (UICollectionViewLayoutAttributes *attr2 in self.allAttributes) {
            if (attr.indexPath.item == attr2.indexPath.item && attr.indexPath.section == attr2.indexPath.section) {
                [tmp addObject:attr2];
                break;
            }
        }
    }
    return tmp;
}

// 根据 item 计算目标item的位置
// x 横向偏移  y 竖向偏移
- (void)targetPositionResultX:(NSUInteger *)x
                       resultY:(NSUInteger *)y index:(NSIndexPath*) index
{
    EaseEmotionManager* m = [allEmotion objectAtIndex:index.section];
    NSUInteger page = index.item/(m.emotionCol*m.emotionRow);
    
    NSUInteger theX = index.item % m.emotionCol + page * m.emotionCol;
    NSUInteger theY = index.item / m.emotionCol - page * m.emotionRow;
    if (x != NULL) {
        *x = theX;
    }
    if (y != NULL) {
        *y = theY;
    }
}

// 根据偏移量计算item
- (NSUInteger)originItemAtX:(NSUInteger)x
                          y:(NSUInteger)y index:(NSIndexPath*)index
{
    EaseEmotionManager* m = [allEmotion objectAtIndex:index.section];
    NSUInteger item = x * m.emotionRow + y;
    return item;
}

@end
