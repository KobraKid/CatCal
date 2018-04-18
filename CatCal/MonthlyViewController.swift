//
//  CalendarViewController.swift
//  CatCal
//
//  Created by Tony on 2018/1/30.
//  Copyright © 2018年 DotDev. All rights reserved.
//

import UIKit
import JTAppleCalendar

class MonthlyViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("CatCal", comment: "")
    }
    
    @IBAction func openFriendsList(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsListViewController = storyBoard.instantiateViewController(withIdentifier: "FriendsList") as! FriendsListViewController
        self.navigationController!.pushViewController(friendsListViewController, animated: true)
    }
}

func handleCelltextColor(view: JTAppleCell?, cellState: CellState){
    guard let validCell = view as? MonthlyCalendarCell else { return }
    
    if cellState.dateBelongsTo == .thisMonth {
        validCell.dateLabel.textColor = UIColor.white
    } else {
        validCell.dateLabel.textColor = UIColor.gray
    }
    
}

extension MonthlyViewController: JTAppleCalendarViewDelegate,JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! MonthlyCalendarCell
        cell.dateLabel.text = cellState.text
        handleCelltextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM DD"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: "2016 03 01")!
        let endDate = formatter.date(from: "2030 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        year.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
    }
    
}
