# MotionOrientation
The notify the orientation of iOS device changed, using CoreMotion for even taking the orientation in 'Orientation Lock'.


# Requirements
- Xcode
- Swift 4.1

# Usage

Run below line for Start motion manager

```
SJMotionOrientationManager.shared.startAccelerometerUpdates(deviceBlock: { (deviceOrientation) in
// code 
}) { (interfacOrientation) in
// code 
}
```

You will get device orientation and interface orientation using block.


Run below line for stop motion manager

SJMotionOrientationManager.shared.stopAccelerometerUpdates()
