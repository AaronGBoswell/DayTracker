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
    internal var activities : [Activity]{
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
            for unit in newValue
            {
                newActions.append(unit.action)
                newDates.append(unit.date)
                newLengths.append(unit.length)
                
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
    var possibleActions : [String]{
        get{ return defaults.objectForKey(Settings.possibleActionsKey) as? [String] ?? ["Working", "Playing","Eating"] }
        set{ defaults.setObject(newValue, forKey:Settings.possibleActionsKey) }
    }
    
    
    
    
    
    private struct Settings {
        
        static let actionsKey = "Tracker.Actions"
        static let datesKey = "Tracker.Date"
        static let lengthsKey = "Tracter.length"
        static let possibleActionsKey = "Tracter.PossibleActions"
       
    }
    
    
    
    
    
    func  setCurrentActivity(current: Activity) {
        activities.append(current)
    }
    
    
    
    
    
    
    func  setCurrentActivity(currentAction: String, currentDate: NSDate, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: currentDate, length: theLength)
        print("in setCurrentActivity")
        print(current)
        activities.append(current)
    }
    
    
    
    
    
    
    func  setCurrentActivity(currentAction: String, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: NSDate().roundDateToThirtyMinutes(), length: theLength)
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String) {
        let current : Activity = Activity(action: currentAction, date: NSDate().roundDateToThirtyMinutes(), length: 30)
        activities.append(current)
    }
    
    
    func setActivity(pastAction: String, pastDate: NSDate, theLength: Int)
    {
        if let index = dates.indexOf(pastDate)
        {
            if lengths[index] == theLength{
                activities[index].action = pastAction
            } else if lengths[index] >= theLength
            {
                activities[index].action = pastAction
                activities[index].length = theLength
            }else if lengths[index] <= theLength
            {
                activities[index].action = pastAction
                activities[index].length = theLength
                for _ in 0 ... theLength/15 {
                    
                    if let indexx = dates.indexOf(pastDate.dateInFifteenMinutes()){
                        activities.removeAtIndex(indexx)
                    }
                }
            }
        
        } else{
            let addActivity : Activity = Activity(action: pastAction, date: pastDate, length: theLength)
            activities.append(addActivity)
            for _ in 0 ... theLength/15 {
                
                if let indexx = dates.indexOf(pastDate.dateInFifteenMinutes()){
                    activities.removeAtIndex(indexx)
                }
            }

            
        }

    }
    
    func addPossibleActivity(activity: String){
        possibleActions.append(activity)
        
    }
    func deletePossibleActivity(activity: String){
        
        possibleActions.removeAtIndex(possibleActions.indexOf(activity)!)
        
    }
    
    func predictActivities(dateFor: NSDate) -> [String]?{
        
       // var PA = [String]()
       // PA.append(activities[activities.count - 1].action)
       // PA.append("Work")
       // PA.append("Eat")
       // return PA
        
    
        
        
        
        return ["Working", "Playing","Eating"]
        
        
        
        
        
        
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
