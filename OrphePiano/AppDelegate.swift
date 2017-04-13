//
//  AppDelegate.swift
//  Orphe-Instrument
//
//  Created by kyosuke on 2017/01/01.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import UIKit
import Orphe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Player.sharedInstance.openPdFile()
        OrpheFont.setFontSize()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if(!(ORPManager.sharedInstance.isLeftConnected() && ORPManager.sharedInstance.isLeftConnected())){
            UIApplication.presentConnectViewController()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

extension UIColor {
    // Color Palette
    class func orpheWhite() -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 255/255)
    }
    class func orpheBlack() -> UIColor {
        return UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 255/255)
    }
    class func orpheYellow() -> UIColor {
        return UIColor(red: 230/255, green: 207/255, blue: 0/255, alpha: 255/255)
    }
    class func orpheBlackTransmission() -> UIColor {
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
    }
    // ===========================================
    // Panel
    class func orpheActive() -> UIColor {
        return orpheYellow()
    }
    class func orphePanel() -> UIColor {
        return orpheWhite()
    }
    class func orphePanelText() -> UIColor {
        return orpheBlack()
    }
    class func orpheActivePanel() -> UIColor {
        return orpheActive()
    }
    class func orpheActivePanelText() -> UIColor {
        return orpheBlack()
    }
    // Text
    class func orpheText() -> UIColor {
        return orpheBlack()
    }
    class func orpheTextBackground() -> UIColor {
        return orpheWhite()
    }
    class func orpheModalBackground() -> UIColor {
        return orpheBlackTransmission()
    }
}

extension UIApplication {
    
    class func presentConnectViewController(animated:Bool = true){
        let ignoreCVNames = ["ConnectViewController","SplashViewController"]
        
        let storyboard = UIStoryboard(name: "ConnectViewController", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateInitialViewController() else {
            return
        }
        for vcName in ignoreCVNames{
            if UIApplication.findViewController(nameVC: vcName)! {
                return
            }
        }
        
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()!.present(viewController, animated: animated, completion: nil)
        
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        print("topVC:", base?.description ?? "nil")
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    
    class func findViewController(vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController,nameVC: String) -> Bool? {
        PRINT("search name:",nameVC)
        
        if let nav = vc as? UINavigationController {
            let currentNav = nav.viewControllers.last!
            let className = NSStringFromClass(type(of: currentNav)).components(separatedBy: ".").last!
            if className == nameVC{
                return true
            }
            else{
                return searchFromPresentedViewController(vc: currentNav, nameVC: nameVC)
            }
        }
        
        if let tab = vc as? UITabBarController {
            if let selected = tab.selectedViewController {
                if String(describing: Mirror(reflecting: selected).subjectType) == nameVC{
                    return true
                }
                else{
                    return searchFromPresentedViewController(vc: selected, nameVC: nameVC)
                }
            }
        }
        
        if let _ = vc?.presentedViewController{
            return searchFromPresentedViewController(vc: vc, nameVC: nameVC)
        }
        
        return false
    }
    
    private class func searchFromPresentedViewController(vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController,nameVC: String) -> Bool? {
        if let presented = vc?.presentedViewController {
            let className = NSStringFromClass(type(of: presented)).components(separatedBy: ".").last!
            if className == nameVC{
                return true
            }
            else{
                return findViewController(vc: presented,nameVC: nameVC)
            }
        }
        else{
            return false
        }
    }
}

class OrpheFont:UIFont{
    
    private static var regularSize:CGFloat = 14
    private static var boldSize:CGFloat = 16
    private static var headerSize:CGFloat = 24
    
    class func setFontSize(){
        if UIScreen.main.bounds.size.height == 480 {
            // iPhone 4
            regularSize = 14
            headerSize = 24
        }
        else if UIScreen.main.bounds.size.height == 568 {
            // IPhone 5
            regularSize = 14
            headerSize = 24
        }
        else if UIScreen.main.bounds.size.width == 375 {
            // iPhone 7
            regularSize = 15
            headerSize = 26
        }
        else if UIScreen.main.bounds.size.width == 414 {
            // iPhone 7+
            regularSize = 16
            headerSize = 28
        }
        else{
            regularSize = 16
            headerSize = 28
        }
    }
    
    class func regular() -> UIFont {
        return systemFont(ofSize: regularSize)
    }
    
    class func bold() -> UIFont {
        return boldSystemFont(ofSize: boldSize)
    }
    
    class func header() -> UIFont {
        return boldSystemFont(ofSize: headerSize)
    }
}

