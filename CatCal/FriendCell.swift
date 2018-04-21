//
//  FriendCell.swift
//  CatCal
//
//  Created by Michael on 3/17/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import UIKit

/**
 A cell used to represent the collapsed/minimized version of a Friend on the Friends page.
 */
class FriendCell: UICollectionViewCell {
    
    var textView: UITextView!
    let padding: CGFloat = 10.0
    var freeTime = [Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textView = UITextView(frame: CGRect(x: padding, y: 0, width: frame.size.width - CGFloat(2 * padding), height: frame.size.height / 2))
        textView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        textView.textColor = UIColor.white
        textView.textAlignment = .natural
        textView.backgroundColor = UIColor.clear
        textView.isUserInteractionEnabled = false
        contentView.addSubview(textView)
    }
    
    func setFreeTime(times: [Int]) {
        self.freeTime = times
    }
    
    /**
     This initializer is called instead of init(frame:) when the class gets initialized from a storyboard or a xib file. That'll never be the case here, but we still need to provide init(coder:).
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
