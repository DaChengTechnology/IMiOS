//
//  EaseBubbleView+IDCard.h
//  HappyChat
//
//  Created by Stn on 2019/9/13.
//  Copyright © 2019 onlysea. All rights reserved.
//

#import "EaseBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseBubbleView (IDCard)
-(void)setupIDCardBubbleView;
-(void)updateIDCardMargin:(UIEdgeInsets)margin;
-(void)setIDCardReciveBubbleView;
-(void)setIDCardBubbleView;
@end

NS_ASSUME_NONNULL_END
