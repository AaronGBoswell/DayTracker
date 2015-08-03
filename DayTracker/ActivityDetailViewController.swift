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
   
    @IBAction func textFieldAction(sender: UITextField) {
        print(nameTextFieldOutlet.text)
        if nameTextFieldOutlet.text != "" {
            for unit in Tracker.sharedTracker.activityBag
            {
                doneButtonOutlet.enabled = true

                if unit.action == nameTextFieldOutlet.text
                {
                    doneButtonOutlet.enabled = false
                }
            }

        }
    }
    @IBOutlet weak var doneButtonOutlet: UIBarButtonItem!
    @IBAction func doneAndSave(sender: UIBarButtonItem) {
        if edit
        {
            if notificationSwitch.on{
            Tracker.sharedTracker.editActivityInBag(populate!,action: nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 4, color: pickerDictonary[pickerData[groupPicker.selectedRowInComponent(0)]]!)
            } else {
            Tracker.sharedTracker.editActivityInBag(populate!,action: nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 0, color: pickerDictonary[pickerData[groupPicker.selectedRowInComponent(0)]]!)
            }
        } else {
            if notificationSwitch.on{
            Tracker.sharedTracker.addActivityToBag(nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 4, color: pickerDictonary[pickerData[groupPicker.selectedRowInComponent(0)]]!)
            } else{
                Tracker.sharedTracker.addActivityToBag(nameTextFieldOutlet.text!, note: noteSwitch.on, productive: pickerData[groupPicker.selectedRowInComponent(0)], pushToFront: 0, color: pickerDictonary[pickerData[groupPicker.selectedRowInComponent(0)]]!)
            }
        }
        
        print("here")
        performSegueWithIdentifier("Done", sender: sender)
    }
    
  
    var pickerData = Tracker.sharedTracker.groups
    var pickerDictonary = Tracker.sharedTracker.groupsWithColorAsIntDictonary
    var firstPicker = 0
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
           
            title = "Edit Activity"
        }
        else {
            notificationSwitch.on = true
          
            title = "New Activity"
            
        }
        doneButtonOutlet.enabled = false
        
    
    }



    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count + 1
    }
    
    /*
    //MARK: Delegates
     func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row < pickerData.count{
            return NSAttributedString(string: pickerData[row])
        } else{
        //pickerLabel.backgroundColor = UIColor
            let warningTitle = NSAttributedString(string: "Add New", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
        return warningTitle
           // NSAttributedString(
        }
    }
*/
    

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            
           
        }
        if row < pickerDictonary.count{
            pickerLabel.backgroundColor =  Tracker.sharedTracker.colorForNumber(pickerDictonary[pickerData[row]]!)
            pickerLabel!.attributedText =  NSAttributedString(string: pickerData[row], attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)])
        } else{
            //pickerLabel.backgroundColor = UIColor
            let warningTitle = NSAttributedString(string: "Add New", attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)])
            pickerLabel!.attributedText = warningTitle
            
          //  let attributedTitle = NSAttributedString(string: heading, attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            
            // NSAttributedString(
        }
     
        pickerLabel.textAlignment = .Center
        return pickerLabel
        
    }
    func findOpenColor() -> Int{
        var used = false
        for x in  0...9 {
            for (_,value) in self.pickerDictonary {
                
                if value == x {
                    
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
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == pickerData.count {
            
            let alert = UIAlertController(title: "Add a group", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                if let tf = alert.textFields?.first as UITextField! {
                    
                    var copy = false
                    for unit in Tracker.sharedTracker.activityBag
                    {
                        
                        
                        if unit.productive == tf.text
                        {
                            copy = true
                            
                        }
                    }
                    
                   

                    
                    
                    if tf.text != "" && copy == false
                    {
                        self.pickerData.append(tf.text ?? "")
                    
                        self.pickerDictonary[tf.text ?? ""] = self.findOpenColor()
                        print("open color")
                        print(self.pickerDictonary)
                    
                        self.groupPicker.reloadAllComponents()
                    }
                }
                
            }))
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.placeholder = "group"
            })
            presentViewController(alert, animated: true, completion: nil)

        }
    }
}
