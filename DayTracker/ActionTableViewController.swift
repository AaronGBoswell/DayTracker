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
    
    var todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(NSDate())
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.reloadData()
        Tracker.sharedTracker.observers.append(self)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    func observedValueChanged() {
        todaysArray = Tracker.sharedTracker.actionsOrganizedForDay(NSDate())
        tableView?.reloadData()
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
        
        if unitComponents.hour < 8 {
            timeOfDay =  "  Early"
        } else if unitComponents.hour < 11 {
            timeOfDay = "   Morning"
        } else if unitComponents.hour < 14 {
            timeOfDay = "   Midday"
        } else if unitComponents.hour < 17 {
            timeOfDay =  "  Afternoon"
        } else if unitComponents.hour < 21 {
            timeOfDay =  "  Evening"
        }else if unitComponents.hour < 24 {
            timeOfDay =  "  Night"
        }
        
        headerLabel.backgroundColor = UIColor(red: 2.0/255.0, green: 77.0/255.0, blue: 109.0/255.0, alpha: 0.89)
        let font = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
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
                    let cell = sender as? UITableViewCell
                    self.tableView.indexPathForCell(cell!)
                    
                    let note = todaysArray[self.tableView.indexPathForCell(cell!)!.section][self.tableView.indexPathForCell(cell!)!.row]
                    NVC.note = note
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