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
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let graphWidth: CGFloat = self.frame.size.width * 0.9
        let graphHeight: CGFloat = self.frame.size.height * 0.85
        let zeroX = center.x - (graphWidth / 2)
        let zeroY = center.y - (graphHeight / 2) + (self.frame.size.height / 20) // move it down from the center by 5%
        
        ctx.setFillColor(UIColor.lightGray.cgColor)
        ctx.addRect(CGRect(x: zeroX, y: zeroY, width: graphWidth, height: graphHeight))
        ctx.fillPath()
        
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.addRect(CGRect(x: zeroX, y: zeroY, width: graphWidth, height: graphHeight))
        ctx.strokePath()
        
        for index in 0...24 {
            ctx.beginPath()
            let offset: CGFloat = CGFloat(index)
            ctx.move(to: CGPoint(x: zeroX, y: zeroY + (offset * graphHeight / 24)))
            ctx.addLine(to: CGPoint(x: zeroX + graphWidth, y: zeroY + (offset * graphHeight / 24)))
            ctx.strokePath()
        }
        drawFriendFreeTime(ctx, x: zeroX, y: zeroY, width: graphWidth, height: graphHeight)
    }
    
    func drawFriendFreeTime(_ ctx: CGContext, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        ctx.setFillColor(UIColor.red.cgColor)
        ctx.setAlpha(0.5)
        var index: Int = 0
        var free = true;
        var offset: CGFloat = 0
        while offset < 24 && index < freeTime.count {
            log.info("Running drawFriendFreeTime loop \(String(describing: freeTime[index]))")
            if (free) {
                ctx.addRect(CGRect(x: x + (width / 3),
                               y: y + (offset * height / 24),
                               width: width * 2 / 3,
                               height: (height / 24) * CGFloat(freeTime[index])))
                ctx.fillPath()
            }
            offset += CGFloat(freeTime[index])
            free = !free
            index += 1
        }
        ctx.setFillColor(UIColor.blue.cgColor)
        ctx.setAlpha(0.5)
        index = 0
        free = true;
        offset = 0.0
        while offset < 24 && index < FriendsListViewController.myFreeTime.count {
            log.info("Running drawMyFreeTime loop \(String(describing: FriendsListViewController.myFreeTime[index]))")
            if (free) {
                ctx.addRect(CGRect(x: x,
                                   y: y + (offset * height / 24),
                                   width: width * 2 / 3,
                                   height: (height / 24) * CGFloat(FriendsListViewController.myFreeTime[index])))
                ctx.fillPath()
            }
            offset += CGFloat(FriendsListViewController.myFreeTime[index])
            free = !free
            index += 1
        }
    }
    
}
