//
//  Tracker.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/22/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import Foundation

class Tracker {
    
    static let sharedTracker = Tracker()
    var activities : [Activity]{
        get{
            var newActivities = [Activity]()
            for (index, unit) in dates.enumerate()
            {
                let addition : Activity = Activity(action: actions[index], date: unit, length: lengths[index])
                newActivities.insert(addition, atIndex: index)
            }
            return newActivities
        }
        set{
            var newActions = [String]()
            var newDates = [NSDate]()
            var newLengths = [Int]()
            for (index, unit) in activities.enumerate()
            {
                newActions.insert(unit.action, atIndex: index)
                newDates.insert(unit.date, atIndex: index)
                newLengths.insert(unit.length, atIndex: index)
                
            }
            actions = newActions
            dates = newDates
            lengths = newLengths
            
        }
    }
    
    
    struct Activity: CustomStringConvertible
    {
        var action : String
        var date : NSDate
        var length : Int
        
        
        internal init( action: String, date: NSDate, length : Int)
        {
            self.action = action
            self.date = date
            self.length = length
            
            return
            
        }
        
        var description : String { get { return "Action : \(action)" + "Date : \(date.humanDate)" + "Length : \(length)"} }
        
        //public var descritpion:String { get {return "hey"}}
        
    }

    
   
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var actions : [String]{
        get{ return defaults.objectForKey(Settings.actionsKey) as? [String] ?? [] }
        set{ defaults.setObject(newValue, forKey:Settings.actionsKey) }
    }
    var dates : [NSDate]{
        get{ return defaults.objectForKey(Settings.datesKey) as? [NSDate] ?? [] }
        set{ defaults.setObject(newValue, forKey:Settings.datesKey) }
    }
    var lengths : [Int]{
        get{ return defaults.objectForKey(Settings.lengthsKey) as? [Int] ?? [] }
        set{ defaults.setObject(newValue, forKey:Settings.lengthsKey) }
    }
    
    
    
    
    
    private struct Settings {
        
        static let actionsKey = "Tracker.Actions"
        static let datesKey = "Tracker.Date"
        static let lengthsKey = "Tracter.length"
       
    }
    
    
    
    
    
    func  setCurrentActivity(current: Activity) {
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String, currentDate: NSDate, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: currentDate, length: theLength)
        activities.append(current)
    }
    
    func  setCurrentActivity(currentAction: String, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: NSDate(), length: theLength)
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String) {
        let current : Activity = Activity(action: currentAction, date: NSDate(), length: 30)
        activities.append(current)
    }
    
    
    
  
    
    

    
    
}
extension NSDate{
    var humanDate :String {
        get{
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            
            return formatter.stringFromDate(self)
        }
    }
}
