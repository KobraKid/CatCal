//
//  NewEventPopOverViewController.swift
//  CatCal
//
//  Created by Michael on 12/12/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit

/**
 A ViewController used to control a **New Event** button press. Creates a popup over the previous view, with a semi-transparent background. Prompts the user to fill out information in order to create a new Google Calendar event.
 
 Once sufficient event details have been specified and **Okay** is pressed, a new `GTLRCalendar_Event` object is created, and sent to an API query.
 */
class NewEventPopUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    private let googleCalendar = GoogleAPIHandler()
    
    // MARK: - Popup Lifecycle
    
    /**
     Initializes the popup.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimation()
    }
    
    /**
     Dismisses the popup.
     */
    @IBAction func closePopUp(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == 0 && titleTextField.text!.count > 0 && startTime.date < endTime.date {
            log.debug("New event was valid")
            let event = GCalEventBuilder(summary: titleTextField.text!, description: descriptionTextField.text, startTime: startTime.date as NSDate, endTime: endTime.date as NSDate)
            googleCalendar.queryAPI(requestType: .POST, params: ["event" : event])
        } else {
            log.debug("Event was invalid or cancelled")
            ViewController.generalErrorTitle = "Error: Bad Event"
            ViewController.generalErrorMessage = "Either the event title was empty, or the start time was later than the end time.\nPlease try again."
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
        }
        removeAnimation()
    }
    
    // MARK: - Animation
    
    /**
     Animation for when the popup is opened.
     */
    func showAnimation() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    /**
     Animation for when the popup is closed.
     */
    func removeAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: { (finished: Bool) in
            if finished {
                ViewController.newEventPopupIsVisible = false
                self.view.removeFromSuperview()
            }
        })
    }
    
    // MARK: - Convenience Methods
    
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

}
