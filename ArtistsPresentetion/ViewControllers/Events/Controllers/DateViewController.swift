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
    @IBOutlet weak var fromDateLabel: UILabel! {
        didSet {
            fromDateLabel.text = NSLocalizedString("From:", comment: "")
        }
    }
    @IBOutlet weak var toDateLabel: UILabel! {
        didSet {
            toDateLabel.text = NSLocalizedString("To:", comment: "")
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func doneAction(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatter.string(from: fromDatePicker.date)
        let toDate = dateFormatter.string(from: toDatePicker.date)
        DataStore.shared.eventsFilter = (fromDate + "," + toDate).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        DataStore.shared.shouldUpdateEvents = true
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        DataStore.shared.shouldUpdateEvents = false
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
