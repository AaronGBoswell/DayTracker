//
//  ActionTableViewController.swift
//  DayTracker
//
//  Created by Aaron Boswell on 7/22/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class ActionTableViewController: UITableViewController, Observer
{
   
    @IBAction func goBackAction(seuge: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBOutlet weak var rightArrow: UIBarButtonItem!
    @IBOutlet weak var leftArrow: UIBarButtonItem!

    var todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(NSDate()){
        didSet{
            tableView?.reloadData()
        }
    }
    
    var displayDate = NSDate(){
        didSet{
            todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(displayDate)
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = NSDateFormatterStyle.NoStyle
            title = formatter.stringFromDate(displayDate)
            if daysFromToday == 0 {
                title = "Today's Activities"
            }
        }
    }
    var daysFromToday = 0{
        didSet{
            let cal = NSCalendar.currentCalendar()
            let comps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: NSDate())
            comps.day += daysFromToday
            if daysFromToday == 0{
                rightArrow.enabled = false
            } else{
                rightArrow.enabled = true
            }
            displayDate = cal.dateFromComponents(comps)!

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.reloadData()
        Tracker.sharedTracker.observers.append(self)
        todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(displayDate)
        if daysFromToday == 0{
            rightArrow.enabled = false
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    func observedValueChanged() {
        todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(displayDate)
    }
    @IBAction func leftArrowClicked(sender: UIBarButtonItem) {
        daysFromToday--
    }

    @IBAction func rightArrowClicked(sender: AnyObject) {
        daysFromToday++
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        
        return todaysArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        

        return todaysArray[section].count
        
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        
        var timeOfDay = ""
        if todaysArray[section].isEmpty {
            print("nilllll")
            
            return nil
        }
        
        let cal = NSCalendar.currentCalendar()
        let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: todaysArray[section].first!.date)
        
        for (hour, title) in Tracker.sharedTracker.timesOfDay {
            if unitComponents.hour < hour{
                timeOfDay = "   \(title)"
                break
            }
        }
        
        headerLabel.backgroundColor = UIColor(red: 2.0/255.0, green: 77.0/255.0, blue: 109.0/255.0, alpha: 0.89)        
        let attributedTitle = NSAttributedString(string: timeOfDay, attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()])
        headerLabel.attributedText = attributedTitle
        
        return headerLabel
        
        
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if todaysArray[section].isEmpty {
            return 0
        }
        return 25

    }
    
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel!.backgroundColor = UIColor.clearColor()
        
        guard   let activityToGroupDict = Tracker.sharedTracker.activityToGroupDictonary[todaysArray[indexPath.section][indexPath.row].action],
                let colorNumber = Tracker.sharedTracker.groupsWithColorAsIntDictonary[activityToGroupDict]
        else{
            cell.contentView.backgroundColor =  UIColor.whiteColor()
            return

        }
        let color = Tracker.sharedTracker.colorForNumber(colorNumber)
        cell.contentView.backgroundColor =  color

    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ident", forIndexPath: indexPath)

        cell.textLabel!.text = todaysArray[indexPath.section][indexPath.row].action
        cell.detailTextLabel!.text = todaysArray[indexPath.section][indexPath.row].date.humanDate
        

        
       
        
        return cell
        
        
    }
    
    
    
    
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if todaysArray[section].isEmpty {
            return nil
        }
        
        let cal = NSCalendar.currentCalendar()
        let unitComponents = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Era , NSCalendarUnit.Year,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: todaysArray[section].first!.date)
       
        if unitComponents.hour < 8 {
            return "Early"
        } else if unitComponents.hour < 11 {
            return "Morning"
        } else if unitComponents.hour < 14 {
            return"Midday"
        } else if unitComponents.hour < 17 {
            return "Afternoon"
        } else if unitComponents.hour < 21 {
            return "Evening"
        }else if unitComponents.hour < 24 {
            return "Night"
        }
        return "Some Time"
        

        
        
        
    }
    */

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        
        performSegueWithIdentifier("ShowNote", sender: tableView.cellForRowAtIndexPath(indexPath))
        
        
    }
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController!
        }
        if let NVC = destination as? NoteViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "ShowNote":
                    if let cell = sender as? UITableViewCell{
                        if let indexPath = tableView.indexPathForCell(cell){
                    
                            let note = todaysArray[indexPath.section][indexPath.row]
                            NVC.note = note
                        }
                    }
                default: break
                }
            }
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
}
protocol Observer{
    func observedValueChanged()
}