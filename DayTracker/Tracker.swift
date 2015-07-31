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
        var productive : String
        
        
        internal init( action: String, note: Bool, productive : String)
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
                let addition : ActivitySetting = ActivitySetting(action: activityDictionary["action"] as! String, note: activityDictionary["note"] as! Bool, productive: activityDictionary["productive"] as! String)
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



    var actionsByGroup : [[ActivitySetting]] {
        get{
            var returnArray = [[ActivitySetting]]()
            for activity in activityBag{
                let type = activity.productive
                var added = false
                for (index, arr) in returnArray.enumerate(){
                    if arr.first?.productive == type{
                        returnArray[index].append(activity)
                        added = true
                    }
                }
                if added == false {
                    var temp = [ActivitySetting]()
                    temp.append(activity)
                    returnArray.append(temp)
                }
            }
            return returnArray
        }
        
    
        
        
        
    }
    
    var todaysArray : [Activity] {
        let date = NSDate()
        var returnArray = [Activity]()
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        
        
        
        for unit in activities{
            let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            
            if dateComponents.month == unitComponents.month && dateComponents.year == unitComponents.year && dateComponents.day == unitComponents.day {
                returnArray.append(unit)
            }
        }
        return returnArray
        
        
    }
    
    
    var todaysOrginizedArray : [[Activity]] {
        let date = NSDate()
        var returnArray = [[Activity]]()
        var early = [Activity]()
        var morning = [Activity]()
        var midday = [Activity]()
        var night = [Activity]()
        var late = [Activity]()
        
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        
        
        
        for unit in activities{
            let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            
            if dateComponents.month == unitComponents.month && dateComponents.year == unitComponents.year && dateComponents.day == unitComponents.day {
                if unitComponents.hour < 8 {
                    early.append(unit)
                } else if unitComponents.hour < 12 {
                    morning.append(unit)
                } else if unitComponents.hour < 16 {
                    midday.append(unit)
                } else if unitComponents.hour < 20 {
                    night.append(unit)
                } else if unitComponents.hour < 24 {
                    late.append(unit)
                }
            }
        }
       
        if early.first != nil{
            returnArray.append(early)
        }
        if morning.first != nil{
            returnArray.append(morning)
        }
        if midday.first != nil{
            returnArray.append(midday)
        }
        if night.first != nil{
            returnArray.append(night)
        }
        if late.first != nil{
            returnArray.append(late)
        }
        return returnArray
        
    }

    
    
    var groups : [String] {
        var returnArray =  [String]()
        for array in actionsByGroup{
            returnArray.append((array.first?.productive)!)
            
        }
        return returnArray

    }
    
    
   
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
  
    
    
    var possibleActions : [[String:AnyObject]]{
        get{ return defaults.objectForKey(Settings.possibleActionsKey) as? [[String:AnyObject]] ?? [["action" : "Programing" , "note" :true, "productive" : "Job" ], ["action" : "Yard Work" , "note" :true, "productive" : "Job" ], ["action" : "Television" , "note" :false, "productive" : "Entertainment"], ["action" : "Relaxing" , "note" :false, "productive" : "Entertainment"], ["action" : "Gaming" , "note" :false, "productive" : "Entertainment"],["action" : "Eat" , "note" :false, "productive" : "Nutrition"]] }
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
    
    func activitiesBasedOnGroup(group: String) -> [ActivitySetting] {
        
        
        for array in actionsByGroup{
            if array.first?.productive == group {
                return array
            }
        }
        
        // i know this is assanine
        return [ActivitySetting]()
        
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

    
    

    
    func addPossibleActivity(activity: String,  note:Bool, productive: String){
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
    
    func predictGroup(dateFor:NSDate) -> [String]?{
        var returnArray = [String]()
        for arr in actionsByGroup {
            returnArray.append((arr.first?.productive)!)
        }
        return returnArray
    }
    func predictActivities(dateFor:NSDate, fromGroup group:String) -> [String]?{
        var returnArray = [String]()
        for element in activitiesBasedOnGroup(group) {
            returnArray.append(element.productive)
        }
        return returnArray
    }


   
    func predictActivities(dateFor: NSDate) -> [String]?{
        return activityBag.map({ (element: ActivitySetting) -> String in
            return element.action
        })
        
        
    }
    
     /*
    func predictActivities(date: NSDate) -> [String]?{
        
   // let date = NSDate()
    var returnArray = [String]()
    let cal = NSCalendar.currentCalendar()
    let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
    
    
    
        for unit in activities{
        let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            if dateComponents.month == unitComponents.month && dateComponents.year == unitComponents.year && dateComponents.day == (unitComponents.day - 3) {
                if dateComponents.hour == (unitComponents.hour - 1) {
                    print(unit.action)
                    for unit2 in returnArray {
                        if unit2 != unit.action {
                            returnArray.append(unit.action)
                            print("added")
                        }
                    }
                }
   
    
            }
        
        }
        
        if returnArray.count < 3 && returnArray.count > 0 {
            for unit in activitiesBasedOnGroup((activityDetails(returnArray[0])?.productive)!){
                returnArray.append(unit.action)
            }
        }
        print(returnArray)
        return returnArray
    }

    
    */
    
    
    func getArrayForDate(date: NSDate) -> [Activity] {
        
        var returnArray = [Activity]()
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        
        
        
        for unit in activities{
            let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            
            if dateComponents.month == unitComponents.month && dateComponents.year == unitComponents.year && dateComponents.day == unitComponents.day {
                returnArray.append(unit)
            }
        }
        return returnArray
        
        
    }
    
    
    
    
    
    

}







