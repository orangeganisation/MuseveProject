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
    @IBOutlet weak var fromDatePicker: UIDatePicker! {
        didSet {
            fromDatePicker.setValue(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forKey: "textColor")
        }
    }
    @IBOutlet weak var toDatePicker: UIDatePicker! {
        didSet {
            toDatePicker.setValue(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forKey: "textColor")
        }
    }
    
    // MARK: - Actions
    @IBAction func doneAction(_ sender: UIButton) {
        let fromDay = Calendar.current.component(.day, from: fromDatePicker.date)
        let fromMonth = Calendar.current.component(.month, from: fromDatePicker.date)
        let fromYear = Calendar.current.component(.year, from: fromDatePicker.date)
        let toDay = Calendar.current.component(.day, from: toDatePicker.date)
        let toMonth = Calendar.current.component(.month, from: toDatePicker.date)
        let toYear = Calendar.current.component(.year, from: toDatePicker.date)
        var fromDayString = "\(fromDay)"
        var toDayString = "\(toDay)"
        var fromMonthString = "\(fromMonth)"
        var toMonthString = "\(toMonth)"
        if fromDay / 10 < 1 {
            fromDayString = "0\(fromDay)"
        }
        if toDay / 10 < 1 {
            toDayString = "0\(toDay)"
        }
        if fromMonth / 10 < 1 {
            fromMonthString = "0\(fromMonth)"
        }
        if toMonth / 10 < 1 {
            toMonthString = "0\(toMonth)"
        }
        EventsViewController.eventsFilter = "\(fromYear)-\(fromMonthString)-\(fromDayString),\(toYear)-\(toMonthString)-\(toDayString)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        EventsViewController.shouldUpdateEvents = true
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        EventsViewController.shouldUpdateEvents = false
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
