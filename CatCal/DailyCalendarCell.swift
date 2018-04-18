//
//  CalendarCell.swift
//  CatCal
//
//  Created by Michael on 12/5/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import UIKit

/**
 A custom implementation of the UICollectionViewCell for use with the daily view
 on the main screen of the app. This cell supports custom fill color, and other
 tweaks can be added as needed for cosmetic appeal.
 */
class DailyCalendarCell: UICollectionViewCell {
 
    var textLabel: UILabel!
    let padding: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: padding, y: 0, width: frame.size.width - CGFloat(2 * padding), height: frame.size.height))
        textLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        textLabel.textAlignment = .natural
        contentView.addSubview(textLabel)
    }
    
    /**
     This initializer is called instead of init(frame:) when the class gets initialized from a storyboard or a xib file. That'll never be the case here, but we still need to provide init(coder:). 
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
