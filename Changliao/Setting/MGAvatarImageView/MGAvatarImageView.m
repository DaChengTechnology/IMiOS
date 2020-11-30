//
//  MGAvatarImageView.m
//  MGAvatarImageView
//
//  Created by mango on 2017/6/15.
//  Copyright © 2017年 mango. All rights reserved.
//

#import "MGAvatarImageView.h"
#import "UIImagePickerController+MGStatusBar.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <TOCropViewController/TOCropViewController.h>

@interface MGAvatarImageView()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate,TOCropViewControllerDelegate>
@property (strong , nonatomic) UIImagePickerController *imagePickerVC;
@property (strong , nonatomic) UITapGestureRecognizer *singleTap;
@property(nonatomic, weak)UIViewController *sourceViewController;
@end
@implementation MGAvatarImageView

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_showSheetView)];
        [self addGestureRecognizer:tap];
        [self setNavItemColor:[UIColor blackColor]];
    }
    return self;
}

#pragma mark - accessor
- (UIViewController *)sourceViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)setNavItemColor:(UIColor *)navItemColor {
    _navItemColor = navItemColor;
    UIBarButtonItem *appearance;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    appearance = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    appearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
#endif
    //设置所有导航条上item的textColor
    NSDictionary *dictNormal = @{
                                 NSForegroundColorAttributeName : _navItemColor,
                                 };
    [appearance setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
}

- (UIColor *)navImageColor {
    return _navImageColor ?: [UIColor blackColor];
}

- (UIColor *)navBarBackgroundColor {
    return _navBarBackgroundColor ?: [UIColor whiteColor];
}

- (UIColor *)sheetTitleColor {
    return _sheetTitleColor ?: [UIColor blackColor];
}

#pragma mark - public method
- (void)show {
    [self p_showSheetView];
}

#pragma mark - private method
- (void)p_showSheetView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    choiceSheet.delegate = self;
    [choiceSheet showInView:self.sourceViewController.view];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    alert.view.tintColor = self.sheetTitleColor;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:NULL]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self p_cameraAuthorizationCheck];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self p_openPhotoLibrary];
    }]];
    alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.sourceViewController presentViewController:alert animated:YES completion:nil];
#endif
}

- (void)p_cameraAuthorizationCheck {
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        NSString *mediaType = AVMediaTypeVideo;
        //读取设备授权状态
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (status == AVAuthorizationStatusRestricted) { // 因为家长控制, 导致应用无法方法相机(跟用户的选择没有关系)
            [self p_showErrorMessage:@"家长控制权限限制使用该功能"];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            [self p_showErrorMessage:[NSString stringWithFormat:@"请去-> [设置 - 隐私 - 相机 - %@ 打开访问开关", appName]];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            [self p_openCamera];
        } else if (status == AVAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self p_openCamera];
                    });
                }
            }];
           
        }
    } else {
        [self p_showErrorMessage:@"该设备没有相机"];
    }
}

- (void)p_openCamera {
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront||UIImagePickerControllerCameraDeviceRear]) {
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerImage.delegate = self;
        pickerImage.allowsEditing = NO;
        pickerImage.navigationBar.tintColor = self.navImageColor;
        pickerImage.navigationBar.barTintColor = self.navBarBackgroundColor;
        pickerImage.mg_statusBarStyle = self.statusBarStyle;
        pickerImage.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.sourceViewController presentViewController:pickerImage animated:YES completion:^{}];
    }
}

- (void)p_openPhotoLibrary {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self p_showErrorMessage:@"该设备没有相册"];
        return;
    }
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerImage.mediaTypes = [NSArray arrayWithObjects: @"public.image", nil];
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    pickerImage.navigationBar.tintColor = self.navImageColor;
    pickerImage.navigationBar.barTintColor = self.navBarBackgroundColor;
    pickerImage.mg_statusBarStyle = self.statusBarStyle;
    pickerImage.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.sourceViewController presentViewController:pickerImage animated:YES completion:^{}];
}

