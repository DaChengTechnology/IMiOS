//
//  QQMIaoBianLab.m
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "QQMIaoBianLab.h"
#import "Public.h"
@implementation QQMIaoBianLab
- (void)drawTextInRect:(CGRect)rect

{
    
    //描边
    
    CGContextRef c = UIGraphicsGetCurrentContext ();
    
    CGContextSetLineWidth (c, 10);
    
    CGContextSetLineJoin (c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode (c, kCGTextStroke);
    
    //描边颜色
    
    self.textColor = kColorFromRGBHex(0xfc5136);
    
    [super drawTextInRect:rect];
    
    //文字颜色
    
    self.textColor = UIColor.whiteColor;
    
    CGContextSetTextDrawingMode (c, kCGTextFill);
    
    [super drawTextInRect:rect];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
