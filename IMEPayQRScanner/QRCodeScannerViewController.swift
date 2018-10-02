//
//  QRCodeScannerViewController.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 6/6/16.
//  Copyright © 2017 imedigital All rights reserved.
//

import AVFoundation
import CryptoSwift

//MARK:- Encryption Keys

let imePayIv: String = "190db824fe56c37a"
let imePaySecretKey: String = "081a49b37c56e2fd"

class QRCodeScannerViewController: BaseViewController, StoryboardInitializable {

    //MARK:- IBOutlets

    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var instructionLabel : UILabel!
    
    private struct Constants {
        
        static let sessionQueueLabel = "IMEPAY_SESSION_QUEUE"
        static let alertTitle = "Alert!"
        static let turnOnCameraMessage = "Camera Should be turned on."
        static let settingActionTitle = "Settings"
        static let authAlertCancelActionTitle = "Cancel"
    }

    //MARK:- Session Queue

    fileprivate var sessionQueue = DispatchQueue(label: Constants.sessionQueueLabel)

    // MARK:- Capture Session
    
    fileprivate var captureSession: AVCaptureSession?

    // MARK:- Preview Layer
    
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    //MARK:-  Supported Code Types

    fileprivate lazy var supportedCodeTypes: [AVMetadataObject.ObjectType] = {
        return [ .upce,.code39, .code39Mod43, .code128, .ean8, .ean13, .aztec, .pdf417, .qr ]
    }()

    var isSendMoney = false

    //MARK:- Vc Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Session setup.
        setupCaptureSession()
        view.bringSubview(toFront: overlayView)
        view.bringSubview(toFront: instructionLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reStart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stop()
    }

}

//MARK:-  Authorizartion and session setup

private extension QRCodeScannerViewController {

    func checkAuthorization() {

        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
                self.sessionQueue.resume()
            })
            break
        case .restricted:
            break
        case .denied:

            let alert = UIAlertController(title: Constants.alertTitle, message: Constants.turnOnCameraMessage, preferredStyle: UIAlertControllerStyle.alert)
            let settingButton = UIAlertAction(title: Constants.settingActionTitle, style: UIAlertActionStyle.default) { (alert)  in
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: { completed in

                        })
                    } else {
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                    }
                }
            }
            alert.addAction(settingButton)
            let cancelButton = UIAlertAction(title: Constants.authAlertCancelActionTitle, style: UIAlertActionStyle.cancel) { (alert)  in
            }
            alert.addAction(cancelButton)
            //UIViewController.topViewController().present(alert, animated: true, completion: nil)
            break
        case .authorized:
            break
        }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        self.setupPreviewLayer()
        checkAuthorization()

        sessionQueue.async {
            let captureDevice =  AVCaptureDevice.default(for: AVMediaType.video)
            var input: AVCaptureDeviceInput?
            
            
            guard let capDevice = captureDevice else {  return }

            do {
                input = try AVCaptureDeviceInput(device: capDevice)
            } catch _ { }

            // Initialize the captureSession object.

            guard let deviceInput = input, let session = self.captureSession else { return }

            if session.canAddInput(deviceInput) {
                 self.captureSession?.addInput(deviceInput)
            }else { // Handle the case

            }
    
            let captureMetadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(captureMetadataOutput) {
    
               self.captureSession?.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
                let output = self.captureSession?.outputs[0] as? AVCaptureMetadataOutput
                var  frameOfInterest = CGRect.zero

                DispatchQueue.main.sync {
                    //frameOfInterest = (self.videoPreviewLayer?.metadataOutputRectOfInterest(for: self.overlayView.transHoleView.frame))!
                    frameOfInterest = (self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: self.overlayView.transHoleView.frame))!
                }
                output?.rectOfInterest = frameOfInterest
            }else {
                // Handle the Case
            }

        }
    }

}

//MARK:- Preview Setup

private extension QRCodeScannerViewController {

