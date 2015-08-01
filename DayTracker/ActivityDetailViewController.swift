//
//  ActivityDetailViewController.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/31/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController ,UIPickerViewDataSource,UIPickerViewDelegate{

    
    
    
    
    @IBOutlet weak var nameTextFieldOutlet: UITextField!
    @IBOutlet weak var noteSwitch: UISwitch!
    @IBOutlet weak var groupPicker: UIPickerView!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
   
    @IBAction func doneAndSave(sender: UIBarButtonItem) {
        if edit
        {
            if notificationSwitch.on{
            Tracker.sharedTracker.editActivityInBag(populate!,action: nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 4)
            } else {
            Tracker.sharedTracker.editActivityInBag(populate!,action: nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 0)
            }
        } else {
            if notificationSwitch.on{
            Tracker.sharedTracker.addActivityToBag(nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 4)
            } else{
                Tracker.sharedTracker.addActivityToBag(nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 0)
            }
        }
        
        print("here")
        performSegueWithIdentifier("Done", sender: sender)
    }
    
  
    var pickerData = Tracker.sharedTracker.groups
    var populate : Tracker.ActivitySetting?
    var edit = false
    //var currentPicked : String
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupPicker.dataSource = self
        groupPicker.delegate = self
        if edit {
            noteSwitch.on = populate!.note
            nameTextFieldOutlet.text = populate!.action
            //find in array 
            groupPicker.selectRow(pickerData.indexOf((populate?.productive)!)!, inComponent: 0, animated: true)
            notificationSwitch.on = false
        }
        else {
            notificationSwitch.on = true
            
        }
    }
    
    
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count + 1
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < pickerData.count{
            return pickerData[row]
        } else{
        return "Add New"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == pickerData.count {
            
            let alert = UIAlertController(title: "Add a group", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                if let tf = alert.textFields?.first as UITextField! {
                    self.pickerData.append(tf.text ?? "")
                    self.groupPicker.reloadAllComponents()
                }
                
            }))
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.placeholder = "group"
            })
            presentViewController(alert, animated: true, completion: nil)

        }
    }
}
