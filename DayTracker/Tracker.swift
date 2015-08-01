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
            for activityDictionary in RecordOf
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
           RecordOf = newActions
            
        }
    }
    
    struct TrackerSettings{
        var timeSlice: Int = 15
        var wakeHour = 8
        var wakeMinute = 0
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
            for activityDictionary in ThingsToDo
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
            ThingsToDo = newActions
            
        }
    }
    var activityStrings : [String]{
        return activityBag.map { (element) -> String in return element.action }
    }



    var activitiesByGroup : [[ActivitySetting]] {
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
            returnArray.sortInPlace { (one,two) -> Bool in
                if one.first?.productive < two.first?.productive{
                    return true
                }
                return false
            }
            for index in 0..<returnArray.count{
                returnArray[index].sortInPlace{(one,two) -> Bool in
                    if one.action < two.action{
                        return true
                    }
                    return false
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
        for array in activitiesByGroup{
            returnArray.append((array.first?.productive)!)
            
        }
        return returnArray

    }
    
    var averageSleepHour : Int {
        var total = 0
        for unit in SleepHour
        {
            total += unit
        }
        total = total/SleepHour.count
        print("Sleep Hour ")
        print(total)
        return total
    }
   
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
  
    
    
    var ThingsToDo : [[String:AnyObject]]{
        get{ return defaults.objectForKey(Settings.possibleActionsKey) as? [[String:AnyObject]] ?? [["action" : "Programing" , "note" :true, "productive" : "Job" ], ["action" : "Yard Work" , "note" :true, "productive" : "Job" ], ["action" : "Television" , "note" :false, "productive" : "Entertainment"], ["action" : "Relaxing" , "note" :false, "productive" : "Entertainment"], ["action" : "Gaming" , "note" :false, "productive" : "Entertainment"],["action" : "Eat" , "note" :false, "productive" : "Nutrition"]] }
        set{ defaults.setObject(newValue, forKey:Settings.possibleActionsKey) }
    }
    
    
    var RecordOf : [[String:AnyObject]] {
        get{ return defaults.objectForKey(Settings.allActivities) as? [[String:AnyObject]] ?? [] }
        set{ defaults.setObject(newValue, forKey:Settings.allActivities) }
    }
    var SleepHour : [Int] {
        get{ return defaults.objectForKey(Settings.sleep) as? [Int] ?? [21] }
        set{ defaults.setObject(newValue, forKey:Settings.sleep) }
    }
    
    struct Settings {
        static let possibleActionsKey = "Tracker.PossibleActions"
        static let allActivities = "Tracker.allActivities"
        static let sleep = "Tracker.sleep"
       
        
       
    }
    
    func activitiesBasedOnGroup(group: String) -> [ActivitySetting]? {
        
        
        for array in activitiesByGroup{
            if array.first?.productive == group {
                return array
            }
        }
        
        // i know this is assanine
        return nil
        
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
        ThingsToDo.append(newAction)
        
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
    
    
    
   
    
    
    func addActivityToBag (action: String, note: Bool, productive: String)
    {
        let addToBag = ActivitySetting(action: action, note: note, productive: productive)
        activityBag.append(addToBag)
    }
    func editActivityInBag (editable: ActivitySetting, action: String, note: Bool, productive: String)
    {
        deletePossibleActivity(editable.action)
        let addToBag = ActivitySetting(action: action, note: note, productive: productive)
        activityBag.append(addToBag)
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

    

    func predictActivities(dateFor: NSDate) -> [String]?{
        return activityBag.map({ (element: ActivitySetting) -> String in
            return element.action
        })
        
        
    }
*/
   func predictActivities(dateFor: NSDate) -> [String]?{
        var returnArray = [String]()
        
        var preDictonary = getDictonaryForTimeSlice(dateFor)
    
    
    
        
        var sortedActivityStrings = Array(preDictonary.keys)
        sortedActivityStrings.sortInPlace(){
            let obj1 = preDictonary[$0]
            let obj2 = preDictonary[$1]
            return obj1 > obj2
            }
    
    
        var preDictonaryOfAllTime = getDictonaryForAllTime()
        var sortedAllTimeActivityStrings = Array(preDictonaryOfAllTime.keys)
        sortedAllTimeActivityStrings.sortInPlace(){
            let obj1 = preDictonary[$0]
            let obj2 = preDictonary[$1]
            return obj1 > obj2
        }
    
        if let one = activities.last?.action{
            sortedActivityStrings.insert(one, atIndex: 0)
        }
    
   
    
    for unit in activitiesByGroup {
            if !sortedActivityStrings.contains((unit.first?.action)!){
                sortedActivityStrings.append((unit.first?.action)!)
            }
        }
    
    
    
        for unit in sortedAllTimeActivityStrings {
            if !sortedActivityStrings.contains(unit){
                sortedActivityStrings.append(unit)
            }
        }
    
    
        for unit in sortedActivityStrings{
            if activityStrings.contains(unit) && !returnArray.contains(unit)
            {
                returnArray.append(unit)
            }
        }
    
    
    return  returnArray
    
   
    
    }
    
    
    
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
    
    
    func getDictonaryForTimeSlice(date: NSDate) -> [String:Int]
    {
        var returnDict = [String:Int]()
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        
        
        for unit in activities{
           
            var exists = false
            let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            if (dateComponents.hour + 2) > unitComponents.hour && (dateComponents.hour - 2) < unitComponents.hour
            {
                for  entry in returnDict.keys
                {
                    if unit.action == entry {
                        exists = true
                        returnDict[entry]?++
                    }
                }
                if exists == false{
                    returnDict[unit.action] = 1
                }
            }
        }
       
        return returnDict

    }

    
    func getDictonaryForAllTime() -> [String:Int]
    {
        var returnDict = [String:Int]()
        
        for unit in activities{
            
            var exists = false
           
            for  entry in returnDict.keys
            {
                if unit.action == entry {
                    exists = true
                    returnDict[entry]?++
                }
            }
            if exists == false{
                returnDict[unit.action] = 1
            }
        }
       
        return returnDict
        
    }

    func predictGroup(dateFor:NSDate) -> [String]?{
        var returnArray = [String]()
        for arr in activitiesByGroup {
            returnArray.append((arr.first?.productive)!)
        }
        return returnArray
    }
    func predictActivities(dateFor:NSDate, fromGroup group:String) -> [String]?{
        var returnArray = [String]()
        if let  activities = activitiesBasedOnGroup(group){
            for element in activities {
                returnArray.append(element.action)
            }
            return returnArray
        }
        return nil
    }
    
    func predictSleep(date:NSDate) -> Bool {
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        if dateComponents.hour > averageSleepHour + 1 {
            return true
        } else{
        return false
        }
    }
    func sleepSelected(date: NSDate)
    {
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)

        SleepHour.append(dateComponents.hour)
    }


}





