//
//  PickModel.m
//  boxin
//
//  Created by Sea on 2019/7/15.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "PickModel.h"
@interface PickModel()<UIPickerViewDelegate,UINavigationControllerDelegate>

@end

@implementation PickModel
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //    获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FaceImage" object:image];
    //    获取图片后返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//按取消按钮时候的功能
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
