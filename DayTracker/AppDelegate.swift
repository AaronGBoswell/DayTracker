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
        
        
        //Tracker.sharedTracker.ThingsToDo =  [["action" : "Programing" , "note" :true, "productive" : "Job", "pushToFront" : 0, "color" : 1 ], ["action" : "Yard Work" , "note" :true, "productive" : "Job" , "pushToFront" : 0 , "color" : 1], ["action" : "Television" , "note" :false, "productive" : "Entertainment" , "pushToFront" : 0 , "color" : 2], ["action" : "Relaxing" , "note" :false, "productive" : "Entertainment" , "pushToFront" : 0 , "color" : 2], ["action" : "Gaming" , "note" :false, "productive" : "Entertainment" , "pushToFront" : 0 , "color" : 2],["action" : "Eat" , "note" :false, "productive" : "Nutrition" , "pushToFront" : 0 , "color" : 3]]
        



        
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
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in

            NotificationManager.sharedNotificationManager.registerNoteAction()
            NotificationManager.sharedNotificationManager.scheduleNotifications()
            NotificationManager.sharedNotificationManager.checkCurrentNotifications()
            NotificationManager.sharedNotificationManager.cancelPastNotifications()
        }
        //NotificationManager.sharedNotificationManager.scheduleNotificationForDate(NSDate().dateByAddingTimeInterval(10), bypassSleep: true)

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
            NotificationManager.sharedNotificationManager.refreshCategoryForDate(date)
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.category = date.description
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            notification.alertBody = "What have you been doing?"
            
            if let alert = NotificationManager.sharedNotificationManager.alertFromNotification(notification){
                print("pushingAlert")
                pushAlert(alert)
            }
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
    func pushAlert(alert:UIAlertController){
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        print(rootViewController)
        if let badAlert = rootViewController?.presentedViewController as? UIAlertController{
            badAlert.dismissViewControllerAnimated(false){
                rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else{
            rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("receivedNoty")
        print(notification.description)
        if let lastActionTime = Tracker.sharedTracker.activities.last?.date {
            if lastActionTime == NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice){
                if notification.category != "noteCategory"{
                    print("notshowingduplicatenoty")
                    return
                }
            }
        }
        if let alert = NotificationManager.sharedNotificationManager.alertFromNotification(notification){
            pushAlert(alert)
        }
        NotificationManager.sharedNotificationManager.cancelNotification(notification)
        print("outrecivedNoty")


    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
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


