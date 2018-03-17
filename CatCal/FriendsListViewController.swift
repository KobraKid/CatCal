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
    let cellCount: CGFloat = 8; /* Number of cells to be shown on screen at a time */
    var friendList: [(id: String, name: String, free: [Int])] = [] /* A list of the user's friends */
    var selectedFriend = -1
    let myFreeTime = [4, 3, 1, 2, 2, 3]

    override func viewDidLoad() {
        super.viewDidLoad()
        log.info("Friends List opened");
        
        collectionView!.delegate = self
        collectionView!.register(FriendCell.self, forCellWithReuseIdentifier: cellID)
        
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! FriendCell
        cell.textView.text = friendList[indexPath.item].name
            
        if (indexPath.item == selectedFriend) {
            cell.textView.text = cell.textView.text! + " - "
            for time in 0...(friendList[indexPath.item].free.count - 1) {
                cell.textView.text = cell.textView.text! + (time % 2 == 0 ? " Free " : " Busy ") + String(describing: friendList[indexPath.item].free[time]) + "hr(s)"
            }
            cell.textView.text = cell.textView.text! + "\nMy schedule: "
            for time in 0...(myFreeTime.count - 1) {
                cell.textView.text = cell.textView.text! + (time % 2 == 0 ? " Free " : " Busy ") + String(describing: myFreeTime[time]) + "hr(s)"
            }
        }
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.white : UIColor.lightGray
        return cell
    }
    
    /**
     Tell the CollectionView what size to make the cell at indexPath
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: (indexPath.item == selectedFriend ? cellCount : 1) * (view.frame.height - ViewController.navHeight) / cellCount)
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
        if (selectedFriend == indexPath.item) {
            selectedFriend = -1
        }
        else {
            selectedFriend = indexPath.item;
        }
        collectionView.reloadData()
    }
    
}

