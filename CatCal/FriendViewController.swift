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
//    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timeStackView = UIStackView(frame: CGRect(x: scrollView.bounds.minX, y: scrollView.bounds.minY, width: 414, height: 800))
        timeStackView.axis = .vertical
        timeStackView.distribution = .equalSpacing
        
        // Populate time list
        let midnight = UILabel()
        midnight.text = "12 am"
        midnight.textColor = textColor
        timeStackView.addArrangedSubview(midnight)
        for i in 0...22 {
            let label = UILabel()
            label.text =  String(describing: (i % 12) + 1) + (i < 11 ? " am" : " pm")
            label.textColor = textColor
            timeStackView.addArrangedSubview(label)
        }

        self.scrollView.addSubview(timeStackView)
        
        // Apply theme
        self.view.backgroundColor = bgColor
        self.dateLabel.textColor = textColor
        
        // Apply title
        self.title = friendName
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 414, height: 800)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 414, height: 800)
    }
}

extension FriendViewController: UIScrollViewDelegate {
    
}
