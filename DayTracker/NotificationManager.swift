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
        }
        if let categories = UIApplication.sharedApplication().currentUserNotificationSettings()?.categories{
            for category in categories{
                print(category.identifier)
            }
        }
        print("Check Complete")

    }

    func scheduleNotifications(){
        var date = NSDate().dateForNextTimeSlice(Tracker.sharedTracker.settings.timeSlice)
        for _ in 1...10{
            if let notification = notificationForDate(date){
                cancelNotification(notification)
            }
            scheduleNotificationForDate(date)
            date = date.dateForNextTimeSlice(Tracker.sharedTracker.settings.timeSlice)
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
        notification.fireDate = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.category = "noteCategory"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 0
        notification.alertBody = " "        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("Note scheduled")
        
    }
    func refreshCategoryForDate(date:NSDate){
        guard let strings = Tracker.sharedTracker.predictActivities(date) else{
            return
        }
        var actions = [UIMutableUserNotificationAction]()
        for string in strings{
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
        if category == "noteCategory"{
            var alert = UIAlertController(title: "Add a note", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
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
            let
            action = UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
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
        consolidateNotifications()
        print(identifier)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        Tracker.sharedTracker.setCurrentActivity(identifier, currentDate: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice), theLength: Tracker.sharedTracker.settings.timeSlice)
        scheduleNotifications()
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
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            
            return formatter.stringFromDate(self)
        }
    }
}