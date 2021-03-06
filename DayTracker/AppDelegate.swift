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
        
      
        print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)



        
        //Tracker.sharedTracker.resetThingToDo()
        
        //Tracker.sharedTracker.SleepUntil = nil
        UINavigationBar.appearance().barTintColor = UIColor(red: 2.0/255.0, green: 77.0/255.0, blue: 109.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
       // UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
        UINavigationBar.appearance().translucent = true
        UITabBar.appearance().tintColor = UIColor(red: 2.0/255.0, green: 77.0/255.0, blue: 109.0/255.0, alpha: 1.0)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        print( Tracker.sharedTracker.SleepUntil)
        
        //let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        //dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
        UIApplication.sharedApplication().cancelAllLocalNotifications()
            NotificationManager.sharedNotificationManager.cancelAllNotifications()
            NotificationManager.sharedNotificationManager.registerNoteAction()
            NotificationManager.sharedNotificationManager.scheduleNotifications()
            NotificationManager.sharedNotificationManager.checkCurrentNotifications()
            NotificationManager.sharedNotificationManager.cancelPastNotifications()
            //NotificationManager.sharedNotificationManager.scheduleNotificationForDate(NSDate().dateByAddingTimeInterval(10), bypassSleep: true)

        //}

       // NotificationManager.sharedNotificationManager.fireNoteNotification()

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
        print("willenterforground")
        if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
            let date = NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice)

            let notification = UILocalNotification()
            notification.fireDate = date
            notification.timeZone = NSTimeZone.defaultTimeZone()
            if NotificationManager.sharedNotificationManager.pendingNoteNotification == true{
                notification.category = "noteCategory"

            } else{
                NotificationManager.sharedNotificationManager.refreshCategoryForDate(date, groupBranch: true)
                notification.category = date.description
            }
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            notification.alertBody = "What have you been doing?"
            
            pushAlert(notification)

        }
        print("Donewillenterforground")

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func pushAlert(notification:UILocalNotification){
        if let lastActionTime = Tracker.sharedTracker.activities.last?.date {
            if lastActionTime == NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice){
                if notification.category != "noteCategory"{
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                    print("notshowingduplicatenoty")
                    return
                }
            }
        }
        guard let alert = NotificationManager.sharedNotificationManager.alertFromNotification(notification) else{return}
        
        
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        print(rootViewController)
        if let badAlert = rootViewController?.presentedViewController as? UIAlertController{
            print(badAlert)
        }
        else{
            rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("receivedNoty")
        print(notification.description)

        pushAlert(notification)

        NotificationManager.sharedNotificationManager.cancelNotification(notification)
        print("outrecivedNoty")


    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print(identifier)
        if let note = responseInfo[UIUserNotificationActionResponseTypedTextKey] as? String{
            Tracker.sharedTracker.setNote(note, date: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice))
            print(note)
        } else if identifier != nil {
            NotificationManager.sharedNotificationManager.responseWithIdentifier(identifier!)
        }
        NotificationManager.sharedNotificationManager.checkCurrentNotifications()
        completionHandler()
    }




}


