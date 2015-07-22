//
//  AppDelegate.swift
//  DayTracker
//
//  Created by Aaron Boswell on 7/22/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerSettingsAndCategories()
        scheduleNotification(true)
        
        // Override point for customization after application launch.
        return true
    }
    func scheduleNotification(soon:Bool){
        let notification = UILocalNotification()
        if soon {
            notification.fireDate = NSDate(timeIntervalSinceNow: 20)
        } else{
            notification.fireDate = NSDate(timeIntervalSinceNow: 60*5)
            
        }
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = "lastAction"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 0
        notification.alertBody = "What have you been doing?"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("scheduled")
        
    }
    func registerSettingsAndCategories() {
        
        let workAction = UIMutableUserNotificationAction()
        workAction.title = NSLocalizedString("Working", comment: "I've been working.")
        workAction.identifier = "working"
        workAction.activationMode = UIUserNotificationActivationMode.Background
        workAction.authenticationRequired = false
        
        let playAction = UIMutableUserNotificationAction()
        playAction.title = NSLocalizedString("Playing", comment: "I've been playing.")
        playAction.identifier = "playing"
        playAction.activationMode = UIUserNotificationActivationMode.Background
        playAction.authenticationRequired = false
        
        let eatAction = UIMutableUserNotificationAction()
        eatAction.title = NSLocalizedString("Eating", comment: "I've been eating.")
        eatAction.identifier = "eating"
        eatAction.activationMode = UIUserNotificationActivationMode.Background
        eatAction.authenticationRequired = false
        
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.setActions([workAction, playAction,eatAction],
            forContext: UIUserNotificationActionContext.Default)
        inviteCategory.identifier = "lastAction"
        
        let categories = NSSet(object: inviteCategory)
        
        // Configure other actions and categories and add them to the set...
        //var types = UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue
        //var ts: UIUserNotificationType = types as! UIUserNotificationType
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: categories as? Set<UIUserNotificationCategory>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
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
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //    notification.category
        
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        print(identifier)
        history += [identifier!]
        time += [NSDate()]
        scheduleNotification(false)
        completionHandler()
    }
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var history : [String]{
        get{ return defaults.objectForKey(Default.History) as? [String] ?? [] }
        set{ defaults.setObject(newValue, forKey: Default.History) }
        
    }
    var time : [NSDate]{
        get{ return defaults.objectForKey(Default.Time) as? [NSDate] ?? [] }
        set{ defaults.setObject(newValue, forKey: Default.Time) }
        
    }
    private struct Default{
        static let History = "WhatDoing.History"
        static let Time = "WhatDoing.Time"
    }
    


}