    func setupPreviewLayer() {

        guard let session = self.captureSession else {  return }
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        let videoFrame = CGRect(x: self.view.layer.bounds.origin.x, y: self.view.layer.bounds.origin.y, width:self.view.layer.bounds.width, height: self.view.layer.bounds.height)
        self.videoPreviewLayer?.frame = videoFrame
        self.view.layer.addSublayer(self.videoPreviewLayer!)
    }
}

//MARK:- Session Control

private extension QRCodeScannerViewController {

    func reStart() {
        sessionQueue.async {
            self.captureSession?.startRunning()
        }
    }

    func stop() {
        sessionQueue.async {
            self.captureSession?.stopRunning()
        }
    }

    func stopSessionInMainThread() {
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
        }
    }
}

//MARK:- AVCaptureMetadataOutputObjectsDelegate

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

            if metadataObjects == nil || metadataObjects.count == 0 {
                return
            }
            let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject

            if metadataObj!.type == AVMetadataObject.ObjectType.qr {
                self.stopSessionInMainThread()
                DispatchQueue.main.async {

                if let qrstring = metadataObj!.stringValue {
                    let deString = self.decrypt(qrString: qrstring)
                    print("decrypted QR Data \(deString)")
//                    guard let mode = QRData(withDecodedString: deString).qrTransactionMode, deString.count > 0 else {
//                        self.showAlertWithCompletion(title: "Invalid QR Data", completion: { _ in
//                            self.reStart()
//                        })
//                        return
//                    }
//                    switch mode {
//                    case .sendMoney:
//                        let qrPayCoordinator = SendwithQRCoordinator(withRootViewController: self.navigationController!, qrData: QRData(withDecodedString: deString))
//                        qrPayCoordinator.start()
//                        break
//                    case .payMerchat:
//
//                        if self.isSendMoney == true {
//                            self.showAlertWithCompletion(title: "Please use a valid QR Code for send money", completion: { _ in
//                                self.reStart()
//                            })
//                            return
//                        }
//
//                        let data = QRData(withDecodedString: deString)
//                        guard let _ = data.mobileNumber else {
//                            self.showAlertWithCompletion(title: "Invalid QR Data", completion: { _ in
//                                self.reStart()
//                            })
//                            return
//                        }
//                        //HYBRID AGENT MERCHANT ACTIONS
//
//                        let selectHybridActionvC = SelectHybridActionViewController.initFromStoryboard(name: "QRCode")
//                        selectHybridActionvC.qrData = data
//                        self.navigationController?.pushViewController(selectHybridActionvC, animated: true)
//                        break
//                    case .agent:
//
//                        if self.isSendMoney == true {
//                            self.showAlertWithCompletion(title: "Please use a valid QR Code for send money", completion: { _ in
//                                self.reStart()
//                            })
//                            return
//                        }
//
//
//                        let data = QRData(withDecodedString: deString)
//                        guard let _ = data.mobileNumber else {
//                            self.showAlertWithCompletion(title: "Invalid QR Data", completion: { _ in
//                                self.reStart()
//                            })
//                            return
//                        }
//
//                        //HYBRID AGENT MERCHANT ACTIONS
//                        let selectHybridActionvC = SelectHybridActionViewController.initFromStoryboard(name: "QRCode")
//                        selectHybridActionvC.qrData = data
//                        self.navigationController?.pushViewController(selectHybridActionvC, animated: true)
//                        break
//                    }
                }
            }
          }
        }
}

//MARK:- Decryption

extension QRCodeScannerViewController {

    func decrypt(qrString: String) -> String {
        do {
            let decrypted =   try AES(key: imePaySecretKey, iv: imePayIv, blockMode: .CBC, padding: .noPadding).decrypt(Array<UInt8>(hex: qrString))
             return String(data: Data(decrypted), encoding: String.Encoding.utf8) ?? ""
        } catch _ {
            print("Failed to decrypt the QR Data")
        }
        return ""
    }

}
