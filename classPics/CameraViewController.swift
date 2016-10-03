//
//  CameraViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/03.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate  {
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var imageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面タップでピントをあわせる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedGesture))
        
        // デリゲートをセット
        tapGesture.delegate = self
        
        // Viewにタップ、ピンチのジェスチャーを追加
        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(pinchGesture)
        
        let underView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: self.view.frame.size.width, height:self.view.frame.size.height/8)))
        underView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-underView.frame.size.height/2)
        underView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(underView)
        
        let shutterButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: underView.frame.size.height-15, height: underView.frame.size.height-15)))
        shutterButton.center = CGPoint(x: underView.frame.size.width/2, y: underView.frame.size.height/2)
        shutterButton.backgroundColor = UIColor.white.withAlphaComponent(0)
        shutterButton.layer.masksToBounds = true
        shutterButton.layer.cornerRadius = shutterButton.frame.size.width/2
        shutterButton.layer.borderColor = UIColor.white.cgColor
        shutterButton.layer.borderWidth = 6
        shutterButton.addTarget(self, action: #selector(tapedShutterButton), for: .touchUpInside)
        underView.addSubview(shutterButton)
        
        let shutterShadowView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: shutterButton.frame.size.height-18, height: shutterButton.frame.size.height-18)))
        shutterShadowView.center = CGPoint(x: shutterButton.frame.size.width/2, y: shutterButton.frame.size.height/2)
        shutterShadowView.backgroundColor = UIColor.white
        shutterShadowView.layer.masksToBounds = true
        shutterShadowView.layer.cornerRadius = shutterShadowView.frame.size.width/2
        // shutterShadowView.layer.borderColor = UIColor.blackColor().CGColor
        // shutterShadowView.layer.borderWidth = 3
        shutterShadowView.isUserInteractionEnabled = false
        shutterButton.addSubview(shutterShadowView)
        
        let closeButton = UIButton()
        closeButton.setTitle("閉じる", for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.sizeToFit()
        closeButton.center = CGPoint(x: (underView.frame.size.width+shutterButton.center.x+shutterButton.frame.size.width/2)/2, y: underView.frame.size.height/2)
        closeButton.addTarget(self, action: #selector(tapedCloseButton), for: .touchUpInside)
        underView.addSubview(closeButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // スクリーン設定
        setupDisplay()
        
        // カメラの設定
        setupCamera()
    }
    
    // メモリ解放
    override func viewDidDisappear(_ animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        
        session = nil
        camera = nil
    }
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.main.bounds.size.width;
        //スクリーンの高さ
        let screenHeight = UIScreen.main.bounds.size.height;
        
        // カメラからの映像を映すimageViewの作成
        if let iv = imageView {
            //以前のimageViewがあれば剥がしておく
            iv.removeFromSuperview()
        }
        imageView = UIImageView()
        imageView.frame = CGRect(x:0.0, y:0.0, width:screenWidth, height:screenHeight)
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
    }
    
    func setupCamera(){
        // AVCaptureSession: キャプチャに関する入力と出力の管理
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        let a = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back)
        
        // AVCaptureDevice: カメラやマイクなどのデバイスを設定
        for caputureDevice in (a?.devices)! {
            // 背面カメラを取得
            if (caputureDevice as AnyObject).position == AVCaptureDevicePosition.back {
                camera = caputureDevice
            }
        }
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // AVCaptureVideoDataOutput:動画フレームデータを出力に設定
        output = AVCaptureVideoDataOutput()
        
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        output.alwaysDiscardsLateVideoFrames = true
        
        session.startRunning()
        
        // deviceをロックして設定
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // キャプチャしたsampleBufferからUIImageを作成
        let image:UIImage = self.captureImage(sampleBuffer: sampleBuffer)
        
        // カメラの画像を画面に表示
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    // sampleBufferからUIImageを作成
    func captureImage(sampleBuffer:CMSampleBuffer) -> UIImage{
        
        // Sampling Bufferから画像を取得
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let baseAddress:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        // 色空間
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue)!
        
        let imageRef:CGImage = newContext.makeImage()!
        let resultImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right)
        
        return resultImage
    }
    
    
    // タップイベント.
    func tapedShutterButton(sender: UIButton) {
        takeStillPicture()
        
        self.imageView.alpha = 0.4
        
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.alpha = 1
        })
    }
    
    func takeStillPicture(){
//        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
//            // アルバムに追加
//            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
//        }
        
        let path = NSHomeDirectory() + "/Library/"
        let fileName = "sample.png"
        let filePath = path + fileName
        
        let data = UIImagePNGRepresentation(imageView.image!)
        
        try! data?.write(to: URL(fileURLWithPath: filePath))
        
    }
    
    func tapedCloseButton(sender: UIButton) {
        print("Close")
        
        // 前の画面に戻るとき
        // self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    let focusView = UIView()
    
    func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
        let tapCGPoint = gestureRecognizer.location(ofTouch: 0, in: gestureRecognizer.view)
        focusView.frame.size = CGSize(width: 120, height: 120)
        focusView.center = tapCGPoint
        focusView.backgroundColor = UIColor.white.withAlphaComponent(0)
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 1
        imageView.addSubview(focusView)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.focusView.frame.size = CGSize(width: 80, height: 80)
            self.focusView.center = tapCGPoint
            }, completion: { Void in
                UIView.animate(withDuration: 0.5, animations: {
                    self.focusView.alpha = 0
                })
        })
        
        self.focusWithMode(focusMode: AVCaptureFocusMode.autoFocus, exposeWithMode: AVCaptureExposureMode.autoExpose, atDevicePoint: tapCGPoint, motiorSubjectAreaChange: true)
    }
    
    var oldZoomScale: CGFloat = 1.0
    
    func pinchedGesture(gestureRecgnizer: UIPinchGestureRecognizer) {
        do {
            try camera.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var currentZoomScale: CGFloat = camera.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = gestureRecgnizer.scale
            
            // ピンチアウトの時、前回のズームに今回のズーム-1を指定
            // 例: 前回3.0, 今回1.2のとき、currentZoomScale=3.2
            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale+pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale-(1-pinchZoomScale)*oldZoomScale
            }
            
            // 最小値より小さく、最大値より大きくならないようにする
            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            }
            else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }
            
            // 画面から指が離れたとき、stateがEndedになる。
            if gestureRecgnizer.state == .ended {
                oldZoomScale = currentZoomScale
            }
            
            camera.videoZoomFactor = currentZoomScale
            camera.unlockForConfiguration()
        } catch {
            // handle error
            return
        }
    }
    
    func focusWithMode(focusMode : AVCaptureFocusMode, exposeWithMode expusureMode :AVCaptureExposureMode, atDevicePoint point:CGPoint, motiorSubjectAreaChange monitorSubjectAreaChange:Bool) {
        
        
        DispatchQueue.global().async {
            let device : AVCaptureDevice = self.input.device
            
            do {
                try device.lockForConfiguration()
                if(device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode)){
                    device.focusPointOfInterest = point
                    device.focusMode = focusMode
                }
                if(device.isExposurePointOfInterestSupported && device.isExposureModeSupported(expusureMode)){
                    device.exposurePointOfInterest = point
                    device.exposureMode = expusureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
