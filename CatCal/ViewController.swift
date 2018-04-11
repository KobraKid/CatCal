//
//  ViewController.swift
//  CatCal
//
//  Created by Michael on 12/5/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

/**
 The ViewController controls the main app view. It handles displaying calendar events, and handles touch events on calendar items.
 */
class ViewController: UICollectionViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    // Google API related vars
    private let scopes = [kGTLRAuthScopeCalendar] /* If modifying these scopes, delete your previously saved credentials by resetting the iOS simulator or uninstalling the app. */
    private let googleCalendar = GoogleAPIHandler()
    static let service = GTLRCalendarService() /* There can only be one signed-in instance of the service, hence the public static */
    let signInButton = GIDSignInButton()
    
    // NU API related vars
    private let nuAPI = NUAPIHandler()
    
    // Layout related vars
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var newEventButton: UIButton!
    static var newEventPopupIsVisible = false
    static var events: [(id: String, description: String)] = []
    let logo = UIImageView(image: #imageLiteral(resourceName: "logo"))
    let cellCount = 24 /* how many cells are shown vertically on the screen */
    let cellID = "CalendarCell"
    public static let navHeight: CGFloat = 64.0
    
    public static var generalErrorTitle: String = ""
    public static var generalErrorMessage: String = ""
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.delegate = self
        collectionView!.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        
        // Configure Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Position the sign-in button
        /// (at the bottom of the screen?)
        /// signInButton.frame = CGRect(x: (collectionView!.bounds.width - signInButton.frame.width) / 2, y: collectionView!.bounds.height - (signInButton.frame.height + navHeight), width: signInButton.frame.width, height: signInButton.frame.height)
        signInButton.frame = CGRect(x: (collectionView!.bounds.width - signInButton.frame.width) / 2, y: collectionView!.bounds.height / 2, width: signInButton.frame.width, height: signInButton.frame.height)
        
        // Position the logo
        logo.frame = CGRect(x: (collectionView!.bounds.width / 2) - 128, y: (collectionView!.bounds.height / 2) - 256, width: 256, height: 256)
        
        // Add the UI elements to the current main view
        collectionView!.addSubview(signInButton)
        collectionView!.addSubview(logo)
        
        // Register NotificationCenter listener
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refreshView), name: NSNotification.Name(rawValue: eventsRequireRefreshKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: alertKey), object: nil)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeLeft))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    /**
     *Silently* signs the user in to Google upon opening the app, if possible.
     
     - Remark: User has to already be signed into Google (which will most likely happen the first time they opened the app). Otherwise, the **Sign In** button will show up and the user will have to sign in.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // showAlert(title: "Authentication Error", message: error.localizedDescription)
            ViewController.generalErrorTitle = "Authentication Error"
            ViewController.generalErrorMessage = error.localizedDescription
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
            ViewController.service.authorizer = nil
        } else {
            signInButton.isHidden = true
            logo.isHidden = true
            refreshButton.isHidden = false
            newEventButton.isHidden = false
            ViewController.service.authorizer = user.authentication.fetcherAuthorizer()
            googleCalendar.queryAPI(requestType: .GET)
        }
    }
    
    // MARK: - Button Actions
    
    // FIXME: Refreshing the view happens too quickly, the changes to the Google Calendar sometimes are not yet reflected.
    /**
     Reset local variables, update list of events, and refresh the view
     - Parameter sender: Can be any value, is not used.
     
     - Todo: Delay refreshing the list of events, to allow Google Calendar to reflect recent changes. Otherwise, if the list is refreshed immediately after creating or deleting events, the most recent changes will not be reflected.
     */
    @IBAction func refreshButtonPressed(_ sender: Any) {
        log.verbose("Refresh Button Pressed")
        nuAPI.queryAPI(requestType: .GET, params: [:])
        refreshView()
    }
    
    @IBAction func showCalendar(_ sender: Any) {
        if !ViewController.newEventPopupIsVisible {
            log.verbose("Opening popup for create new event")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendarView") as! CalendarViewController
            addChildViewController(popOverVC)
            popOverVC.view.frame = view.frame
            view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            ViewController.newEventPopupIsVisible = true
        }
    }
    
    /**
     Called when the 'New Event' button is pressed. Displays a Pop-Up view over the current view.
     - Parameter sender: Can be any value, is not used.
     - SeeAlso: `NewEventPopUpViewController()`
     */
    @IBAction func newEventAction(_ sender: Any) {
        log.verbose("New Event Button Pressed")
        if !ViewController.newEventPopupIsVisible {
            log.verbose("Opening popup for create new event")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newEventPopUp") as! NewEventPopUpViewController
            addChildViewController(popOverVC)
            popOverVC.view.frame = view.frame
            view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            ViewController.newEventPopupIsVisible = true
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
        log.verbose(ViewController.events)
        unowned let unownedSelf = self
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.googleCalendar.queryAPI(requestType: .GET)
            unownedSelf.collectionView!.reloadData()
            log.verbose(ViewController.events)
        })
    }
    
    /**
     Helper for showing an alert
     - Parameter title: The title of the alert popup
     - Parameter message: The body of the alert popup
     */
    @objc func showAlert() {
        let alert = UIAlertController(
            title: ViewController.generalErrorTitle,
            message: ViewController.generalErrorMessage,
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
    
    @objc func swipeLeft() {
        log.info("Left swipe")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsListViewController = storyBoard.instantiateViewController(withIdentifier: "FriendsList") as! FriendsListViewController
        // self.present(friendsListViewController, animated: true, completion: nil)
        self.navigationController!.pushViewController(friendsListViewController, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {

    /**
     Tell the CollectionView how many cells you need
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViewController.events.count
    }
    
    /**
     Give the CollectionView the cell you want it to display at indexPath
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! CalendarCell
        cell.textLabel.text = ViewController.events[indexPath.item].description
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.white : UIColor.lightGray
        return cell
    }
    
    /**
     Tell the CollectionView what size to make the cell at indexPath
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (view.frame.height - ViewController.navHeight) / CGFloat(cellCount))
    }
    
    /**
     Handle what happens when you tap on a cell
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = ViewController.events[indexPath.item].id
        log.debug("You clicked on item \(indexPath.item), which has ID \(id)")
        if id != "0" {
            log.verbose("Now deleting...")
            googleCalendar.queryAPI(requestType: .DELETE, params: ["eventId" : id]/*, onComplete: refreshView(_:)*/)
        }
    }
    
}
