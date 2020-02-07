//
//  FSCalendarViewController.swift
//  TasksManager
//
//  Created by Artem Syritsa on 07.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit
import FSCalendar

typealias CalendarSelectCompletion = (Date, String)->()

class FSCalendarViewController: BaseController, FSCalendarDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    
    var callBackReturnDate: CalendarSelectCompletion?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
        calendar.select(selectedDate != nil ? selectedDate : Date(), scrollToDate: true)
    }
    
    // MARK: - Calendar delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        if let `callBackReturnDate` = callBackReturnDate, let `selectedDate` = selectedDate {
            callBackReturnDate(selectedDate, selectedDate.convertToString())
            Material.hideMaterialPopUp()
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let result = date.compare(Date()) == .orderedAscending ? false : true
        if result == false {
            Material.showSnackBar(message: "common.selet_future_date".localized(), duration: 3.0)
        }
        return result
    }

}

