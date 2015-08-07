//
//  Tracker.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/22/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import Foundation
import UIKit
class Tracker {
    
    static let sharedTracker = Tracker()
    internal var settings = TrackerSettings()
    var observers = [Observer]()
     var themeColor = UIColor(red: 255, green: 171, blue: 17, alpha: 1)
    var noSleepYet = false
    var oppositeThemeColor = UIColor.yellowColor()
    
    var timesOfDay: [(hour:Int, title:String)] = [(5, "Very Early"),(8, "Early"),(11, "Morning"),(14, "Midday"),(17, "Afternoon"),(21, "Evening"),(24, "Night")]

    
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
            
            for observer in observers{
                dispatch_async(dispatch_get_main_queue()){
                    
                    observer.observedValueChanged()
                }
            }
            
        }
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
        var priorityUntil : NSDate?
        var color : Int
        
        
        internal init( action: String, note: Bool, productive : String, priorityUntil :  NSDate?, color : Int)
        {
            self.action = action
            self.note = note
            self.productive = productive
            self.priorityUntil = priorityUntil
            self.color = color
            return
            
        }
        internal init( action: String?, note: Bool?, productive : String?, priorityUntil :  NSDate?, color : Int?)
        {
            self.action = action!
            self.note = note!
            self.productive = productive!
            self.priorityUntil = priorityUntil
            self.color = color ?? 1
            return
            
        }
        
        
    }
    
    internal var activityBag : [ActivitySetting]{
        get{
            var newActivities = [ActivitySetting]()
            for activityDictionary in ThingsToDo
            {
                if( activityDictionary.keys.count == 0){
                    let addition = ActivitySetting(action: "relaxing", note: false, productive: "Entertainment", priorityUntil: nil, color: 2)
                    newActivities.append(addition)
                    return newActivities
                }
                let addition : ActivitySetting = ActivitySetting(action: activityDictionary["action"] as? String, note: activityDictionary["note"] as? Bool, productive: activityDictionary["productive"] as? String, priorityUntil: activityDictionary["priorityUntil"] as? NSDate,  color: activityDictionary["color"] as? Int)
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
                newAction["priorityUntil"] = unit.priorityUntil
                newAction["color"]=unit.color
                newActions.append( newAction )
            }
            ThingsToDo = newActions
            //let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            //dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
            delay(1.0){
                NotificationManager.sharedNotificationManager.scheduleNotifications()
            }
            //}
        }
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    var activityStrings : [String]{
        return activityBag.map { (element) -> String in return element.action }
    }

    var activityToGroupDictonary : [String:String] {
        var returnDict = [String:String]()
        for unit in activityBag {
            returnDict[unit.action] = unit.productive
        }
        return returnDict
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
    func actionsForDay(date:NSDate) -> [Activity]{
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
    //public let
    func actionsOrganizedForDay(date:NSDate) ->[[Activity]]{
        let actionsForDate = actionsForDay(date)
        let cal = NSCalendar.currentCalendar()

        var returnArray = [[Activity]]()
        for _ in 0 ..< timesOfDay.count{
            returnArray.append([Activity]())
        }
        for unit in actionsForDate{
            let unitComponents = cal.components(NSCalendarUnit.Hour, fromDate: unit.date)
            for (index, element) in timesOfDay.enumerate() {
                if unitComponents.hour < element.hour {
                    returnArray[index].append(unit)
                    break
                }
            }
            
        }
        
        return returnArray
    }
    /*
    var todaysOrginizedArray : [[Activity]] {
        let date = NSDate()
        var returnArray = [[Activity]]()
        var early = [Activity]()
        var morning = [Activity]()
        var midday = [Activity]()
        var night = [Activity]()
        var late = [Activity]()
        var veryLate = [Activity]()

        
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        
        
        
        for unit in activities{
            let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: unit.date)
            
            if dateComponents.month == unitComponents.month && dateComponents.year == unitComponents.year && dateComponents.day == unitComponents.day {
                if unitComponents.hour < 8 {
                    early.append(unit)
                } else if unitComponents.hour < 11 {
                    morning.append(unit)
                } else if unitComponents.hour < 14 {
                    midday.append(unit)
                } else if unitComponents.hour < 17 {
                    night.append(unit)
                } else if unitComponents.hour < 21 {
                    late.append(unit)
                }else if unitComponents.hour < 24 {
                    veryLate.append(unit)
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
        if veryLate.first != nil{
            returnArray.append(veryLate)
        }
        return returnArray
        
    }

    */
    
    var groups : [String] {
        var returnArray =  [String]()
        for array in activitiesByGroup{
            returnArray.append((array.first?.productive)!)
            
        }
        return returnArray

    }
    var groupsWithColorAsIntDictonary : [String:Int] {
        var returnDict =  [String:Int]()
        for array in activitiesByGroup{
            returnDict[(array.first?.productive)!] = (array.first?.color)!
            
        }
        return returnDict
        
    }
    
    var averageSleepHour : Int {
        var total = 0
        for unit in SleepHour
        {
            total += unit
        }
        total = total/SleepHour.count
        return total
    }
   
    
    
    
  
    var SleepUntil : NSDate?{
        get {
            return defaults.objectForKey(Settings.sleepUntil) as? NSDate
        }
        set {
            defaults.setObject(newValue, forKey: Settings.sleepUntil)
        }
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    struct TrackerSettings{
        var timeSlice: Int = 15
        
        
        var wakeHour : Int {
            get{ return Tracker.sharedTracker.defaults.objectForKey(Settings.wakeHour) as? Int ?? 8 }
            set{ Tracker.sharedTracker.defaults.setObject(newValue, forKey:Settings.wakeHour) }
        }
            
        
        
        var wakeMinute : Int {
            get{ return Tracker.sharedTracker.defaults.objectForKey(Settings.wakeMinute) as? Int ?? 0 }
            set{ Tracker.sharedTracker.defaults.setObject(newValue, forKey:Settings.wakeMinute) }
        }

    }
    


    var ThingsToDo : [[String:AnyObject]]{
        get{ return defaults.objectForKey(Settings.possibleActionsKey) as? [[String:AnyObject]] ?? [[: ]] }
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
        static let sleepUntil = "Tracker.sleepUntil"
         static let wakeHour = "Tracker.wakeHour"
        static let wakeMinute = "Tracker.wakeMinute"
       
        
       
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
        NotificationManager.sharedNotificationManager.pendingNoteNotification = false
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
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
                return
                
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
    
    
    func findOpenColor() -> Int{
        var used = false
        for x in  0...9 {
            for unit in activityBag {
                
                if unit.color == x {
                    used = true
                }
            }
            if used == false{
            return x
            }
            else {
                used = false
            }
        }
        return 10
    }
   
    
    
    func addActivityToBag (action: String, note: Bool, productive: String, priorityUntil: NSDate?, color: Int)
    {
        let addToBag = ActivitySetting(action: action, note: note, productive: productive, priorityUntil: priorityUntil, color: color)
        activityBag.append(addToBag)
    }
    func editActivityInBag (editable: ActivitySetting, action: String, note: Bool, productive: String, priorityUntil: NSDate?, color: Int)
    {
        deletePossibleActivity(editable.action)
        let addToBag = ActivitySetting(action: action, note: note, productive: productive, priorityUntil: priorityUntil, color: color)
        print("saving with")
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
    
    
    
    
        for unit in activityBag{
            if let priorityUntil = unit.priorityUntil{
                if priorityUntil.laterDate(NSDate()) == priorityUntil {
                    returnArray.insert(unit.action, atIndex: 0)
                }
            }
        }
    
    
    
        for unit in sortedActivityStrings{
            if activityStrings.contains(unit) && !returnArray.contains(unit)
            {
                returnArray.append(unit)
            }
        }
    
        for unit in activityBag{
            if !returnArray.contains(unit.action) {
                returnArray.append(unit.action)
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
        if let  activitiesForGroup = activitiesBasedOnGroup(group){
            for element in activitiesForGroup {
                returnArray.append(element.action)
            }
            return returnArray
        }
        return nil
    }
    
    func predictSleep(date:NSDate) -> Bool {
        
        //NSDate().dateForNext(Tracker.sharedTracker.settings.wakeHour, minute: Tracker.sharedTracker.settings.wakeMinute)
        return true
        /*
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        if dateComponents.hour > averageSleepHour - 1 {
            
            return true
        } else if dateComponents.hour < settings.wakeHour {
            return true
        }
            
        return false
    */

    }
    func sleepSelected(date: NSDate)
    {
        let cal = NSCalendar.currentCalendar()
       
        let dateComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        if dateComponents.hour > 18 {
        
        
            SleepHour.append(dateComponents.hour)
        }
        
       
    }
    
    func predictGroups(dateFor: NSDate) -> [String]?{
        let arrayWithActivities = predictActivities(dateFor)
        var returnArray = [String]()
        
        for unit in arrayWithActivities! {
            if !returnArray.contains(activityToGroupDictonary[unit]!){
                returnArray.append(activityToGroupDictonary[unit]!)
            }
            //activityToGroupDictonary[unit]
        }
        return returnArray
    }
    func predictActivitiesForGroup(dateFor: NSDate, group: String) -> [String]?{
         var returnArray = [String]()
        let arrayWithActivities = predictActivities(dateFor)
        for unit in arrayWithActivities! {
            if activityToGroupDictonary[unit] == group {
                returnArray.append(unit)
            }
        }
        return returnArray
    }
    func colorForNumber(number: Int) -> UIColor {
        
        var returnColor : UIColor
        returnColor = UIColor.clearColor()
        if number == 0{
            returnColor =  UIColor.redColor()
            
        } else if number == 1 {
            returnColor = UIColor.blueColor()
        } else if number == 2 {
            returnColor = UIColor.greenColor()
        } else if number == 3 {
            returnColor = UIColor.yellowColor()
        } else if number == 4 {
            returnColor = UIColor.purpleColor()
        } else if number == 5 {
            returnColor = UIColor.orangeColor()
        } else if number == 6 {
            returnColor = UIColor.magentaColor()
        } else if number == 7 {
            returnColor = UIColor.cyanColor()
        } else if number == 8 {
            returnColor = UIColor.brownColor()
        } else if number == 9 {
            returnColor = UIColor.grayColor()
        } else if number == 10 {
            returnColor = UIColor.brownColor()
        }





        
        return returnColor.colorWithAlphaComponent(0.1)
        
    }
    
    func saveNote(note: String, forActivity: Activity) {
        for (index , unit) in activities.enumerate(){
            if unit.date == forActivity.date && unit.action == forActivity.action
            {
                activities[index].note = note
            }
        }
    }


}





