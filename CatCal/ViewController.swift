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

class ViewController: UICollectionViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    // Google API related
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    
    var calendarToAccess = "u.northwestern.edu_uuh3sk34il40hq330fm95jiaic@group.calendar.google.com"
    
    // Layout related
    let numberOfCells = 24
    let cellID = "CalendarCell"
    var colorCounter = 0
    let navHeight: CGFloat = 64.0
    var events: [(id: String, description: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.delegate = self
        self.collectionView!.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        // view.addSubview(signInButton)
        self.collectionView!.addSubview(signInButton)
    }
    
    // Reset local variables, update list of events, and refresh the view
    @IBAction func refreshView(_ sender: Any) {
        colorCounter = 0
        fetchEvents()
        self.collectionView!.reloadData()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            signInButton.isHidden = true
            service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
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
    
    // Display the start dates and event summaries in the UITextView
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
                outputText = "\(startString) - \(event.summary!)"
                self.events.append((id: event.identifier!, description: outputText))
            }
        } else {
            self.events.append((id: "0", description: "No upcoming events found."))
        }
    }

    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
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

    // Tell the CollectionView how many cells you need
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    // Give the CollectionView the cell you want it to display at indexPath
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! CalendarCell
        cell.textLabel.text = events[indexPath.item].description
        cell.backgroundColor = colorCounter % 2 == 0 ? UIColor.gray : UIColor.lightGray
        colorCounter = colorCounter + 1
        return cell
    }
    
    // Tell the CollectionView what size to make the cell at indexPath
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (view.frame.height - navHeight) / CGFloat(numberOfCells))
    }
    
    // Handle what happens when you tap on a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You clicked on item \(indexPath.item), which has ID \(events[indexPath.item].id)")
    }
    
}
