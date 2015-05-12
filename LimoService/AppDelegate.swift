//
//  AppDelegate.swift
//  LimoService
//
//  Created by Sameer Totey on 3/11/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseUI
import ParseCrashReporting

struct PushNotifications {
    static let Notification = "LimoService Push Notification"
    static let Key = "LimoService Push Notification Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId(KeysAndSecrets.parseApplicationId, clientKey: KeysAndSecrets.parseClientKey)
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        
        // we have to create dummy lauchOptions object if application receives nil because of the signature of the initialize method Facebook utils
        if let launchOptions = launchOptions {
            PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
            println("did receive launch options: \(launchOptions)")
        } else {
            let launchOptions = [NSObject: AnyObject]()
            // did not receive any launch options sending empty options to PFFacebookUtils
            PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        }
//        PFFacebookUtils.initializeFacebook()
        
        
        PFTwitterUtils.initializeWithConsumerKey(KeysAndSecrets.twitterConsumerKey, consumerSecret: KeysAndSecrets.twitterConsumerSecret)
            
        // ****************************************************************************
            
//        PFUser.enableAutomaticUser()
//        PFUser.currentUser().incrementKey("RunCount")
//        PFUser.currentUser().saveInBackground()
        
        // setup the default appearances here
        let navbar = UINavigationBar.appearance()
        navbar.barTintColor = UIColor(red: 255.0/255, green: 215.0/255, blue: 0.0/255, alpha: 1.0)
        let font = UIFont(name: "Avenir", size: 20)
        navbar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: font!]
        navbar.tintColor = UIColor.blueColor()
        
        
        let toolbar = UIToolbar.appearance()
        toolbar.barTintColor = UIColor(red: 255.0/255, green: 215.0/255, blue: 0.0/255, alpha: 1.0)
        toolbar.tintColor = UIColor.blueColor()
        
        let defaultACL = PFACL();
            
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        defaultACL.setPublicWriteAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
            
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
                
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            println("There is no support for versions other than iOS 8.0")
//            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
//            application.registerForRemoteNotificationTypes(types)
        }
            
        return true
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
        
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded, error) -> Void in
            if succeeded {
                println("LimoService App successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("LimoService App failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }
        
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        println("User info in didReceiveNotification = \(userInfo)")
//        // post a notification when a GPX file arrives
//        let center = NSNotificationCenter.defaultCenter()
//        let notification = NSNotification(name: PushNotifications.Notification, object: self, userInfo: [PushNotifications.Key:userInfo])
//        center.postNotification(notification)
//
//        PFPush.handlePush(userInfo)
//        
//        if application.applicationState == UIApplicationState.Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }
    
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        println(notificationSettings.types.rawValue)
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // Do something serious in a real app.
        println("Received Local Notification:")
        println(notification.alertBody)
    }
    
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if identifier == "editList" {
            NSNotificationCenter.defaultCenter().postNotificationName("modifyListNotification", object: nil)
        }
        else if identifier == "trashAction" {
            NSNotificationCenter.defaultCenter().postNotificationName("deleteListNotification", object: nil)
        }
        
        completionHandler()
    }
    
        
    /////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    /////////////////////////////////////////////////////////
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        println("Received this message ......\(userInfo)")
        
        
        if let limoreqId: String = userInfo["limoreq"] as? String {
            let limoRequest = LimoRequest(withoutDataWithObjectId: limoreqId)
            limoRequest.fetchInBackgroundWithBlock { (object, error) in
                if error != nil {
                    completionHandler(UIBackgroundFetchResult.Failed)
                } else if PFUser.currentUser() != nil {
                    completionHandler(UIBackgroundFetchResult.NewData)
                     // post a notification after pinning this request record
                    limoRequest.pinInBackgroundWithBlock() { (succeeded, error) in
                        if succeeded {
                            let center = NSNotificationCenter.defaultCenter()
                            let notification = NSNotification(name: PushNotifications.Notification, object: self, userInfo: userInfo)
                            center.postNotification(notification)
                        }
                    }
                    if let numbags = object?["numBags"] as? NSNumber {
                        println("numBags = \(numbags)")
                    }
                } else {
                    completionHandler(UIBackgroundFetchResult.NoData)
                }
            }
        }
        
        
//        PFPush.handlePush(userInfo)
        

        completionHandler(.NoData)
    }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

