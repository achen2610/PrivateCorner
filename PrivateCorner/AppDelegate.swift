//
//  AppDelegate.swift
//  PrivateCorner
//
//  Created by a on 3/9/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var customWindow: MyWindow?
//    var window: UIWindow?
    var window: UIWindow? {
        get {
            customWindow = customWindow ?? MyWindow(frame: UIScreen.main.bounds)
            return customWindow
        }
        set { }
    }
    var tabBarController: TabBarController!
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.allButUpsideDown
    
    lazy var downloadButton: UIButton = {
        let button = UIButton (frame: CGRect(x: kScreenWidth - 50 * kScale, y: kScreenHeight - 100 * kScale, width: 40 * kScale, height: 40 * kScale))
        button.setImage(UIImage(named: "button-download"), for: .normal)
        button.addTarget(self, action: #selector(clickDownloadButton), for: .touchUpInside)
        return button
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UINavigationBar.appearance().barTintColor = ElementColor.bar.getColor()
        UINavigationBar.appearance().tintColor = ElementColor.title.getColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: "#3398FB")]
        
        UITabBar.appearance().barTintColor = ElementColor.bar.getColor()
        UITabBar.appearance().tintColor = ElementColor.title.getColor()
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(hex: "#3398FB")], for:.normal)
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.red], for:.selected)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as? TabBarController
        tabBarController.delegate = tabBarController
        
        let lockScreenNavi = mainStoryboard.instantiateViewController(withIdentifier: "LockScreenNavi") as! UINavigationController
        let lockScreen = lockScreenNavi.topViewController as! LockScreenViewController
        let viewModel = LockScreenViewModel(delegate: lockScreen, totalDotCount: 6)
        let firstInstall = UserDefaults.standard.bool(forKey: "firstInstall")
        if !firstInstall {
            viewModel.passcodeState = .FirstStart
            viewModel.passcodeSaved = ""
        } else {
            viewModel.passcodeState = .NotFirst
            viewModel.passcodeSaved = UserDefaults.standard.value(forKey: "passcodeSaved") as? String
        }
        lockScreen.viewModel = viewModel
        window?.rootViewController = lockScreenNavi
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowBecameHidden(notification:)), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowBecameVisible(notification:)), name: UIWindow.didBecomeHiddenNotification, object: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        backToLockScreen()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CoreDataManager.shared.saveContext()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    @objc func clickDownloadButton() {
        print("Download button clicked!")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DownloadVideoNotification"), object: nil)
        
        downloadButton.isUserInteractionEnabled = false
    }

    func backToLockScreen() {
        let naviController = window?.rootViewController as! UINavigationController
        if let naviInTabbar = tabBarController.selectedViewController as? UINavigationController {
            if let controller = naviInTabbar.topViewController as? GalleryPhotoViewController {
                if controller.isRequestPermission {
                    return
                }
            }
        }
        _ = [naviController .popViewController(animated: false)]
    }
    
    func backToLockScreenWhenChangePass() {
        let naviController = window?.rootViewController as! UINavigationController
        _ = naviController.popViewController(animated: true)
        
        if let controller = naviController.topViewController as? LockScreenViewController {
            controller.styleChangePassState()
        }
    }
    
    @objc func windowBecameHidden(notification: Notification) {
        let newWindow = notification.object as! UIWindow
        let name = NSStringFromClass(newWindow.classForCoder)
        if name == "UIRemoteKeyboardWindow" || name == "UITextEffectsWindow" || name == "_UISnapshotWindow" {
            return
        }
        
        if newWindow != window {
            newWindow.addSubview(downloadButton)
        }
    }
    
    @objc func windowBecameVisible(notification: Notification) {
        let newWindow = notification.object as! UIWindow
        if newWindow != window {
            downloadButton.removeFromSuperview()
        }
    }
}

