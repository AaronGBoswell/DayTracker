//
//  NotificationManager.swift
//  DayTracker
//
//  Created by Aaron Boswell on 7/27/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import Foundation
import UIKit

class NotificationManager {
    static let sharedNotificationManager = NotificationManager()
    
    var pendingNoteNotification:Bool = false
    func consolidateNotifications(){
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            var newestPastNotification: UILocalNotification?
            for notification in notifications{
                if notification.category == "noteCategory"{
                    continue
                }
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
    func cancelAllNotifications(){
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications{
                cancelNotification(notification)
            }
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = -1

    }
    func cancelNotification(notification:UILocalNotification){
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    func checkCurrentNotifications(){
        print("Check start")
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications{
                print(notification.fireDate)
            }
            print(notifications.count)
        }
        print("Check Complete")

    }

    func scheduleNotifications(){
        let date = NSDate().dateForNextTimeSlice(Tracker.sharedTracker.settings.timeSlice)
        scheduleNotificationsStartingWithDate(date)
    }
    func scheduleNotificationsStartingWithDate(var date:NSDate){
        for _ in 1...10{
            if let notification = notificationForDate(date){
                cancelNotification(notification)
            }
            scheduleNotificationForDate(date)
            date = date.dateForNextTimeSlice(Tracker.sharedTracker.settings.timeSlice)
        }
        
    }
    func cancelPastNotifications(){
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
            let date = NSDate().dateByAddingTimeInterval(60)
            if date.laterDate(notification.fireDate!) == date{
                cancelNotification(notification)
            }
        }
    }
    func notificationForDate(date:NSDate) -> UILocalNotification?{
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications{
                if notification.fireDate == date{
                    return notification
                }
            }
        }
        return nil
    }
    func scheduleNotificationForDate(date:NSDate, bypassSleep : Bool = false){
        if(!bypassSleep){
            if Tracker.sharedTracker.SleepUntil != nil {
                if  date.dateByAddingTimeInterval(60).laterDate(Tracker.sharedTracker.SleepUntil!) == Tracker.sharedTracker.SleepUntil! {
                    return
                } else{
                    
                }
                
            }
        }
        refreshCategoryForDate(date)
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = date.description
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.alertBody = "What have you been doing?"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print(date.humanDate)
        print("scheduled")
        
    }
    
