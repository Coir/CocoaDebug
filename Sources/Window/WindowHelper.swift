//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

public class WindowHelper: NSObject {
    public static let shared = WindowHelper()
    
    var window: CocoaDebugWindow
    var displayedList = false
    lazy var vc = CocoaDebugViewController() //must lazy init, otherwise crash
    
    //UIBlocking
//    fileprivate var uiBlockingCounter = UIBlockingCounter()
//    var uiBlockingCallback:((Int) -> Void)?
    
    
    private override init() {
        window = CocoaDebugWindow(frame: UIScreen.main.bounds)
        // This is for making the window not to effect the StatusBarStyle
//        window.bounds.size.height = UIScreen.main.bounds.height.nextDown
        super.init()
        
//        uiBlockingCounter.delegate = self
    }
    
    
    public func enable() {
        if window.rootViewController == vc {
            return
        }
        
        window.rootViewController = vc
        window.delegate = self
        window.isHidden = false
        
        if CocoaDebugSettings.shared.enableUIBlockingMonitoring == true {
            startUIBlockingMonitoring()
        }

        if #available(iOS 13.0, *) {
            var success: Bool = false

            for i in 0...10 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.1 * Double(i))) {[weak self] in
                    if success == true {return}

                    for scene in UIApplication.shared.connectedScenes {
                        if let windowScene = scene as? UIWindowScene {
                            guard let self = self else { return }
                            self.window.windowScene = windowScene
//                            let statusbarHeight = windowScene.statusBarManager?.statusBarFrame.size.height ?? 20
//                            self.window.frame.origin.y = statusbarHeight
                            
                            /// 调低window的高度，修复>=iOS16横屏的问题。。wired
                            self.window.frame.size.height -= 0.1
                            success = true
                        }
                    }
                }
            }
        }
    }
    
    
    public func disable() {
        if window.rootViewController == nil {
            return
        }
        window.rootViewController = nil
        window.delegate = nil
        window.isHidden = true
        stopUIBlockingMonitoring()
    }
    
    public func startUIBlockingMonitoring() {
//        uiBlockingCounter.startMonitoring()
        _RunloopMonitor.shared().begin()
    }

    public func stopUIBlockingMonitoring() {
//        uiBlockingCounter.stopMonitoring()
        _RunloopMonitor.shared().end()
    }
}


// MARK: - UIBlockingCounterDelegate
//extension WindowHelper: UIBlockingCounterDelegate {
//    @objc public func uiBlockingCounter(_ counter: UIBlockingCounter, didUpdateFramesPerSecond uiBlocking: Int) {
//        if let uiBlockingCallback = uiBlockingCallback {
//            uiBlockingCallback(uiBlocking)
//        }
//    }
//}

