//
//  SettingsTableViewController.swift
//  DayTracker
//
//  Created by Aaron Boswell on 8/1/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var wakeTimeTableCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        popDatePicker = PopDatePicker(forView: wakeTimeTableCell)
        refreshWakeTime()

        
    }
    func refreshWakeTime(){
        let wakeMinute: String = (Tracker.sharedTracker.settings.wakeMinute == 0) ? "00" : Tracker.sharedTracker.settings.wakeMinute.description
        wakeTimeTableCell.textLabel?.text = "Wake Time               \(Tracker.sharedTracker.settings.wakeHour):\(wakeMinute)"
    }
    var popDatePicker : PopDatePicker?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if wakeTimeTableCell == tableView.cellForRowAtIndexPath(indexPath){
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            //let initDate : NSDate? = formatter.dateFromString(wakeTimeTextField.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate) -> () in
                
                let cal = NSCalendar.currentCalendar()
                let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: newDate)
                
                Tracker.sharedTracker.settings.wakeMinute = comps.minute
                Tracker.sharedTracker.settings.wakeHour = comps.hour
                self.refreshWakeTime()
                self.wakeTimeTableCell.selected = false

            }
            
            popDatePicker!.pick(self, dataChanged: dataChangedCallback)
        }
    }
    
   }
