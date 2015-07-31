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
    
  
    let pickerData = Tracker.sharedTracker.groups
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupPicker.dataSource = self
        groupPicker.delegate = self
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
         }
}