    func scheduleNotificationWithCategoryForNow(category:String){
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = category
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.alertBody = "What have you been doing?"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        //print(date.humanDate)
        print("scheduled")
        
    }
    
    
    func fireNoteNotification(){
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = "noteCategory"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.alertBody = " "        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("Note scheduled")
        pendingNoteNotification = true
        
    }
    func refreshCategoryForDate(date:NSDate){
        guard   var strings = Tracker.sharedTracker.predictActivities(date),
                let groups = Tracker.sharedTracker.predictGroup(date) else{
            return
        }
        
        if Tracker.sharedTracker.predictSleep(date) {
            strings.insert("Good Night", atIndex: 0)
        }
        makeCategoryWithOptions(strings, minimalOptions : groups, identifier: date.description)
        
    }
    func makeCategoryWithOptions(options: [String], minimalOptions:[String]? = nil, identifier:String){
        let newCategory = UIMutableUserNotificationCategory()
        var actions = [UIMutableUserNotificationAction]()
        for string in options{
            let action = UIMutableUserNotificationAction()
            action.title = string
            action.identifier = string
            if string == "Good Night" {
                action.identifier = "::"+string
            }
            action.activationMode = UIUserNotificationActivationMode.Background
            action.authenticationRequired = false
            actions.append(action)
        }
        if let minOptions = minimalOptions{
            var minimalActions = [ UIMutableUserNotificationAction]()
            for string in minOptions{
                let action = UIMutableUserNotificationAction()
                action.title = string
                action.identifier = "/"+string
                action.activationMode = UIUserNotificationActivationMode.Background
                action.authenticationRequired = false
                minimalActions.append(action)
            }
            newCategory.setActions(minimalActions, forContext: UIUserNotificationActionContext.Minimal)
        }
        newCategory.setActions(actions, forContext: UIUserNotificationActionContext.Default)
        newCategory.identifier = identifier
        let newCategories = NSMutableSet()
        if let categories = UIApplication.sharedApplication().currentUserNotificationSettings()?.categories{
            for category in categories {
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
        let settings = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: categories as? Set<UIUserNotificationCategory>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    func alertFromNotification(notification:UILocalNotification) -> UIAlertController?{
        guard let category = currentCategoryForIdentifier(notification.category) else{
            return nil
        }
        if category.identifier == "noteCategory"{
            let alert = UIAlertController(title: "Add a note", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                if let tf = alert.textFields?.first as UITextField! {
                    Tracker.sharedTracker.setNote(tf.text ?? "", date: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice))
                } 

            }))
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.placeholder = "Note"
            })
            return alert
        }
        guard let notificationActions = category.actionsForContext(UIUserNotificationActionContext.Default) else{
                return nil
        }
        var uiActions = [UIAlertAction]()
        for notificationAction in notificationActions {
            guard   let identifier = notificationAction.identifier,
                    let title = notificationAction.title else{continue}
            let action = UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.responseWithIdentifier(identifier)
            })

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
    func responseWithIdentifier(identifier:String){
        pendingNoteNotification = false
        UIApplication.sharedApplication().applicationIconBadgeNumber = -1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0

        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
            self.cancelPastNotifications()
            print(identifier)
            if identifier.hasPrefix("/") {
                let group = identifier.substringFromIndex(identifier.startIndex.successor())
                if let activities = Tracker.sharedTracker.predictActivities(NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice), fromGroup: group){
                    self.makeCategoryWithOptions(activities, identifier: group)
                    self.scheduleNotificationWithCategoryForNow(group)
                } else{
                    
                    
                    print(group + "doesnt exist as a gorup")
                }
                
            }else if identifier.hasPrefix("::") {
                self.cancelAllNotifications()
                let sleepTime = NSDate().dateForNext(Tracker.sharedTracker.settings.wakeHour, minute: Tracker.sharedTracker.settings.wakeMinute)
                Tracker.sharedTracker.SleepUntil = sleepTime
                self.scheduleNotificationsStartingWithDate(NSDate().dateForNext(Tracker.sharedTracker.settings.wakeHour, minute: Tracker.sharedTracker.settings.wakeMinute))
                Tracker.sharedTracker.sleepSelected(NSDate())
                self.checkCurrentNotifications()

            }else {
                Tracker.sharedTracker.setCurrentActivity(identifier, currentDate: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice), theLength: Tracker.sharedTracker.settings.timeSlice)
                if Tracker.sharedTracker.activityDetails(identifier)?.note == true{
                    self.fireNoteNotification()
                    self.checkCurrentNotifications()
                }
                self.scheduleNotifications()
            }

            self.checkCurrentNotifications()
        }

    }
}
extension NSDate{
    func dateForNextTimeSlice(timeSlice: Int) -> NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)
        
        comps.minute = comps.minute + timeSlice
        comps.minute = (comps.minute / timeSlice ) * timeSlice
        
        let date = cal.dateFromComponents(comps)
        
        return date!
    }
    func dateForNext(hour: Int, minute: Int) -> NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)
        if comps.hour > hour{
            comps.day++
        }
        comps.minute = minute
        comps.hour = hour

        let date = cal.dateFromComponents(comps)
        return date!
    }
    func roundDateDownToTimeSlice(timeSlice: Int)->NSDate{
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: self)
        comps.minute = comps.minute + 1
        comps.minute = (comps.minute / timeSlice ) * timeSlice
        
        let date = cal.dateFromComponents(comps)
        
        return date!
    }
    var humanDate :String {
        get{
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.NoStyle
            formatter.timeStyle = .ShortStyle
            
            return formatter.stringFromDate(self)
        }
    }
}