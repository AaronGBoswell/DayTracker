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
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        registerNoteAction()
        
        fireNoteNotification()
        //registerSettingsAndCategories()
        startScheduleTimer()
        checkCurrentNotifications()
        startConsolidationTimer()
       // scheduleNotification(true)

        return true
    }
    func startConsolidationTimer(){
        let timer = NSTimer.scheduledTimerWithTimeInterval(60*15, target: self, selector: "consolidateNotifications:", userInfo: nil, repeats: true)
        timer.tolerance = 60*5
        timer.fire()
    }
    func consolidateNotifications(timer:NSTimer?){
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            var newestPastNotification: UILocalNotification?
            for notification in notifications{
                guard let date = notification.fireDate else{
                    cancelNotification(notification)
                    continue
                }
                if date.laterDate(NSDate()) == NSDate(){
                    if newestPastNotification != nil {
                        if date.laterDate((newestPastNotification?.fireDate)!) == date {
                            cancelNotification(newestPastNotification!)
                            newestPastNotification = notification
                        } else{
                            cancelNotification(notification)
                        }
                    } else{
                        newestPastNotification = notification
                    }
                }
            }
        }
    }

    func cancelNotification(notification:UILocalNotification){
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    func checkCurrentNotifications(){
        print("Check start")
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications{
                print(notification.fireDate?.humanDate)
            }
            print(notifications.count)
            print("Check Complete")
        }

    }
    func startScheduleTimer(){
        let timer = NSTimer.scheduledTimerWithTimeInterval(60*60, target: self, selector: "schedule:", userInfo: nil, repeats: true)
        timer.tolerance = 60*30
        timer.fire()
    }
    func schedule(timer:NSTimer){
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        var date = NSDate().dateInThirtyMinutes()
        for _ in 1...10{
            scheduleNotificationForDate(date)
            date = date.dateInThirtyMinutes()
        }
    }
    func notificationExistsForDate(date:NSDate) -> Bool{
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications{
                if notification.fireDate == date{
                    return true
                }
            }
        }
        return false
    }
    func scheduleNotificationForDate(date:NSDate){
        refreshCategoryForDate(date)
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = date.description
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 0
        notification.alertBody = "What have you been doing?"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print(date.humanDate)
        print("scheduled")
        
    }
    func fireNoteNotification(){
        let notification = UILocalNotification()
        notification.fireDate = NSDate().dateByAddingTimeInterval(0)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = "noteCategory"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 0
        notification.alertBody = " "
        //notification.alertAction = "Submit"

        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("Note scheduled")
        
    }
    func refreshCategoryForDate(date:NSDate){
        guard let strings = Tracker.sharedTracker.predictActivities(date) else{
            return
        }
        var actions = [UIMutableUserNotificationAction]()
        for var string in strings{
            let action = UIMutableUserNotificationAction()
            action.title = string
            action.identifier = string
            action.activationMode = UIUserNotificationActivationMode.Background
            action.authenticationRequired = false
            actions.append(action)
        }
        let newCategory = UIMutableUserNotificationCategory()
        newCategory.setActions(actions, forContext: UIUserNotificationActionContext.Default)
        newCategory.identifier = date.description
        var newCategories = NSMutableSet()
        if let categories = UIApplication.sharedApplication().currentUserNotificationSettings()?.categories{
            for var category in categories {
                if category.identifier != newCategory.identifier {
                    newCategories.addObject(category)
                }
            }
        }
        newCategories.addObject(newCategory)
        let set = NSSet(set:newCategories)
        let settings = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: set as? Set<UIUserNotificationCategory>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
    }
    func registerNoteAction() {

        let noteAction = UIMutableUserNotificationAction()
        noteAction.title = "Add Note"
        noteAction.behavior = .TextInput
        noteAction.identifier = "activity.Note"
        noteAction.activationMode = UIUserNotificationActivationMode.Background
        noteAction.authenticationRequired = false
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.setActions([noteAction],forContext: UIUserNotificationActionContext.Default)

        inviteCategory.identifier = "noteCategory"
        
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
        if let alert = alertFromNotification(notification){
            let rootViewController = self.window!.rootViewController
            rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }

    }
    func alertFromNotification(notification:UILocalNotification) -> UIAlertController?{
        guard let category = currentCategoryForIdentifier(notification.category),
            let notificationActions = category.actionsForContext(UIUserNotificationActionContext.Default) else{
                return nil
        }
        var uiActions = [UIAlertAction]()
        for notificationAction in notificationActions {
            guard   let identifier = notificationAction.identifier,
                let title = notificationAction.title else{continue}
            let
            action = UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.responseWithIdentifier(identifier)
            })
            // var action = UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: {[unowned self] in self.responseWithIdentifier(identifier)})
            uiActions.append(action)
            
        }
        let title = notification.alertTitle
        let message = notification.alertBody
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        for action in uiActions{
            alert.addAction(action)
        }
        return alert

    }
    func currentCategoryForIdentifier(identifier:String?) -> UIUserNotificationCategory?{
        if identifier != nil{
            if let categories = UIApplication.sharedApplication().currentUserNotificationSettings()?.categories{
                for category in categories{
                    if category.identifier == identifier{
                        return category
                    }
                }
            }
        }
        return nil
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if var note = responseInfo[UIUserNotificationActionResponseTypedTextKey]{
            print(note)
        } else if identifier != nil {
            responseWithIdentifier(identifier!)
            fireNoteNotification()

        }

        completionHandler()
    }

    func responseWithIdentifier(identifier:String){
        consolidateNotifications(nil)
        print(identifier)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        Tracker.sharedTracker.setCurrentActivity(identifier, currentDate: NSDate().roundDateToThirtyMinutes(), theLength: 30)
    }


}
extension NSDate{
    func dateInThirtyMinutes() -> NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)

        comps.minute = comps.minute + 30
        comps.minute = (comps.minute / 30 ) * 30

        let date = cal.dateFromComponents(comps)

        return date!
    }
    func dateInFifteenMinutes() -> NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)
        
        comps.minute = comps.minute + 15
        comps.minute = (comps.minute / 15 ) * 15
        
        let date = cal.dateFromComponents(comps)
        
        return date!
    }
    func roundDateToThirtyMinutes()->NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)
        
        comps.minute = (comps.minute / 30 ) * 30
        
        let date = cal.dateFromComponents(comps)
        
        return date!
    }
    
}

