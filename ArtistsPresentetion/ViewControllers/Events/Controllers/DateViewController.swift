//
//  DateViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/25/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

final class DateViewController: UIViewController {

    // MARK: - Vars & Lets
    private let dataStore = DataStore.shared
    
    // MARK: - Outlets
    @IBOutlet private weak var fromDatePicker: UIDatePicker!
    @IBOutlet private weak var toDatePicker: UIDatePicker!
    @IBOutlet private weak var fromDateLabel: UILabel!
    @IBOutlet private weak var toDateLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    // MARK: - Actions
    @IBAction func doneAction(_ sender: UIButton) {
        dataStore.eventsFilter = .date(fromDate: fromDatePicker.date, toDate: toDatePicker.date)
        dataStore.shouldUpdateEvents = true
        dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dataStore.shouldUpdateEvents = false
        dismiss(animated: true)
    }
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        fromDateLabel.text = "From:".localized()
        toDateLabel.text = "To:".localized()
        cancelButton.setTitle(StringConstant.cancel, for: .normal)
        doneButton.setTitle("Done".localized(), for: .normal)
    }
}
