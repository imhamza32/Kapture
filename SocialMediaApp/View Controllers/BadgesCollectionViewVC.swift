//
//  ViewController.swift
//  TableViewPractice
//
//  Created by Munib Hamza on 06/01/2023.
//

import UIKit

class BadgesCollectionViewVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //array of images assets
    var badgeImages: [UIImage] = [
        UIImage(named: "signUp")!,
        UIImage(named: "1st")!,
        UIImage(named: "20th")!,
        UIImage(named: "50th")!,
        UIImage(named: "master")!
    ]
    
    var labels:[String] = ["TutorialKart","Swift Tutorial","TutorialKart","Swift Tutorial","TutorialKart","Swift Tutorial","TutorialKart","Swift Tutorial","TutorialKart","Swift Tutorial","TutorialKart","Swift Tutorial"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "BadgesCVCell", bundle: nil), forCellWithReuseIdentifier: "BadgesCVCell")
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension BadgesCollectionViewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3
        
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgesCVCell", for: indexPath) as! BadgesCVCell
        
        cell.imageInCell.image = badgeImages[indexPath.row]
        cell.labelInCell.text = labels[indexPath.row]
        if indexPath.item == Int.random(in: 0...10) || indexPath.item == Int.random(in: 0...10) || indexPath.item == Int.random(in: 0...10) || indexPath.item == Int.random(in: 0...10) || indexPath.item == Int.random(in: 0...10) {
            cell.greyVu.isHidden = false
        } else {
            cell.greyVu.isHidden = true
        }
        return cell
    }
}
