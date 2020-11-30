//
//  ZZQAvatarPicker.m
//  ZZQAvatarPicker
//
//  Created by 郑志强 on 2018/10/31.
//  Copyright © 2018 郑志强. All rights reserved.
//

#import "ZZQAvatarPicker.h"
#import "ZZQResourceSheetView.h"
#import "ZZQAuthorizationManager.h"
#import <TOCropViewController/TOCropViewController.h>

typedef void(^seletedImage)(UIImage *image);

@interface ZZQAvatarPicker ()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
ZZQResouceSheetViewDelegate,TOCropViewControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) ZZQResourceSheetView *toolView;

@property (nonatomic, copy) seletedImage selectedImage;

@end

@implementation ZZQAvatarPicker

+ (void)startSelected:(void(^)(UIImage *image))compleiton {
      [[self new] startSelected:^(UIImage * _Nullable image) {
        compleiton(image);
    }];
}


- (void)startSelected:(void (^)(UIImage * _Nullable))compleiton {
    [self.toolView show];
    self.selectedImage = compleiton;
}


#pragma mark - <ZZQResouceSheetViewDelegate>

- (void)ZZQResourceSheetView:(ZZQResourceSheetView *)sheetView seletedMode:(ResourceMode)resourceMode {
    
    if (resourceMode == ResourceModeNone) {
        self.selectedImage ? self.selectedImage(nil) : nil;
        [self clean];
        return;
    }
    
    if (resourceMode == ResourceModeAlbum) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        __weak typeof(self) weakSelf = self;
        [ZZQAuthorizationManager checkPhotoLibraryAuthorization:^(BOOL isPermission) {
            if (isPermission) {
                [weakSelf presentToImagePicker];
            } else {
                [ZZQAuthorizationManager requestPhotoLibraryAuthorization];
            }
        }];
  
    } else if (resourceMode == ResourceModeCamera) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        __weak typeof(self) weakSelf = self;
        [ZZQAuthorizationManager checkCameraAuthorization:^(BOOL isPermission) {
            if (isPermission) {
                [weakSelf presentToImagePicker];
            } else {
                [ZZQAuthorizationManager requestCameraAuthorization];
            }
        }];
    }
}


- (void)presentToImagePicker {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        self.imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootVC presentViewController:self.imagePicker animated:YES completion:nil];
    });
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.onlyPic) {
            self.selectedImage ? self.selectedImage(image) : nil;
            [self clean];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
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
                UIViewController *rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
                    [rootVC presentViewController:cropController animated:YES completion:^(){
                    //                [cropController setAspectRatioPreset:TOCropViewControllerAspectRatioPresetSquare animated:NO];
                                }];
            });
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.selectedImage ? self.selectedImage(nil) : nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self clean];
    }];
}


- (void)clean {
    self.toolView.delegate = nil;
    self.toolView = nil;
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
     self.selectedImage ? self.selectedImage(image) : nil;
    [self clean];
}


#pragma mark - getter

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
    }
    return _imagePicker;
}


- (ZZQResourceSheetView *)toolView {
    if (!_toolView) {
        _toolView = [ZZQResourceSheetView new];
        _toolView.delegate = self;
    }
    return _toolView;
}


- (void)dealloc {
    NSLog(@"picker dealloc");
}

@end
