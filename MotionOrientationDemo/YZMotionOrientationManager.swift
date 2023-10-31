//
//  YZMotionOrientationManager.swift
//  MotionOrientationDemo
//
//  Created by Yudiz Solutions on 29/08/18.
//  Copyright © 2018 Yudiz Solutions. All rights reserved.
//


import Foundation
import UIKit
import CoreMotion

typealias YZDeviceOrientationHandler = (UIDeviceOrientation) -> Swift.Void
typealias YZInterfaceOrientationHandler = (UIInterfaceOrientation) -> Swift.Void

class YZMotionOrientationManager: NSObject{
    static let shared =  YZMotionOrientationManager()
    
    // MARK: - Variables
    var motionManager: CMMotionManager = {
        let cm = CMMotionManager()
        cm.accelerometerUpdateInterval = 0.1
        return cm
    }()
    
    var operationQueue: OperationQueue = {
        let qu = OperationQueue()
        return qu
    }()
    
    var interfaceOrientation: UIInterfaceOrientation = .portrait
    var deviceOrientation: UIDeviceOrientation = .portrait
    
    var deviceOrientationBlock: YZDeviceOrientationHandler?
    var interfaceOrientationBlock: YZInterfaceOrientationHandler?
    
    var affineTransform: CGAffineTransform {
        var rotationDegree: CGFloat = 0
        
        switch self.interfaceOrientation {
        case .portrait :
            rotationDegree = 0
            break
        case .landscapeLeft :
            rotationDegree = 90
            break
        case .portraitUpsideDown :
            rotationDegree = 180
            break
        case .landscapeRight :
            rotationDegree = 270
            break
            
        default:
            break
        }
        return CGAffineTransform(rotationAngle: (CGFloat.pi * rotationDegree)/180.0)
    }
    
    private override init(){
        super.init()
    }
    
    func startAccelerometerUpdates(deviceBlock: YZDeviceOrientationHandler? = nil, interfaceBlock: YZInterfaceOrientationHandler? = nil){
        self.deviceOrientationBlock = deviceBlock
        self.interfaceOrientationBlock = interfaceBlock
        // Simulator
        #if arch(i386) || arch(x86_64)
        self.prepareForSimulator()
        #endif
        if (!self.motionManager.isAccelerometerAvailable) {
            print("YZMotionOrientationManager - Accelerometer is NOT available");
            return;
        }
        self.motionManager.startAccelerometerUpdates(to: self.operationQueue) { [weak self] (accelerometerData, error) in
            self?.accelerometerUpdate(withData: accelerometerData, error: error)
        }
    }
    
    func stopAccelerometerUpdates(){
        self.motionManager.stopAccelerometerUpdates()
        // Simulator
        #if arch(i386) || arch(x86_64)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        #endif
        NotificationCenter.default.removeObserver(self)
        self.deviceOrientationBlock = nil
        self.interfaceOrientationBlock = nil
    }
    
    func accelerometerUpdate(withData accelerometerData: CMAccelerometerData?, error: Error?){
        if let err = error{
            print("accelerometerUpdate ERROR: \(err)");
            return
        }
        guard let data = accelerometerData else {
            return
        }
        let acceleration = data.acceleration
        
        // Get the current device angle
        let xx = -acceleration.x
        let yy =  acceleration.y
        let z =  acceleration.z
        let angle = atan2(yy, xx)
        
        let newInterfaceOrientation =  self.interfaceOrientation(withCurrentOrientation: self.interfaceOrientation, angle: angle, z: z)
        let newDeviceOrientation = self.deviceOrientation(withCurrentOrientation: self.deviceOrientation, angle: angle, z: z)
        
        var deviceOrientationChanged = false
        var interfaceOrientationChanged = false
        
        if newDeviceOrientation != self.deviceOrientation{
            deviceOrientationChanged = true
            self.deviceOrientation = newDeviceOrientation
        }
        
        if newInterfaceOrientation != self.interfaceOrientation{
            interfaceOrientationChanged = true
            self.interfaceOrientation = newInterfaceOrientation
        }
        
        // Fire the block
        
        if deviceOrientationChanged {
            self.deviceOrientationBlock?(self.deviceOrientation)
        }
        
        if interfaceOrientationChanged{
            self.interfaceOrientationBlock?(self.interfaceOrientation)
        }
    }
    
    func deviceOrientation(interfaceOrientation orientation: UIInterfaceOrientation) -> UIDeviceOrientation{
        
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func interfaceOrientation(withCurrentOrientation orientation: UIInterfaceOrientation, angle: Double, z: Double) -> UIInterfaceOrientation{
        let devOrientation = self.deviceOrientation(withCurrentOrientation: self.deviceOrientation(interfaceOrientation: orientation), angle: angle, z: z)
        switch devOrientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return orientation;
        }
    }
    
    func deviceOrientation(withCurrentOrientation orientation: UIDeviceOrientation, angle: Double, z: Double) -> UIDeviceOrientation{
        
        let absoluteZ = fabs(z)
        var devOrientation = orientation
        if deviceOrientation == .faceUp || deviceOrientation == .faceDown {
            if (absoluteZ < 0.845) {
                if (angle < -2.6) {
                    devOrientation = .landscapeRight
                } else if (angle > -2.05 && angle < -1.1) {
                    devOrientation = .portrait
                } else if (angle > -0.48 && angle < 0.48) {
                    devOrientation = .landscapeLeft
                } else if (angle > 1.08 && angle < 2.08) {
                    devOrientation = .portraitUpsideDown
                }
            } else if (z < 0.0) {
                devOrientation = .faceUp
            } else if (z > 0.0) {
                devOrientation = .faceDown
            }
            
        }else{
            if (z > 0.875) {
                devOrientation = .faceDown
            } else if (z < -0.875) {
                devOrientation = .faceUp
            } else {
                switch (devOrientation) {
                case .landscapeLeft:
                    if (angle < -1.07){
                        return .portrait;
                    }
                    if (angle > 1.08){
                        return .portraitUpsideDown
                    }
                    break;
                    
                case .landscapeRight:
                    if (angle < 0.0 && angle > -2.05) {
                        return .portrait;
                    }
                    if (angle > 0.0 && angle < 2.05) {
                        return .portraitUpsideDown
                    }
                    break;
                    
                case .portraitUpsideDown:
                    if (angle > 2.66) {
                        return .landscapeRight
                    }
                    if (angle < 0.48) {
                        return .landscapeLeft
                    }
                    break;
                    
                default:
                    if (angle > -0.47) {
                        return .landscapeLeft
                    }
                    if (angle < -2.64){
                        return .landscapeRight
                    }
                    break;
                }
            }
        }
        
        return devOrientation;
    }
    
    func debugDataString(withZ z: Double, angle: Double) -> String{
        return String(format: "<z: %.3f> <angle: %.3f>",z, angle)
    }
    
    // Simulator support
    #if arch(i386) || arch(x86_64)
    func prepareForSimulator(){
        print("YZMotionOrientationManager - Simulator in use. Using UIDevice instead")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func deviceOrientationChanged(_ noti: Notification){
        self.deviceOrientation = UIDevice.current.orientation
        self.deviceOrientationBlock?(self.deviceOrientation)
    }
    #endif
    
    deinit {
        #if arch(i386) || arch(x86_64)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        #endif
        NotificationCenter.default.removeObserver(self)
        self.deviceOrientationBlock = nil
        self.interfaceOrientationBlock = nil
    }
}