- (void)p_showErrorMessage:(NSString *)message {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
    [alert show];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                          handler:NULL];
    [alert addAction:defaultAction];
    alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.sourceViewController presentViewController:alert animated:YES completion:nil];
#endif
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            //拍照
            [self p_cameraAuthorizationCheck];
            break;
        case 1:
            //相册
            [self p_openPhotoLibrary];
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    //在高版本中，actionSheet.subviews为空数组对象，苹果限制了，运行在低版本的机子上没问题
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subView;
            label.textColor = self.sheetTitleColor;
        }
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
            [button setTitleColor:self.sheetTitleColor forState:UIControlStateNormal];
        }
    }
}
#endif

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.image = image;
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:image];
            cropController.delegate = self;

            // Uncomment this if you wish to provide extra instructions via a title label
            //cropController.title = @"Crop Image";

            // -- Uncomment these if you want to test out restoring to a previous crop setting --
            //cropController.angle = 90; // The initial angle in which the image will be rotated
            //cropController.imageCropFrame = CGRectMake(0,0,2848,4288); //The initial frame that the crop controller will have visible.
            
            // -- Uncomment the following lines of code to test out the aspect ratio features --
            cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare; //Set the initial aspect ratio as a square
            cropController.aspectRatioLockEnabled = YES; // The crop box is locked to the aspect ratio and can't be resized away from it
            cropController.resetAspectRatioEnabled = NO; // When tapping 'reset', the aspect ratio will NOT be reset back to default
            //cropController.aspectRatioPickerButtonHidden = YES;

            // -- Uncomment this line of code to place the toolbar at the top of the view controller --
            //cropController.toolbarPosition = TOCropViewControllerToolbarPositionTop;
            
            // -- Uncomment this line of code to include only certain type of preset ratios
        //    cropController.allowedAspectRatios = @[@(TOCropViewControllerAspectRatioPresetSquare)];
            

            //cropController.rotateButtonsHidden = YES;
            //cropController.rotateClockwiseButtonHidden = NO;
            
            cropController.doneButtonTitle = @"选取";
            cropController.cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel");

            // -- Uncomment this line of code to show a confirmation dialog when cancelling --
            //cropController.showCancelConfirmationDialog = YES;

            // Uncomment this if you wish to always show grid
            //cropController.cropView.alwaysShowCroppingGrid = YES;

            // Uncomment this if you do not want translucency effect
            //cropController.cropView.translucencyAlwaysHidden = YES;
            
            //If profile picture, push onto the same navigation stack
            [self.sourceViewController presentViewController:cropController animated:YES completion:^(){
            //                [cropController setAspectRatioPreset:TOCropViewControllerAspectRatioPresetSquare animated:NO];
                        }];
    }];
}

-(UIImage *)resizeImage:(UIImage *)image width:(int)wdth height:(int)hght{
    int w = image.size.width;
    int h = image.size.height;
    CGImageRef imageRef = [image CGImage];
    int width, height;
    int destWidth = wdth;
    int destHeight = hght;
    if(w > h){
        width = destWidth;
        height = h*destWidth/w;
    }
    else {
        height = destHeight;
        width = w*destHeight/h;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap;
    bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);

    if (image.imageOrientation == UIImageOrientationLeft) {

        CGContextRotateCTM (bitmap, M_PI/2);
        CGContextTranslateCTM (bitmap, 0, -height);

    } else if (image.imageOrientation == UIImageOrientationRight) {

        CGContextRotateCTM (bitmap, -M_PI/2);
        CGContextTranslateCTM (bitmap, -width, 0);

    }
    else if (image.imageOrientation == UIImageOrientationUp) {

    } else if (image.imageOrientation == UIImageOrientationDown) {

        CGContextTranslateCTM (bitmap, width,height);
        CGContextRotateCTM (bitmap, -M_PI);
    }

    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return result;

}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}


- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    self.image = image;
    if ([self.delegate respondsToSelector:@selector(imageView:didSelectImage:)]) {
        [self.delegate imageView:self didSelectImage:image];
    }
}
@end
