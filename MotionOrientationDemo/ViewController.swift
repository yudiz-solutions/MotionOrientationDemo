//
//  ViewController.swift
//  MotionOrientationDemo
//
//  Created by Yudiz Solutions on 29/08/18.
//  Copyright © 2018 Yudiz Solutions. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet var lblDeviceOrientation: UILabel!
    @IBOutlet var lblMotionOrientation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
       UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
        YZMotionOrientationManager.shared.stopAccelerometerUpdates()
    }
    
    func prepareUI(){
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
         YZMotionOrientationManager.shared.startAccelerometerUpdates(deviceBlock: { [weak self ] (orientation) in
            self?.prepareMotionOrientation( orientation)
        })
    }
    
    @objc func deviceOrientationChanged(){
        switch UIDevice.current.orientation {
        case .portrait:
            lblDeviceOrientation.text = "portrait"
            break
        case .portraitUpsideDown:
            lblDeviceOrientation.text = "portraitUpsideDown"
            break
        case .landscapeLeft:
            lblDeviceOrientation.text = "landscapeLeft"
            break
        case .landscapeRight:
            lblDeviceOrientation.text = "landscapeRight"
            break
        case .faceUp:
            lblDeviceOrientation.text = "faceUp"
            break
        case .faceDown:
            lblDeviceOrientation.text = "faceDown"
            break
        default:
            lblDeviceOrientation.text = "unknown"
            break
        }
    }
    
    func prepareMotionOrientation(_ orientation: UIDeviceOrientation){
        switch orientation {
        case .portrait:
            lblMotionOrientation.text = "portrait"
            break
        case .portraitUpsideDown:
            lblMotionOrientation.text = "portraitUpsideDown"
            break
        case .landscapeLeft:
            lblMotionOrientation.text = "landscapeLeft"
            break
        case .landscapeRight:
            lblMotionOrientation.text = "landscapeRight"
            break
        case .faceUp:
            lblMotionOrientation.text = "faceUp"
            break
        case .faceDown:
            lblMotionOrientation.text = "faceDown"
            break
        default:
            lblMotionOrientation.text = "unknown"
            break
        }
    }
}

