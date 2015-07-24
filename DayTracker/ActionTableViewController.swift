//
//  ActionTableViewController.swift
//  DayTracker
//
//  Created by Aaron Boswell on 7/22/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class ActionTableViewController: UITableViewController
{
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var history : [String]{
        get{ return defaults.objectForKey(Default.History) as? [String] ?? [] }
        set{ defaults.setObject(newValue, forKey: Default.History) }
        
    }
    var time : [NSDate]{
        get{ return defaults.objectForKey(Default.Time) as? [NSDate] ?? [] }
        set{ defaults.setObject(newValue, forKey: Default.Time) }
        
    }
    private struct Default{
        static let History = "WhatDoing.History"
        static let Time = "WhatDoing.Time"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        print(Tracker.sharedTracker.activities)
        //print(Tracker.sharedTracker.activities)
       //
        print(Tracker.sharedTracker.activityBag)
        return Tracker.sharedTracker.activities.count
        
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ident", forIndexPath: indexPath)
        
        
        
        cell.textLabel!.text = Tracker.sharedTracker.activities[indexPath.row].action
        cell.detailTextLabel!.text = Tracker.sharedTracker.activities[indexPath.row].date.humanDate
        
        
        
        return cell
    }
    
    
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
                    
                    let note = Tracker.sharedTracker.activities[self.tableView.indexPathForCell(cell!)!.row]
                    NVC.note = note
                default: break
                }
            }
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
}