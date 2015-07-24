//
//  NoteViewController.swift
//  DayTracker
//
//  Created by Henry Boswell on 7/24/15.
//  Copyright © 2015 Aaron Boswell. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    
    var note : Tracker.Activity?
    
    @IBOutlet weak var noteText: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteText.text = note?.note
        print(note?.note)
    }
   }
