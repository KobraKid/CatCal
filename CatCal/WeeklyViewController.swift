//
//  WeeklyController.swift
//  CatCal
//
//  Created by Tony on 2018/4/16.
//  Copyright © 2018年 DotDev. All rights reserved.
//

import UIKit
import JTAppleCalendar

class WeeklyViewController: UIViewController {
    let formatter = DateFormatter()
    
    @IBOutlet weak var weeklyScrollView: UIScrollView!
    private var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("CatCal", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.weeklyScrollView.delegate = self
        weeklyScrollView.isScrollEnabled = true
        weeklyScrollView.contentSize = CGSize(width: 414, height: 1000)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        weeklyScrollView.isScrollEnabled = true
        weeklyScrollView.contentSize = CGSize(width: 414, height: 1000)
    }
    
    @IBAction func openFriendsList(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsListViewController = storyBoard.instantiateViewController(withIdentifier: "FriendsList") as! FriendsListViewController
        self.navigationController!.pushViewController(friendsListViewController, animated: true)
    }
}

extension WeeklyViewController: UIScrollViewDelegate {
    
}

//func handleCelltextColor(view: JTAppleCell?, cellState: CellState){
//    guard let validCell = view as? CustomCell else { return }
//
//    if cellState.dateBelongsTo == .thisMonth {
//        validCell.dateLabel.textColor = UIColor.white
//    } else {
//        validCell.dateLabel.textColor = UIColor.gray
//    }
//
//}

extension WeeklyViewController: JTAppleCalendarViewDelegate,JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "WeeklyCell", for: indexPath) as! WeeklyCell
        cell.dateLabel.text = cellState.text
//        handleCelltextColor(view: cell, cellState: cellState)
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
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1)
        return parameters
    }
    
//    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//        let date = visibleDates.monthDates.first!.date
    
//        formatter.dateFormat = "yyyy"
//        year.text = formatter.string(from: date)
//        
//        formatter.dateFormat = "MMMM"
//        month.text = formatter.string(from: date)
//    }
    
}

