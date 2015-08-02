//
//  PopDatePicker.swift
//  DayTracker
//
//  Created by Henry Boswell on 8/1/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

public class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DataPickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (newDate : NSDate)->()
    
    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var view : UIView!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    
    public init(forView: UIView) {
        
        datePickerVC = PopDateViewController()
        self.view = forView
        super.init()
    }
    
    public func pick(inViewController : UIViewController, dataChanged : PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        datePickerVC.preferredContentSize = CGSizeMake(500,208)
        
        popover = datePickerVC.popoverPresentationController
        if let _popover = popover {
            
            _popover.sourceView = view
            _popover.sourceRect = CGRectMake(self.offset,view.bounds.size.height,view.bounds.midX,view.bounds.midY)
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.presentViewController(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    public func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
    }
    
    func datePickerVCDismissed(date : NSDate?) {
        
        if let _dataChanged = dataChanged {
            
            if let _date = date {
                
                _dataChanged(newDate: _date)
                
            }
        }
        presented = false
    }
}