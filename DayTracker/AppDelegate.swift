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
        



        */
        
        //Tracker.sharedTracker.resetThingToDo()
        
        //Tracker.sharedTracker.SleepUntil = nil
        print( Tracker.sharedTracker.SleepUntil)
        NotificationManager.sharedNotificationManager.registerNoteAction()
        NotificationManager.sharedNotificationManager.scheduleNotifications()
        NotificationManager.sharedNotificationManager.checkCurrentNotifications()
        NotificationManager.sharedNotificationManager.cancelPastNotifications()
       // NotificationManager.sharedNotificationManager.scheduleNotificationForDate(NSDate().dateByAddingTimeInterval(10), bypassSleep: true)

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
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
            let date = NSDate()
            if date.laterDate(notification.fireDate!) == date{
                print(notification.description)
                if let alert = NotificationManager.sharedNotificationManager.alertFromNotification(notification){
                    print(alert.description)
                    let rootViewController = self.window!.rootViewController
                    rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
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
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("receivedNoty")
        print(notification.description)
        if let alert = NotificationManager.sharedNotificationManager.alertFromNotification(notification){
            print(alert.description)
            let rootViewController = self.window!.rootViewController
            rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
        NotificationManager.sharedNotificationManager.cancelNotification(notification)
        print("outrecivedNoty")


    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if let note = responseInfo[UIUserNotificationActionResponseTypedTextKey] as? String{
            Tracker.sharedTracker.setNote(note, date: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice))
            print(note)
            UIApplication.sharedApplication().applicationIconBadgeNumber--
        } else if identifier != nil {
            NotificationManager.sharedNotificationManager.responseWithIdentifier(identifier!)
        }
        NotificationManager.sharedNotificationManager.checkCurrentNotifications()
        completionHandler()
    }




}


