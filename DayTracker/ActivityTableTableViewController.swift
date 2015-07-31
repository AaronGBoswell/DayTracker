//
//  ActivityTableTableViewController.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/27/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class ActivityTableTableViewController: UITableViewController {

    
    var fromTableView = false
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("identifier", forIndexPath: indexPath)
        
        
        
        cell.textLabel!.text = Tracker.sharedTracker.activitiesByGroup[indexPath.section][indexPath.row].action
       // cell.textLabel!.text = Tracker.sharedTracker.actionsByGroup[indexPath.section][indexPath.row]
        //print(Tracker.sharedTracker.activities[
    

        
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Tracker.sharedTracker.activitiesByGroup[section].first!.productive
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        fromTableView = true
        performSegueWithIdentifier("ShowActivityDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
        
        
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
                    
                    if fromTableView
                    {
                        let cell = sender as? UITableViewCell
                        self.tableView.indexPathForCell(cell!)
                        let populateFrom = Tracker.sharedTracker.activitiesByGroup[self.tableView.indexPathForCell(cell!)!.section][self.tableView.indexPathForCell(cell!)!.row]
                        ADVC.populate = populateFrom
                        ADVC.edit = true
                        fromTableView = false
                    } else{
                       ADVC.edit = false
                        
                    }
                default: break
                }
            }
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
