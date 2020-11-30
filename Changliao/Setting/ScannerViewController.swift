//
//  ScannerViewController.swift
//  ChinaWorker
//
//  Created by 吕仕成 on 2018/4/13.
//  Copyright © 2018年 DCTechnology. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import AudioToolbox
import SVProgressHUD
protocol ScannerQRCodeDelegate {
    func onScaned(qrcode:String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    var scanningLineImageView:UIImageView?
    var stopedAnimation = false
    var avDevice:AVCaptureDevice?//摄像头对象
    var avSession:AVCaptureSession?//  回话对象
    var delegate:ScannerQRCodeDelegate?
    var previewlayer: AVCaptureVideoPreviewLayer!  //摄像头图层
    var output: AVCaptureMetadataOutput! //输出类
    var hasData=false
    var scanWidth: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avSession?.startRunning()
//        startScanLineAnimation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createScannerLayer()
        showAV()
        self.title = "扫一扫";
        // 创建“相册”按钮
        let RightItem = UIBarButtonItem(title: "相册", style: UIBarButtonItem.Style.plain, target: self, action: #selector(GoXiangCe))
        
        self.navigationItem.rightBarButtonItem = RightItem
        
    }
    //点击相册按钮事件
    @objc func GoXiangCe() -> Void{
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        self.present(imagePicker, animated: true, completion: nil)

        
    }
    //点击图片时触发该方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        //获取点击图片
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated: true) {
            
            SVProgressHUD.show()
            
            //二维码读取
            let ciImage:CIImage = CIImage (image: image)!
            
            //创建图片扫描仪CIDetectorAccuracyHigh
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            //            let ci = CIImage(data: image.pngData()!)
            //获取到二维码数据
            let featureArr = detector?.features(in: ciImage)
            if featureArr?.first != nil {
                let feature = featureArr?.first as! CIQRCodeFeature
                SVProgressHUD.dismiss()
                self.delegate?.onScaned(qrcode: (feature.messageString!))
            }else
            {
                
                SVProgressHUD.dismiss()
            }
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    //点击取消时调用该方法
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    //返回
    @objc func backAction() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downAnimate()
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopedAnimation = true
    }
    
    /// 扫描布局
    func createScannerLayer() {
        let scannerLayer = CALayer()
        scannerLayer.frame = CGRect(x: self.view.frame.width*0.15, y: self.view.frame.height*0.24, width: self.view.frame.width*0.7, height: self.view.frame.height*0.52)
        self.view.layer.addSublayer(scannerLayer)
        let leftTopImageView = UIImageView(frame: CGRect(x: self.view.frame.width*0.15, y: self.view.frame.height*0.24, width: 25, height: 25))
        leftTopImageView.image = UIImage(named: "矩形3拷贝")
        self.view.addSubview(leftTopImageView)
        let rightTopImageView = UIImageView(frame: CGRect(x: self.view.frame.width*0.85-25, y: self.view.frame.height*0.24, width: 25, height: 25))
        rightTopImageView.image = UIImage(named: "矩形3拷贝2")
        self.view.addSubview(rightTopImageView)
        let leftBottomImageView = UIImageView(frame: CGRect(x: self.view.frame.width*0.15, y: self.view.frame.height*0.76-25, width: 25, height: 25))
        leftBottomImageView.image = UIImage(named: "矩形3拷贝2.")
        self.view.addSubview(leftBottomImageView)
        let rightBottomImageView = UIImageView(frame: CGRect(x: self.view.frame.width*0.85-25, y: self.view.frame.height*0.76-25, width: 25, height: 25))
        rightBottomImageView.image = UIImage(named: "矩形3拷贝.")
        self.view.addSubview(rightBottomImageView)
        scanningLineImageView = UIImageView(frame: CGRect(x: (self.view.frame.width-146)/2, y: self.view.frame.height*0.24, width: 146, height: 1))
        scanningLineImageView?.image = UIImage(named: "矩形1")
        self.view.addSubview(scanningLineImageView!)
        
    }
    
    /// 向下动画
    func downAnimate() {
        UIView.animate(withDuration: 3, animations: {
            self.scanningLineImageView?.frame = CGRect(x: (self.view.frame.width-146)/2, y: self.view.frame.height*0.76, width: 146, height: 1)
        }) { (_) in
            if !self.stopedAnimation{
                DispatchQueue.main.async {
                    self.upAnimate()
                }
            }
        }
    }
    
    /// 向上动画
    func upAnimate() {
        UIView.animate(withDuration: 3, animations: {
            self.scanningLineImageView?.frame = CGRect(x: (self.view.frame.width-146)/2, y: self.view.frame.height*0.24, width: 146, height: 1)
        }) { (_) in
            if !self.stopedAnimation{
                DispatchQueue.main.async {
                    self.downAnimate()
                }
            }
        }
    }
    
    func showAV() {
        let auth = AVCaptureDevice.authorizationStatus(for: .video)
        if auth == AVAuthorizationStatus.restricted || auth == AVAuthorizationStatus.denied {
            let alert = UIAlertController(title: nil, message: "请开启相机权限", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        avDevice = AVCaptureDevice.default(for: .video)
        let input = try! AVCaptureDeviceInput.init(device: avDevice!)
        let metdataOutput = AVCaptureMetadataOutput()
        metdataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metdataOutput.rectOfInterest = self.view.bounds
        
        avSession = AVCaptureSession()
        avSession?.sessionPreset = .hd1280x720
        avSession?.addInput(input)
        avSession?.addOutput(metdataOutput)
        
        metdataOutput.metadataObjectTypes = [.qr]
        let layer = AVCaptureVideoPreviewLayer(session: avSession!)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        
        avSession?.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopedAnimation = true
        avSession?.stopRunning()
        if hasData {
            return
        }
        hasData=true
        let data : AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if data != nil {
            delegate?.onScaned(qrcode: (data.stringValue)!)
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    //MARK: -----点击屏幕控制闪光灯------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //呼叫控制硬件
        try! avDevice!.lockForConfiguration()
        
        //开启、关闭闪光灯
        if avDevice!.torchMode == .on {
            avDevice!.torchMode = .off
        } else {
            avDevice!.torchMode = .on
        }
        //控制完毕需要关闭控制硬件
        avDevice!.unlockForConfiguration()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
