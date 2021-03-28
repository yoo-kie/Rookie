//
//  RookiesUICollectionViewDataSource.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/28.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

class RookiesUICollectionViewDataSource: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var rookies: [Rookie] = []
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.rookies.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rookiesCell", for: indexPath) as? RookiesCollectionViewCell
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "rookiesCell", for: indexPath)
        }
            
        cell.bind(rookies: rookies, indexPath: indexPath)
        
        return cell
    }
    
}
