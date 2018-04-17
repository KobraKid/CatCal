//
//  FriendsListViewController.swift
//  CatCal
//
//  Created by Michael on 3/17/18.
//  Copyright © 2018 DotDev. All rights reserved.
//

import UIKit

class FriendsListViewController: UICollectionViewController {
    
    let cellID = "FriendCell"
    let cellID2 = "ExtendedFriendCell"
    let cellCount: CGFloat = 8; /* Number of cells to be shown on screen at a time */
    var friendList: [(id: String, name: String, free: [Int])] = [] /* A list of the user's friends */
    var selectedFriend = -1
    public static let myFreeTime = [6, 2, 1, 3, 8]

    override func viewDidLoad() {
        super.viewDidLoad()
        log.info("Friends List opened");
        
        collectionView!.delegate = self
        collectionView!.register(FriendCell.self, forCellWithReuseIdentifier: cellID)
        collectionView!.register(ExpandedFriendCell.self, forCellWithReuseIdentifier: cellID2)
        
        getFriends()
    }
    
    func getFriends() {
        let friendCount = 12;
        for i in 0...(friendCount - 1) {
            let gaps: Int = Int(arc4random_uniform(6))
            var free: [Int] = []
            let maxGap: Int = 24 / (gaps + 1)
            log.debug(String(describing: gaps) + " " + String(describing: maxGap))
            for _ in 0...gaps {
                free.append(1 + Int(arc4random_uniform(UInt32(maxGap))))
            }
            friendList.append((id: String(describing: i), name: "Friend #" + String(describing: i), free: free))
        }
    }

    @IBAction func refreshList(_ sender: Any) {
        self.collectionView!.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendsListViewController: UICollectionViewDelegateFlowLayout {
    
    /**
     Tell the CollectionView how many cells you need
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    /**
     Give the CollectionView the cell you want it to display at indexPath
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: FriendCell
        
        // If the current cell is the one the user has expanded, make it a type `ExpandedFriendCell` and position it at the top of the screen
        if (indexPath.item == selectedFriend) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID2, for: indexPath) as! ExpandedFriendCell
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! FriendCell
        }
        
        cell.textView.text = friendList[indexPath.item].name
        
        // If the current cell is the one the user has expanded,
        if (indexPath.item == selectedFriend) {
            // append a dash,
            cell.textView.text = cell.textView.text! + " - "
            // append free and busy times for the friend,
            for time in 0...(friendList[indexPath.item].free.count - 1) {
                cell.textView.text = cell.textView.text! + (time % 2 == 0 ? " Free " : " Busy ") + String(describing: friendList[indexPath.item].free[time]) + "hr(s)"
            }
            // append my schedule text,
            cell.textView.text = cell.textView.text! + "\nMy schedule: "
            // and finally append my free and busy times
            for time in 0...(FriendsListViewController.myFreeTime.count - 1) {
                cell.textView.text = cell.textView.text! + (time % 2 == 0 ? " Free " : " Busy ") + String(describing: FriendsListViewController.myFreeTime[time]) + "hr(s)"
            }
            
            // Set free time array
            cell.setFreeTime(times: friendList[indexPath.item].free)
        }
        
        // Zebra-stripe the cells
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.white : UIColor.lightGray
        return cell
    }
    
    /**
     Tell the CollectionView what size to make the cell at indexPath
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (indexPath.item == selectedFriend ? cellCount : 1) * (view.frame.height - DailyViewController.navHeight) / cellCount)
    }
    
    /**
     Horizontal spacing between items
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     Vertical spacing between items
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     Handle what happens when you tap on a cell
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = friendList[indexPath.item].id
        log.debug("You clicked on item \(indexPath.item), which has ID \(id)")
        // Clear the selected friend, reenable scrolling
        if (selectedFriend == indexPath.item) {
            selectedFriend = -1
            collectionView.isScrollEnabled = true
        }
        // Set the selected friend, disable scrolling
        else {
            selectedFriend = indexPath.item;
            collectionView.isScrollEnabled = false
        }
        collectionView.reloadData()
    }
    
}

