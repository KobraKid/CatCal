//
//  FriendViewController.swift
//  CatCal
//
//  Created by Michael on 4/20/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController {
    
    var friendName: String?

    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply title
        self.title = friendName
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
    }
}
