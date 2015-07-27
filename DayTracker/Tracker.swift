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
    internal let settings = TrackerSettings()
    internal var activities : [Activity]{
        get{
            var newActivities = [Activity]()
            for activityDictionary in allActivities
            {
                let addition : Activity = Activity(action: activityDictionary["action"] as! String, date: activityDictionary["date"] as! NSDate, length: activityDictionary["length"] as! Int, note: activityDictionary["note"] as! String)
                newActivities.append(addition)
            }
            return newActivities
        }
        set{
            
            var newActions = [[String:AnyObject]]()
            for unit in newValue
            {
                var newAction = [String:AnyObject]()

                newAction["action"] =  unit.action
                newAction["date"] = unit.date
                newAction["length"] = unit.length
                newAction["note"] = unit.note
                newActions.append( newAction )
            }
           allActivities = newActions
            
        }
    }
    
    struct TrackerSettings{
        var timeSlice: Int = 15
    }
    struct Activity: CustomStringConvertible
    {
        var action : String
        var date : NSDate
        var length : Int
        var note : String
        
        
        internal init( action: String, date: NSDate, length : Int, note : String)
        {
            self.action = action
            self.date = date
            self.length = length
            self.note = note
            
            return
            
        }
        
        var description : String { get { return "Action : \(action) Date : \(date.humanDate) Length : \(length) Note : \(note)"} }
        
        //public var descritpion:String { get {return "hey"}}
        
    }
    struct ActivitySetting
    {
        var action : String
        var note : Bool
        var productive : Bool
        
        
        internal init( action: String, note: Bool, productive : Bool)
        {
            self.action = action
            self.note = note
            self.productive = productive
            
            return
            
        }
        
        
    }
    
    internal var activityBag : [ActivitySetting]{
        get{
            var newActivities = [ActivitySetting]()
            for activityDictionary in possibleActions
            {
                let addition : ActivitySetting = ActivitySetting(action: activityDictionary["action"] as! String, note: activityDictionary["note"] as! Bool, productive: activityDictionary["productive"] as! Bool)
                newActivities.append(addition)
            }
            return newActivities
        }
        set{
            
            var newActions = [[String:AnyObject]]()
            for unit in newValue
            {
                var newAction = [String:AnyObject]()
                
                newAction["action"] =  unit.action
                newAction["note"] = unit.note
                newAction["productive"] = unit.productive
                newActions.append( newAction )
            }
            possibleActions = newActions
            
        }
    }


    
    
   
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
  
    
    
    var possibleActions : [[String:AnyObject]]{
        get{ return defaults.objectForKey(Settings.possibleActionsKey) as? [[String:AnyObject]] ?? [["action" : "Work" , "note" :true, "productive" : true ], ["action" : "Play" , "note" :true, "productive" : false], ["action" : "Eat" , "note" :false, "productive" : false]] }
        set{ defaults.setObject(newValue, forKey:Settings.possibleActionsKey) }
    }
    
    
    var allActivities : [[String:AnyObject]] {
        get{ return defaults.objectForKey(Settings.allActivities) as? [[String:AnyObject]] ?? [] }
        set{ defaults.setObject(newValue, forKey:Settings.allActivities) }
    }
    
    
    struct Settings {
        static let possibleActionsKey = "Tracker.PossibleActions"
        static let allActivities = "Tracker.allActivities"
    }
    
    func  setCurrentActivity(current: Activity) {
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String, currentDate: NSDate, theLength: Int, note:String) {
        let current : Activity = Activity(action: currentAction, date: currentDate, length: theLength, note: note)
        print("in setCurrentActivity")
        print(current)
        activities.append(current)
    }
    
    func  setCurrentActivity(currentAction: String, currentDate: NSDate, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: currentDate, length: theLength, note: "")
        print("in setCurrentActivity")
        print(current)
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String, theLength: Int) {
        let current : Activity = Activity(action: currentAction, date: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice), length: theLength,  note: "")
        activities.append(current)
    }
    func  setCurrentActivity(currentAction: String) {
        let current : Activity = Activity(action: currentAction, date: NSDate().roundDateDownToTimeSlice(Tracker.sharedTracker.settings.timeSlice), length: 30 , note: "")
        activities.append(current)
    }
    func setNote(note: String, date: NSDate){
        
        var test : NSDate
        for (index, unit) in activities.enumerate()
        {
            test = unit.date
            if test == date
            {
                activities[index].note = note
                //unit.note = note
                print(note)
                print("noteSuccess")
         
            }
        }
        print("note ran")
        print(note)
        
    }

    
    

    
    func addPossibleActivity(activity: String,  note:Bool, productive: Bool){
        var newAction = [String:AnyObject]()
        
        newAction["action"] =  activity
        newAction["note"] =  note
        newAction["productive"] =  productive
        possibleActions.append(newAction)
        
    }
    
    
    func deletePossibleActivity(activity: String){
        
        var test : String
        for (index, unit) in activityBag.enumerate()
        {
           test = unit.action
            if test == activity
            {
                activityBag.removeAtIndex(index)
                
            }
        }
        
        //possibleActions.removeAtIndex(possibleActions.indexOf(activity)!)
        
    }
    
    func activityDetails(activity: String) -> ActivitySetting?{
        
        var test : String
        for unit in activityBag
        {
            test = unit.action
            if test == activity
            {
                return unit
                
            }
        }
        
        return nil
    }
    
    


    
    func predictActivities(dateFor: NSDate) -> [String]?{
        return ["Work", "Play","Eat"]
    }
    
    
    
    
    
    
    

}







