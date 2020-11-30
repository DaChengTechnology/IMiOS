//
//  LongTapFunction.m
//  boxin
//
//  Created by Sea on 2019/7/11.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "LongTapFunction.h"

@implementation LongTapFunction

-(void)setLongTapWithImage:(UIImage *)image
{
    UITapGestureRecognizer *tap =   [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapCliclk:)];
    
    UILongPressGestureRecognizer*longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imglongTapClick:)];
    _sentImg.image = image;
    
}

-(void)imglongTapClick:(UILongPressGestureRecognizer*)gesture

{
    
    if(gesture.state==UIGestureRecognizerStateBegan)
        
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"保存图片"delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")destructiveButtonTitle:nil otherButtonTitles:@"保存图片到手机",nil];
        
        actionSheet.actionSheetStyle=UIActionSheetStyleBlackOpaque;
        
        [actionSheet showInView:self];
        
        UIImageView *img = (UIImageView*)[gesture view];
        
        _sentImg= img;
        
    }
    
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:  (NSInteger)buttonIndex

{
    
    if(buttonIndex ==0) {
        UIImageWriteToSavedPhotosAlbum(_sentImg.image,self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),nil);
        
    }
    
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(void*)contextInfo

{
    
    NSString*message =@"呵呵";
    
    if(!error) {
        
        message =@"成功保存到相册";
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK")otherButtonTitles:nil];
        
        [alert show];
        
    }else
        
    {
        
        message = [error description];
        
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提    示"message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK")otherButtonTitles:nil];
        
        [alert show];
        
    }
    
}



@end
