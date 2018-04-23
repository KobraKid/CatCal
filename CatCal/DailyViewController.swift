//
//  ViewController.swift
//  CatCal
//
//  Created by Michael on 12/5/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import UIKit

/**
 The ViewController controls the main app view.
 It handles displaying calendar events, and handles touch events on calendar items.
 */
class DailyViewController: UICollectionViewController {
    
    // Google API related vars
    private let googleCalendar = GoogleAPIHandler()
    weak var refreshTimer: Timer?
    
    // NU API related vars
    private let nuAPI = NUAPIHandler()
    
    // Layout related vars
    static var events: [(id: String, description: String)] = []
    let cellCount = 10 /* how many cells are shown vertically on the screen */
    let cellID = "CalendarCell"
    public static let navHeight: CGFloat = 64.0
    
    public static var generalErrorTitle: String = ""
    public static var generalErrorMessage: String = ""
    
    var transparentBackground: UIView? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apple color theme
        collectionView!.backgroundColor = bgColor
        
        // Apply title
        self.navigationItem.title = NSLocalizedString("CatCal", comment: "")
        
        collectionView!.delegate = self
        collectionView!.register(DailyCalendarCell.self, forCellWithReuseIdentifier: cellID)
        
        // Register NotificationCenter listener
        NotificationCenter.default.addObserver(self, selector: #selector(DailyViewController.refreshView), name: NSNotification.Name(rawValue: eventsRequireRefreshKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: alertKey), object: nil)
        
        // Initial loading of events list
        refreshView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { [weak self] _ in
            self?.refreshView()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refreshTimer?.invalidate()
    }
    
    // MARK: - Button Actions
    
    @IBAction func openFriendsList(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsListViewController = storyBoard.instantiateViewController(withIdentifier: "FriendsList") as! FriendsListViewController
        self.navigationController!.pushViewController(friendsListViewController, animated: true)
    }
    
    // MARK: - Convenience Methods
    
    /**
     Re-fetches Google Calendar events, updating the event list on-screen.
     */
    @objc func refreshView() {
        googleCalendar.queryAPI(requestType: .GET)
        collectionView!.reloadData()
        unowned let unownedSelf = self
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.googleCalendar.queryAPI(requestType: .GET)
            unownedSelf.collectionView!.reloadData()
        })
    }
    
    /**
     Helper for showing an alert
     - Parameter title: The title of the alert popup
     - Parameter message: The body of the alert popup
     */
    @objc func showAlert() {
        let alert = UIAlertController(
            title: DailyViewController.generalErrorTitle,
            message: DailyViewController.generalErrorMessage,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        log.info(String(describing: alert))
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DailyViewController: UICollectionViewDelegateFlowLayout {

    /**
     Tell the CollectionView how many cells you need
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DailyViewController.events.count
    }
    
    /**
     Give the CollectionView the cell you want it to display at indexPath
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! DailyCalendarCell
        cell.textLabel.text = DailyViewController.events[indexPath.item].description
        cell.textLabel.textColor = UIColor.white
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.purple : UIColor.init(red: 73, green: 26, blue: 136, alpha: 0)
        return cell
    }
    
    /**
     Tell the CollectionView what size to make the cell at indexPath
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (view.frame.height - DailyViewController.navHeight) / CGFloat(cellCount))
    }
    
    /**
     Handle what happens when you tap on a cell
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = DailyViewController.events[indexPath.item].id
        log.debug("You clicked on item \(indexPath.item), which has ID \(id)")
        if id != "0" {
            log.verbose("Now deleting...")
            googleCalendar.queryAPI(requestType: .DELETE, params: ["eventId" : id])
        }
    }
    
}
