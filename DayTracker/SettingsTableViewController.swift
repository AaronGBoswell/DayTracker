//
//  SettingsTableViewController.swift
//  DayTracker
//
//  Created by Aaron Boswell on 8/1/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        popDatePicker = PopDatePicker(forTextField: wakeTimeTextField)
        wakeTimeTextField.delegate = self
        
    }
    var popDatePicker : PopDatePicker?
    @IBOutlet weak var wakeTimeTextField: UITextField!
    
    func resign() {
        
        wakeTimeTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === wakeTimeTextField) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            let initDate : NSDate? = formatter.dateFromString(wakeTimeTextField.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.humanDate ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
   }
