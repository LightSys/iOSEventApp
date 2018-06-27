//
//  QRScannerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

// The majority of this file (whatever enables it to scan QR codes) was downloaded from https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code

/*
 So the idea is that you go in to the QR scanner when you open the app. Once the
    QR code has been scanned, the app will stay on that event, sourcing data
    through that hyperlink, until otherwise notified. The ability to change the
    QR code being used is in settings. We downloaded the QR code reader.
 */

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController,
        AVCaptureMetadataOutputObjectsDelegate {

  weak var delegate: MenuButton?

  let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
  var activityIndicator: UIActivityIndicatorView!
  
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
    captureSession = AVCaptureSession()
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    let videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    if (captureSession.canAddInput(videoInput)) {
      captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr]
    } else {
      failed()
      return
    }
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
  }
  
  func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // If they arrive on the scanner, they have come back from the main container – and need to (re)scan.
    if (captureSession.isRunning == false) {
      captureSession.startRunning()
    }
  }
  
  // When the app is backgrounded, the capture session is automatically paused, then resumed when foregrounded. Because of this, this is only called when leaving for the main container.
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (captureSession.isRunning == true) {
      captureSession.stopRunning()
    }
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    captureSession.stopRunning()
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      found(code: stringValue, completion: { (success) in
        if success == true {
          self.performSegue(withIdentifier: "PresentMainContainer", sender: nil)
        }
        else {
          self.captureSession.startRunning()
        }
      })
    }
    else {
      captureSession.startRunning()
    }
  }
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - code: <#code description#>
  ///   - completion: Performed on the main thread
  func found(code: String, completion: @escaping ((_ success: Bool) -> Void)) {
//     if let url = URL(string: code) {
//    if let url = URL(string: "http://172.31.98.84:8080") {
    if let url = URL(string: "http://192.168.1.126:8080") {
      activityIndicator.startAnimating()
      (UIApplication.shared.delegate as! AppDelegate).persistentContainer.performBackgroundTask { (context) in
        
        // The user won't want notifications from a different event... clear everything except chosen refresh rate
        UserDefaults.standard.removeObject(forKey: "defaultRefreshRateMinutes")
        UserDefaults.standard.removeObject(forKey: "dataLastUpdatedAt")
        UserDefaults.standard.removeObject(forKey: "loadedDataURL")
        UserDefaults.standard.removeObject(forKey: "loadedNotificationsURL")
        UserDefaults.standard.removeObject(forKey: "notificationsLastUpdatedAt")
        self.loader.deleteAllObjects(onContext: context)
        
        self.loader.loadDataFromURL(url, completion: { (success, errors) in
          DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            if success == false {
              let alertController = UIAlertController(title: "Failed to load data", message: DataController.messageForErrors(errors), preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion(success)
              })
              alertController.addAction(okAction)
              self.present(alertController, animated: true, completion: nil)
            }
            else if errors?.count ?? 0 > 0 {
              let alertController = UIAlertController(title: "Data loaded with some errors", message: DataController.messageForErrors(errors), preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion(success)
              })
              alertController.addAction(okAction)
              self.present(alertController, animated: true, completion: nil)
            }
            else {
              completion(success)
            }
          }
        })
      }
    }
    else {
      let alertController = UIAlertController(title: "No url found", message: "\(code) is not a valid url", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
        completion(false)
      })
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  // TODO: What is this good for?
//  override var prefersStatusBarHidden: Bool {
//    return true
//  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let mainContainer = segue.destination as? MainContainerViewController {
      mainContainer.delegate = delegate
    }
  }
}
