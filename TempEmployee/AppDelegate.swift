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
import Firebase
import UserNotifications

let INTERCOM_APP_ID = "u2oc79rp"
let INTERCOM_API_KEY = "ios_sdk-28fca06bd4b1824de40d5558d1f571b7b7303004"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var navigationController : UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.isStatusBarHidden = true
        
        IQKeyboardManager.sharedManager().enable = true
        
        Intercom.setApiKey(INTERCOM_API_KEY, forAppId: INTERCOM_APP_ID)
        
        self.registerForRemoteNotification(application);
        
        FirebaseApp.configure()
        
        setRootViewController()
        
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
        
//        if Defaults[.accessToken] != nil {
//            self.refreshToken()
//            
//        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        

       
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        print(Messaging.messaging().fcmToken ?? "No token found")
        
        //        if Defaults[.hasUserSignedIn]{
        //            FCMTokenUpdateService().updateUserFCM(token: Messaging.messaging().fcmToken!) { (result) in
        //
        //                print(result);
        //            }
        //        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    
    // Message Delegate
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        print(fcmToken)
        if Defaults[.accessToken] != nil{
            FCMTokenUpdateService().updateUserFCM(token: fcmToken) { (result) in
                
                print(result);
            }
        }
    }
    //    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //
    //
    //        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constants.Notifications.pushNotificationReceived), object: nil, userInfo: userInfo)
    //
    //    }
    
    
    /*----------------------------------------UNUserNotification Delegate mehtods---------------------------------*/
    
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo);
        
        let data = response.notification.request.content.userInfo
        
        self.showAlertController(with: "Alert", body: "")
        
        
    }
    
    @available(iOS 10.0, *)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let data = notification.request.content.userInfo
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constants.Notifications.pushNotificationReceived), object: nil, userInfo: data)
        
    }
    
    /*------------------------------------------------Custom Methods-------------------------------------------------*/
    
    
    
    func registerForRemoteNotification(_ application : UIApplication){
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self as MessagingDelegate
    }
    
    func setRootViewController(){
        
        
        
        // Employer not registeres set show case as root view controller
        if !Defaults[.hasEmployerSignedIn] {
            
            // get your storyboard
            let storyboard = UIStoryboard(name: "ShowCase", bundle: nil)

            // instantiate your desired ViewController
            let rootController : MainViewController  = storyboard.instantiateViewController(withIdentifier: "ShowCaseController") as! MainViewController
            
//                        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
//
//                        // instantiate your desired ViewController
//                        let rootController : CompanyInfoController  = storyboard.instantiateViewController(withIdentifier: "CompanyInfoController") as! CompanyInfoController

            self.setRootController(root: rootController)
        }
            
            // Employer regsitered but licence detail not uploaded take him to licenceContainerController
        else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
            self.setRootController(root: rootController)
            /*let rootController : ThankViewController  = storyboard.instantiateViewController(withIdentifier: "ThankViewController") as! ThankViewController*/
            
            //self.window?.rootViewController = rootController
            DropDown.startListeningToKeyboard()
        }
        
    }
    
    func setRootController(root controller : UIViewController) {
        
        
        navigationController  =  self.window?.rootViewController as? UINavigationController
        
        navigationController?.setViewControllers([controller], animated: false)
    }
    
    
    func showAlertController(with title : String, body:String) {
        
        let controller =   UIAlertController.init(title: title, message: body, preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: "OK", style: .default) { (action) in
            

             NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constants.Notifications.pushNotificationReceived), object: nil, userInfo: nil)
            
        }
        controller.addAction(action)
        
        self.navigationController?.topViewController?.present(controller, animated: true, completion: nil)
    }
    
    
}

