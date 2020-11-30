//
//  DIYCustomLabel.m
//  boxin
//
//  Created by guduzhonglao on 10/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "DIYCustomLabel.h"

@implementation DIYCustomLabel

- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:rect];
}

@end
