//
//  AppDelegate.swift
//  Temp Provide
//
//  Created by kashif Saeed on 02/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyUserDefaults
import DropDown
import Intercom

let INTERCOM_APP_ID = "u2oc79rp"
let INTERCOM_API_KEY = "ios_sdk-28fca06bd4b1824de40d5558d1f571b7b7303004"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController : UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.sharedManager().enable = true
        setRootViewController()
        
        
        Intercom.setApiKey(INTERCOM_API_KEY, forAppId: INTERCOM_APP_ID)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if Defaults[.accessToken] != nil {
            self.refreshToken()
            
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Register for push notifications
        //For more info, see: https://developers.intercom.com/v2.0/docs/ios-push-notifications
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
//        if Defaults[.accessToken] != nil {
//             self.refreshToken()
//            
//        }
       
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return SDKApplicationDelegate.shared.application(application, open:url, sourceApplication:sourceApplication, annotation:annotation)
//    }
    
    func setRootViewController(){
        
        
        
        // Job seeker not registeres set show case as root view controller
        if !Defaults[.hasUserRegistered] {
            
            // get your storyboard
            let storyboard = UIStoryboard(name: "ShowCase", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController : MainViewController  = storyboard.instantiateViewController(withIdentifier: "ShowCaseController") as! MainViewController
            let nav = UINavigationController.init()
            nav.setViewControllers([rootController], animated: true)
             self.window?.rootViewController = nav
            
            
        }
            
            // Job seeker regsitered but licence detail not uploaded take him to licenceContainerController
        else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
            
            /*let rootController : ThankViewController  = storyboard.instantiateViewController(withIdentifier: "ThankViewController") as! ThankViewController*/
            
            self.window?.rootViewController = rootController
            DropDown.startListeningToKeyboard()
        }
        
    }
    
    func setRootController(root controller : UIViewController) {
        
        
        navigationController  =  self.window?.rootViewController as? UINavigationController
        
        navigationController?.setViewControllers([controller], animated: false)
    }
    
    func refreshToken()  {
        
        Intercom.registerUser(withEmail: Defaults[.email]!)
        LoginService().refreshToken(completionHandler:{result in
            
            switch result {
            case .Success(let user):
                
                //  print("User access token = \(user.access_token?.characters.count)")
                if user.access_token != nil{
                    Defaults[.accessToken] = user.access_token
                    Defaults[.accessTokenExpiresIn] = user.expires_in!
                    Defaults[.refreshToken] = user.refresh_token!
                }
                
            case .Failure(let error):
                print(error)
            }
            
        })
    }
}

