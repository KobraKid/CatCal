//
//  APICallHandler.swift
//  CatCal
//
//  Created by Michael on 1/19/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import SwiftyJSON

/**
 The APICallHandler is used to handle API calls.
 */
protocol APICallHandler {
    func queryAPI(requestType: HTMLRequestType, params: [String : Any])
}

extension APICallHandler {
    fileprivate func notify() {
        log.verbose("Sending 🔄 \"Require Refresh\" notification")
        NotificationCenter.default.post(name: Notification.Name(rawValue: eventsRequireRefreshKey), object: self)
    }
}

/**
 Standardized HTML requests
 */
enum HTMLRequestType {
    case GET
    case DELETE
    case POST
}

// MARK: - Google Calendar API

/**
 Used to query the Google Calendar API
 */
class GoogleAPIHandler: NSObject, APICallHandler {
    
    // Google Calendar related objects
    var calendarToAccess = "u.northwestern.edu_uuh3sk34il40hq330fm95jiaic@group.calendar.google.com"
    
    func queryAPI(requestType: HTMLRequestType, params: [String : Any] = [:]) {
        switch requestType {
        case .GET:
            fetchEvents()
        case .DELETE:
            removeEvent(params)
        case .POST:
            addEvent(params)
        }
    }
    
    /**
     Construct a query and get a list of upcoming events from the user calendar.
     */
    private func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarToAccess)
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        LoginViewController.service.executeQuery(query, delegate: self, didFinish: #selector(updateEventsList(ticket:finishedWithObject:error:)))
    }
    
    /**
     Parse the events list returned by `fetchEvents()`, and sends them to the ViewController in a human-readable format.
     */
    @objc dynamic func updateEventsList(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : Error?) {
        
        if let error = error {
            DailyViewController.generalErrorTitle = "Error Fetching Events"
            DailyViewController.generalErrorMessage = error.localizedDescription
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
            return
        }
        
        var outputText = ""
        DailyViewController.events.removeAll()
        if let events = response.items, !events.isEmpty {
            for event in events {
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = DateFormatter.localizedString(
                    from: start.date,
                    dateStyle: .short,
                    timeStyle: .short)
                let description = event.descriptionProperty ?? ""
                outputText = "\(startString) - \(event.summary ?? "(No title)")\(description.count > 0 ? ": " + description : "")"
                DailyViewController.events.append((id: event.identifier!, description: outputText))
                //log.verbose(outputText)
            }
        } else {
            DailyViewController.events.append((id: "0", description: "No upcoming events found."))
        }
    }
    
    /**
     Removes the provided event from a Google Calendar
     
     - Parameter eventID: A unique identifier for the Google Calendar event to be deleted.
     - Parameter calendar: A unique identifier for the Google Calendar from which an event is to be deleted.
     - Requires: The event corresponding to the provided eventId must exist on the provided calendar.
     - Note: Deleted events cannot be recovered.
     */
    private func removeEvent(_ params: [String : Any]) {
        if let eventId = params["eventId"] as! String? {
            let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: calendarToAccess, eventId: eventId)
            LoginViewController.service.executeQuery(query, completionHandler: {(callbackTicket, event, callbackError) in
                if callbackError == nil {
                    log.verbose("Deletion succeeded")
                    self.notify()
                } else {
                    DailyViewController.generalErrorTitle = "Error Deleting Event"
                    DailyViewController.generalErrorMessage = callbackError!.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
                    log.warning(String(describing: callbackError))
                }
            })
        }
    }
    
    /**
     Adds an event to a Google Calendar.
     - Parameter event: A `GTLRCalendar_Event` object, representing an event to be added to a Google Calendar.
     - Parameter calendar: A unique identifier for a Google Calendar to which an event will be added.
     - Note: It is recommended to use the `GCalEventBuilder` to create an event that can be passed to this function
     */
    private func addEvent(_ params: [String: Any]) {
        if let event = params["event"] as! GTLRCalendar_Event? {
            let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: calendarToAccess)
            LoginViewController.service.executeQuery(query, completionHandler: {(callbackTicket, event, callbackError) in
                if callbackError == nil {
                    log.verbose("Add succeeded")
                    self.notify()
                } else {
                    DailyViewController.generalErrorTitle = "Error Creating Event"
                    DailyViewController.generalErrorMessage = callbackError!.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
                    log.warning(String(describing: callbackError))
                }
            })
        }
    }
    
}

// MARK: - Northwestern University API

/**
 Northwestern University API Handler
 */
class NUAPIHandler : NSObject, APICallHandler {
    
    // API Key
    private let key: String = "RhvuDhGcx5wcwujn"
    
    func queryAPI(requestType: HTMLRequestType, params: [String : Any]) {
        switch requestType {
        case .GET:
            getNUClasses(params: params)
        default:
            return
        }
    }
    
    private func getNUClasses(params: [String : Any]) {
        let urlEndPoint: String = "https://api.asg.northwestern.edu/terms/?key=" + key + "&term=4503&subject=SPANISH"
        guard let url = URL(string: urlEndPoint) else {
            log.warning("Error, invalid URL")
            return
        }
        
        log.verbose(urlEndPoint)
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler:{data, response, error in
            // Guard for errors
            guard error == nil else {
                log.warning("Error calling \(urlEndPoint) : \(error?.localizedDescription ?? "no description available.")")
                return
            }
            // Guard for empty data
            guard let responseData = data else {
                log.warning("No response data")
                return
            }
            
            /* Parse JSON */
            
            do {
                // Guard for poorly formatted JSON
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    log.warning("Could not create JSON")
                    return
                }
                log.info(json.description)
            } catch {
                log.warning("Error parsing JSON")
                return
            }
            
        })
        task.resume()
    }
    
}




