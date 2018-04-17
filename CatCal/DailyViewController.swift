//
//  ViewController.swift
//  CatCal
//
//  Created by Michael on 12/5/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import UIKit

/**
 The ViewController controls the main app view. It handles displaying calendar events, and handles touch events on calendar items.
 */
class DailyViewController: UICollectionViewController {
    
    // Google API related vars
    private let googleCalendar = GoogleAPIHandler()
    
    // NU API related vars
    private let nuAPI = NUAPIHandler()
    
    // Layout related vars
    @IBOutlet weak var newEventButton: UIButton!
    static var newEventPopupIsVisible = false
    static var events: [(id: String, description: String)] = []
    let cellCount = 10 /* how many cells are shown vertically on the screen */
    let cellID = "CalendarCell"
    public static let navHeight: CGFloat = 64.0
    
    public static var generalErrorTitle: String = ""
    public static var generalErrorMessage: String = ""
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("CatCal", comment: "")
        
        collectionView!.delegate = self
        collectionView!.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        
        // Register NotificationCenter listener
        NotificationCenter.default.addObserver(self, selector: #selector(DailyViewController.refreshView), name: NSNotification.Name(rawValue: eventsRequireRefreshKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: alertKey), object: nil)
        
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DailyViewController.swipeLeft))
//        swipeGesture.direction = .left
//        self.view.addGestureRecognizer(swipeGesture)

        newEventButton.isHidden = false
    }
    
    // MARK: - Button Actions
    
    // FIXME: Refreshing the view happens too quickly, the changes to the Google Calendar sometimes are not yet reflected.
    /**
     Reset local variables, update list of events, and refresh the view
     - Parameter sender: Can be any value, is not used.
     
     - Todo: Delay refreshing the list of events, to allow Google Calendar to reflect recent changes. Otherwise, if the list is refreshed immediately after creating or deleting events, the most recent changes will not be reflected.
     */
//    @IBAction func refreshButtonPressed(_ sender: Any) {
//        log.verbose("Refresh Button Pressed")
//        nuAPI.queryAPI(requestType: .GET, params: [:])
//        refreshView()
//    }
    
    /**
     Called when the 'New Event' button is pressed. Displays a Pop-Up view over the current view.
     - Parameter sender: Can be any value, is not used.
     - SeeAlso: `NewEventPopUpViewController()`
     */
    @IBAction func newEventAction(_ sender: Any) {
        log.verbose("New Event Button Pressed")
        if !DailyViewController.newEventPopupIsVisible {
            log.verbose("Opening popup for create new event")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newEventPopUp") as! NewEventPopUpViewController
            addChildViewController(popOverVC)
            popOverVC.view.frame = view.frame
            view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            DailyViewController.newEventPopupIsVisible = true
        }
    }
    
    // MARK: - Convenience Methods
    
    // FIXME: Currently a manual press of the Refresh button is needed to reflect changes.
    /**
     Re-fetches Google Calendar events, updating the event list on-screen.
     */
    @objc func refreshView() {
        googleCalendar.queryAPI(requestType: .GET)
        collectionView!.reloadData()
        log.verbose(DailyViewController.events)
        unowned let unownedSelf = self
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.googleCalendar.queryAPI(requestType: .GET)
            unownedSelf.collectionView!.reloadData()
            log.verbose(DailyViewController.events)
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
    
    @IBAction func openFriendsList(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsListViewController = storyBoard.instantiateViewController(withIdentifier: "FriendsList") as! FriendsListViewController
        self.navigationController!.pushViewController(friendsListViewController, animated: true)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! CalendarCell
        cell.textLabel.text = DailyViewController.events[indexPath.item].description
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.white : UIColor.lightGray
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
            googleCalendar.queryAPI(requestType: .DELETE, params: ["eventId" : id]/*, onComplete: refreshView(_:)*/)
        }
    }
    
}
