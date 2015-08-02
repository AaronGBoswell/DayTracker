//
//  PopDateViewController.swift
//  DayTracker
//
//  Created by Henry Boswell on 8/1/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//
import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(date : NSDate?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?
    
    var currentDate : NSDate? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func okAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
        
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
}