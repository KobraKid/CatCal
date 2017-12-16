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
 ViewController controls the main app view. It handles displaying calendar events, and touch events on calendar items.
 */
class ViewController: UICollectionViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    // Google API related objects
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    /// If modifying these scopes, delete your previously saved credentials by resetting the iOS simulator or uninstalling the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    // Google Calendar related objects
    var calendarToAccess = "u.northwestern.edu_uuh3sk34il40hq330fm95jiaic@group.calendar.google.com"
    
    // Layout related objects
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var newEventButton: UIButton!
    static var newEventPopupIsVisible = false
    let logo = UIImageView(image: #imageLiteral(resourceName: "Icon-1025"))
    let numberOfCells = 24
    let cellID = "CalendarCell"
    let navHeight: CGFloat = 64.0
    var events: [(id: String, description: String)] = []
    
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
    }
    
    // FIXME: - Refreshing the view happens too quickly, the changes to the Google Calendar are not yet reflected
    /**
     Reset local variables, update list of events, and refresh the view
     
     - Todo: Delay refreshing the list of events, to allow Google Calendar to reflect recent changes. Otherwise, if the list is refreshed immediately after creating or deleting events, the most recent changes will not be reflected.
     */
    @IBAction func refreshView(_ sender: Any) {
        fetchEvents()
        collectionView!.reloadData()
        print(String(describing: events))
    }
    
    /**
     Called when the 'New Event' button is pressed. Displays a Pop-Up view over the current view.
     
     - Todo: Allow the popup view to modify the new event before it is created.
     */
    @IBAction func newEventAction(_ sender: Any) {
        if !ViewController.newEventPopupIsVisible {
            print("Creating new event")
            addEvent(event: GCalEventBuilder(summary: "Test Event", description: "This is a test :)", startTime: NSDate(timeIntervalSinceNow: 60 * 60), endTime: NSDate(timeIntervalSinceNow: 60 * 60 * 2)), to: calendarToAccess)
            
            print("Opening popup")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newEventPopUp") as! NewEventPopUpViewController
            addChildViewController(popOverVC)
            popOverVC.view.frame = view.frame
            view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            ViewController.newEventPopupIsVisible = true
        }
    }
    
    /**
     Signs in the user upon opening the app.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            signInButton.isHidden = true
            logo.isHidden = true
            refreshButton.isHidden = false
            newEventButton.isHidden = false
            service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    /**
     Construct a query and get a list of upcoming events from the user calendar.
     */
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarToAccess)
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    /**
     Display the start dates and event titles in the UITextView
     */
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        self.events.removeAll()
        if let events = response.items, !events.isEmpty {
            for event in events {
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = DateFormatter.localizedString(
                    from: start.date,
                    dateStyle: .short,
                    timeStyle: .short)
                let description = event.descriptionProperty ?? ""
                outputText = "\(startString) - \(event.summary!)\(description.count > 0 ? ": " + description : "")"
                self.events.append((id: event.identifier!, description: outputText))
                print(outputText)
            }
        } else {
            self.events.append((id: "0", description: "No upcoming events found."))
        }
        collectionView!.reloadData()
    }
    
    /**
     Removes the provided event from a Google Calendar
     
     - Parameter eventID: A unique identifier for the Google Calendar event to be deleted.
     - Parameter calendar: A unique identifier for the Google Calendar from which an event is to be deleted.
     - Requires: The event corresponding to the provided eventId must exist on the provided calendar.
     - Note: Deleted events cannot be recovered.
     */
    func removeEvent(eventId: String, from calendar: String) {
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: calendar, eventId: eventId)
        service.executeQuery(query, completionHandler: {(callbackTicket, event, callbackError) in
            if callbackError == nil {
                print("Deletion succeeded")
                self.refreshView(self)
            } else {
                self.showAlert(title: "Error", message: String(describing: callbackError))
                print(String(describing: callbackError))
            }
        })
    }
    
    /**
     Adds an event to a Google Calendar.
     - Parameter event: A `GTLRCalendar_Event` object, representing an event to be added to a Google Calendar.
     - Parameter calendar: A unique identifier for a Google Calendar to which an event will be added.
     - Note: It is recommended to use the GCalEventBuilder to create an event that can be passed to this function
     */
    func addEvent(event: GTLRCalendar_Event, to calendar: String) {
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: calendar)
        service.executeQuery(query, completionHandler: {(callbackTicket, event, callbackError) in
            if callbackError == nil {
                print("Add succeeded")
                self.refreshView(self)
            } else {
                self.showAlert(title: "Error", message: String(describing: callbackError))
                print("There was an error: \(String(describing: callbackError))")
            }
        })
    }
    
    /**
     Builds a new Google Calendar event
     - Parameter summary: The title of the event.
     - Parameter description: A more detailed *(optional)* description of the event.
     - Parameter startTime: The time at which the event is scheduled to begin.
     - Parameter endTime: The time at which the event is scheduled to end.
     - Returns: A Google Calendar event that can be used with the Google Calendar API.
     */
    func GCalEventBuilder(summary: String, description descriptionProperty: String?, startTime: NSDate, endTime: NSDate) -> GTLRCalendar_Event {
        let event = GTLRCalendar_Event()
        
        // Event title and (optional) description
        event.summary = summary
        event.descriptionProperty = descriptionProperty
        
        // Start and End times
        let offsetMinutes = NSTimeZone().secondsFromGMT(for: startTime as Date) / 60
        event.start = GTLRCalendar_EventDateTime()
        event.start!.dateTime = GTLRDateTime(date: startTime as Date, offsetMinutes: offsetMinutes)
        event.end = GTLRCalendar_EventDateTime()
        event.end!.dateTime = GTLRDateTime(date: endTime as Date, offsetMinutes: offsetMinutes)
        
        /// This may come in handy later, for dealing with permissions:
        /// event.guestsCanSeeOtherGuests = False
        
        return event
    }
    
    /**
     Helper for showing an alert
     - Parameter title: The title of the alert popup
     - Parameter message: The body of the alert popup
     */
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {

    /**
     Tell the CollectionView how many cells you need
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    /**
     Give the CollectionView the cell you want it to display at indexPath
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! CalendarCell
        cell.textLabel.text = events[indexPath.item].description
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.gray : UIColor.lightGray
        return cell
    }
    
    /**
     Tell the CollectionView what size to make the cell at indexPath
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (view.frame.height - navHeight) / CGFloat(numberOfCells))
    }
    
    /**
     Handle what happens when you tap on a cell
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = events[indexPath.item].id
        print("You clicked on item \(indexPath.item), which has ID \(id).")
        if id != "0" {
            print("Now deleting...")
            removeEvent(eventId:id, from: calendarToAccess)
        }
    }
    
}
