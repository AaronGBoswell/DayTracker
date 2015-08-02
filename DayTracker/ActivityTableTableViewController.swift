//
//  ActivityTableTableViewController.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/27/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class ActivityTableTableViewController: UITableViewController {

    @IBAction func goBack(seuge: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        tableView.allowsSelectionDuringEditing = true


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Tracker.sharedTracker.activitiesByGroup.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(Tracker.sharedTracker.activities)
        //print(Tracker.sharedTracker.activities)
        //
        //print(Tracker.sharedTracker.activityBag)
        return Tracker.sharedTracker.activitiesByGroup[section].count
        
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("identifier", forIndexPath: indexPath)
        
        
        
        cell.textLabel!.text = Tracker.sharedTracker.activitiesByGroup[indexPath.section][indexPath.row].action
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.shouldIndentWhileEditing = false
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator
       // cell.textLabel!.text = Tracker.sharedTracker.actionsByGroup[indexPath.section][indexPath.row]
        //print(Tracker.sharedTracker.activities[
        

        
        return cell
    }
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
        
    }
    //override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    //    return UITableViewCellEditingStyle.None
    //}

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Tracker.sharedTracker.activitiesByGroup[section].first!.productive
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if tableView.editing == true {
            performSegueWithIdentifier("ShowActivityDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
        }
        
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let activity = Tracker.sharedTracker.activitiesByGroup[indexPath.section][indexPath.row]
            //tableView.delet
            
            let sections = Tracker.sharedTracker.activitiesByGroup.count
            Tracker.sharedTracker.deletePossibleActivity(activity.action)
            let newSections = Tracker.sharedTracker.activitiesByGroup.count
            tableView.beginUpdates()
            if sections != newSections{
                let indexSet = NSMutableIndexSet()
                indexSet.addIndex(indexPath.section)
                tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Middle)
            } else{
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
            }
            tableView.endUpdates()
            //tableView.reloadData()
            

        }
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.editing
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController!
        }
        if let ADVC = destination as? ActivityDetailViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "ShowActivityDetail":
                    
                    if let cell = sender as? UITableViewCell {
                        self.tableView.indexPathForCell(cell)
                        let populateFrom = Tracker.sharedTracker.activitiesByGroup[self.tableView.indexPathForCell(cell)!.section][self.tableView.indexPathForCell(cell)!.row]
                        ADVC.populate = populateFrom
                        ADVC.edit = true
                    } else{
                       ADVC.edit = false
                        
                    }
                   ADVC.firstPicker = Tracker.sharedTracker.groups.count
                default: break
                }
            }
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
