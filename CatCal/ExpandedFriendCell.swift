//
//  ExpandedFriendCell.swift
//  CatCal
//
//  Created by Michael on 3/17/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import UIKit

class ExpandedFriendCell: FriendCell {
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let rectangleWidth: CGFloat = self.frame.size.width / 2
        let rectangleHeight: CGFloat = self.frame.size.height / 2
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.addRect(CGRect(x: center.x - (0.5 * rectangleWidth), y: center.y - (0.5 * rectangleHeight), width: rectangleWidth, height: rectangleHeight))
        ctx.setLineWidth(10)
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.strokePath()
        
        if (arc4random_uniform(2) % 2 == 0) {
            ctx.setFillColor(UIColor.green.cgColor)
        } else {
            ctx.setFillColor(UIColor.red.cgColor)
        }
        
        ctx.addRect(CGRect(x: center.x - (0.5 * rectangleWidth), y: center.y - (0.5 * rectangleHeight), width: rectangleWidth, height: rectangleHeight))
        
        ctx.fillPath()
    }
    
}
