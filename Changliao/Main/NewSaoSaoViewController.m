//
//  NewSaoSaoViewController.m
//  boxin
//
//  Created by Stn on 2019/8/3.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "NewSaoSaoViewController.h"
#import "WSLScanView.h"
#import "WSLNativeScanTool.h"
#import "Public.h"
#import "ZZQAvatarPicker.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

#define XCenter self.view.center.x
#define YCenter self.view.center.y

#define SHeight 20

#define SWidth (WIDTH - 100)
@interface NewSaoSaoViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong)  WSLNativeScanTool * scanTool;
@property (nonatomic, strong)  WSLScanView * scanView;
@property (strong , nonatomic) UIImagePickerController *imagePickerVC;
@end


@implementation NewSaoSaoViewController
{
    NSTimer *_timer;
    int num;
    BOOL upOrDown;
}

#pragma mark ===========懒加载===========
//device
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        //AVMediaTypeVideo是打开相机
        //AVMediaTypeAudio是打开麦克风
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}
//input
- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}
//output  --- output如果不打开就无法输出扫描得到的信息
// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (!_output || [_output isKindOfClass:NSNull.class]) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //限制扫描区域(上下左右)
        [_output setRectOfInterest:self.view.bounds];
    }
    return _output;
}
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

//session
- (AVCaptureSession *)session
{
    if (_session == nil) {
        //session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.output]) {
            [_session addOutput:self.output];
        }
    }
    return _session;
}
//preview
- (AVCaptureVideoPreviewLayer *)preview
{
    if (_preview == nil) {
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _preview;
}
#pragma mark ==========ViewDidLoad==========
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"扫一扫";
    UIBarButtonItem * item=[[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem=item;
  
     //打开定时器，开始扫描
    [self addTimer];
    
    //界面初始化
    [self interfaceSetup];
    
    //初始化扫描
    [self scanSetup];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //点击alert，开始扫描
    [self.session startRunning];
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
  
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //视图退出，关闭扫描
    [self.session stopRunning];
    //关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
}

//界面初始化
- (void)interfaceSetup
{
    //1 添加扫描框
    [self addImageView];
    
    //添加模糊效果
    [self setOverView];
    //添加开始扫描按钮
    //    [self addStartButton];
    
}

//添加扫描框
- (void)addImageView
{
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH-SWidth)/2, (HEIGHT-SWidth)/2-kNavHeight, SWidth, SWidth)];
    //显示扫描框
    _imageView.image = [UIImage imageNamed:@"scanscanBg"];
    [self.view addSubview:_imageView];
    _line = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5, CGRectGetWidth(_imageView.frame), 3)];
    _line.image = [UIImage imageNamed:@"矩形12"];
    [self.view addSubview:_line];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [lable setText:@"将二维码放入框内，自动识别"];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor whiteColor];
    lable.font = [UIFont systemFontOfSize:14];
    lable.center = CGPointMake(_imageView.center.x , _imageView.center.y+ SWidth/2 + 30);
    [self.view addSubview:lable];
    
}

//初始化扫描配置
- (void)scanSetup
{
    //2 添加预览图层
    self.preview.frame = self.view.bounds;
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //3 设置输出能够解析的数据类型
    //注意:设置数据类型一定要在输出对象添加到回话之后才能设置
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //4 开始扫描
    [self.session startRunning];
    
}



-(void)rightClick{
    //视图退出，关闭扫描
    [self.session stopRunning];
    //关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    
    [self checkPhotoLibary];
//    __weak typeof(self)weakSelf=self;

//    [ZZQAvatarPicker startSelected:^(UIImage * _Nonnull image) {
//
//        if (image) {
//            [weakSelf.scanTool scanImageQRCode:image];
//        }
//    }];
}

-(void) checkPhotoLibary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    __weak typeof(self)weakSelf=self;
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [weakSelf goToPhotoLib];
            }
        }];
    }else if(status == PHAuthorizationStatusAuthorized) {
        [self goToPhotoLib];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请开启相册权限"];
        [SVProgressHUD dismissWithDelay:1.0];
        
    }
}

-(void) goToPhotoLib {
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerImage.mediaTypes = [NSArray arrayWithObjects: @"public.image", nil];
    pickerImage.delegate = self;
    pickerImage.navigationBar.tintColor = kColorFromRGBHex(0xDB633D);
    [pickerImage.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:kColorFromRGBHex(0xDB633D)}];
    pickerImage.navigationBar.barTintColor = kColorFromRGBHex(0xF7F6F6);
    pickerImage.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pickerImage animated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1 获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //初始化一个监听器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >= 1) {
            //结果对象
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            [self.navigationController popViewControllerAnimated:NO];
            if (self.saoyisaoBlock) {
                self.saoyisaoBlock(scannedResult);
            }
        }
        else
        {
            //点击alert，开始扫描
            [self.session startRunning];
            //开启定时器
            [_timer setFireDate:[NSDate distantPast]];
        }
    }];
}
//得到扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            NSString *stringValue = [metadataObject stringValue];
            if (stringValue != nil) {
                [self.session stopRunning];
                //扫描结果
                [self.navigationController popViewControllerAnimated:NO];[self.navigationController popViewControllerAnimated:NO];
                NSLog(@"%@",stringValue);
                if (self.saoyisaoBlock) {
                    self.saoyisaoBlock(stringValue);
                }

            }
        }
        
    }
}
#pragma mark ============添加模糊效果============
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = CGRectGetMinX(_imageView.frame);
    CGFloat y = CGRectGetMinY(_imageView.frame);
    CGFloat w = CGRectGetWidth(_imageView.frame);
    CGFloat h = CGRectGetHeight(_imageView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor blackColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self.view addSubview:view];
}

#pragma mark ============添加扫描效果============

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
}
//控制扫描线上下滚动
- (void)timerMethod
{
    if (upOrDown == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5+num, CGRectGetWidth(_imageView.frame)-10, 3);
        if (num == (int)(CGRectGetHeight(_imageView.frame)-10)) {
            upOrDown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5+num, CGRectGetWidth(_imageView.frame)-10, 3);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}
//暂定扫描
- (void)stopScan
{
    //弹出提示框后，关闭扫描
    [self.session stopRunning];
    //弹出alert，关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    //隐藏扫描线
    _line.hidden = YES;
}
- (void)starScan
{
    //开始扫描
    [self.session startRunning];
    //打开定时器
    [_timer setFireDate:[NSDate distantPast]];
    //显示扫描线
    _line.hidden = NO;
}
-(void)BackClick{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
