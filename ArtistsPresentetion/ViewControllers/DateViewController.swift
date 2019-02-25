//
//  DateViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/25/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    // MARK: - Actions
    @IBAction func doneAction(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.string(from: fromDatePicker.date)
        let toDate = dateFormatter.string(from: toDatePicker.date)
        EventsViewController.eventsFilter = (fromDate + "," + toDate).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        EventsViewController.shouldUpdateEvents = true
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        EventsViewController.shouldUpdateEvents = false
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
