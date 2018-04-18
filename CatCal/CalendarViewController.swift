//
//  CalendarViewController.swift
//  CatCal
//
//  Created by Michael on 4/16/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import UIKit

/**
 The View Controller for the Tab View, which controls the Day, Week, and Month views
 as well as the New Event view.
 */
class CalendarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NewEventViewController {
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "NewEvent") {
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        return true
    }
}
