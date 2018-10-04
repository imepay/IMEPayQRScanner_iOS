//
//  QRCodeScannerViewController.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 6/6/16.
//  Copyright © 2017 imedigital All rights reserved.
//

import AVFoundation
import CryptoSwift

class QRCodeScannerViewController: BaseViewController, StoryboardInitializable {

    //MARK:- IBOutlets

    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var instructionLabel : UILabel!
    @IBOutlet weak var dissmissBtnView: UIView!

    // MARK:- Constants

    private struct Constants {
        static let sessionQueueLabel = "IMEPAY_AV_SESSION_QUEUE"
        static let alertTitle = "Alert!"
        static let turnOnCameraMessage = "Camera Should be turned on."
        static let settingActionTitle = "Settings"
        static let authAlertCancelActionTitle = "Cancel"
        static let invalidQRMessage  = "Invalid QR Code"
        static let deviceErrorMessage = "Something went wrong, Please try later."
        static let deviceErrorInfo = "Device error."
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

    // MARK:- Controller Delegate
    
    var scannerDelegate: ScannerControllerDelegate?

    //MARK:- Vc Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Session setup.
        setupCaptureSession()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTapGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSessionInMainThread()
    }
}

// MARK:- UI Setup

private extension QRCodeScannerViewController {

    func setupUI() {
        view.bringSubview(toFront: overlayView)
        view.bringSubview(toFront: instructionLabel)
        dissmissBtnView.rounded()
    }
}

// MARK:- Gesture setup

private extension QRCodeScannerViewController {
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action:#selector(self.dissmissBtnClicked))
        dissmissBtnView.addGestureRecognizer(tapGesture)
    }

    @objc func dissmissBtnClicked() {
         scannerDelegate?.cancelled()
         self.dissmiss()
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
            self.present(alert, animated: true, completion: nil)
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
            }else {
                 self.showDeviceErrorAlert()
            }
    
            let captureMetadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(captureMetadataOutput) {
    
               self.captureSession?.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
                let output = self.captureSession?.outputs[0] as? AVCaptureMetadataOutput
                var  frameOfInterest = CGRect.zero

                DispatchQueue.main.sync {
                    frameOfInterest = (self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: self.overlayView.transHoleView.frame))!
                }
                output?.rectOfInterest = frameOfInterest
            }else {
                self.showDeviceErrorAlert()
            }
        }
    }
    
    func showDeviceErrorAlert() {
        self.showAlertWithCompletion(title: Constants.deviceErrorMessage, completion: { _ in
            self.scannerDelegate?.scannerFailed(errorMessage: Constants.deviceErrorInfo)
            self.dissmiss()
        })
    }

}

//MARK:- Video Preview Layer Setup

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

    func start() {
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

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
       
        if metadataObjects.isEmpty {
            return
        }

        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            return
        }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            self.stopSessionInMainThread()
            DispatchQueue.main.async {
                if let qrstring = metadataObj.stringValue {
                    let deString = CryptoManager.decrypt(qrString: qrstring)
                    guard let mode = IMPQRInfo(withDecodedString: deString).qrTransactionMode, mode == IMPQRInfo.QRTransactionMode.payMerchat,  !deString.isEmpty else {
                        self.showAlertWithCompletion(title: Constants.invalidQRMessage, completion: { _ in
                            self.start()
                        })
                        return
                    }
                    let info = IMPQRInfo(withDecodedString: deString)
                    self.scannerDelegate?.scannerSucceed(name: info.name, mobileNumberOrCode: info.mobileNumberOrCode)
                }
            }
        }
    }
}
