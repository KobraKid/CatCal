//
//  NewEventPopOverViewController.swift
//  CatCal
//
//  Created by Michael on 12/12/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import UIKit

/**
 A ViewController used to control a **New Event** button press. Creates a popup over the previous view, with a semi-transparent background. Prompts the user to fill out information in order to create a new Google Calendar event.
 */
class NewEventPopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimate()
    }
    
    /**
     Animation for when the popup is opened.
     */
    func showAnimate() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    /**
     Dismisses the popup.
     */
    @IBAction func closePopUp(_ sender: Any) {
        ViewController.newEventPopupIsVisible = false
        removeAnimate()
    }
    
    /**
     Animation for when the popup is closed.
     */
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: { (finished: Bool) in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }

}
