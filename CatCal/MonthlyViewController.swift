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


    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    let formatter = DateFormatter()
    let todayColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("CatCal", comment: "")
        
        formatter.dateFormat = "yyyy"
        self.year.text = formatter.string(from: Date())
        
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: Date())
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
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "MonthlyCalendarCell", for: indexPath) as! MonthlyCalendarCell
        cell.dateLabel.text = cellState.text
        handleCelltextColor(view: cell, cellState: cellState)
        
        formatter.dateFormat = "yyyy MM dd"
        let currentDate = formatter.string(from: Date())
        let cellStateDate = formatter.string(from: cellState.date)
        if currentDate == cellStateDate {
            cell.dateLabel.textColor = UIColor.black
            cell.contentView.layer.backgroundColor = todayColor.cgColor
            cell.contentView.layer.cornerRadius = 24.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
        }
        
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM DD"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2016 03 01")!
        let endDate = formatter.date(from: "2030 12 31")!
        
        let today: Date = Date()
        calendar.scrollToDate(today, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0, completionHandler: nil)
        
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
