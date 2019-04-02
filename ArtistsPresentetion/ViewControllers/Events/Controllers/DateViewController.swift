//
//  DateViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/25/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

final class DateViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var fromDatePicker: UIDatePicker!
    @IBOutlet private weak var toDatePicker: UIDatePicker!
    @IBOutlet private weak var fromDateLabel: UILabel!
    @IBOutlet private weak var toDateLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    // MARK: - Actions
    @IBAction func doneAction(_ sender: UIButton) {
        DataStore.shared.setEventsFilterDate(fromDate: fromDatePicker.date, toDate: toDatePicker.date)
        DataStore.shared.shouldUpdateEvents = true
        dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        DataStore.shared.shouldUpdateEvents = false
        dismiss(animated: true)
    }
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        fromDateLabel.text = NSLocalizedString("From:", comment: "")
        toDateLabel.text = NSLocalizedString("To:", comment: "")
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
    }
}
