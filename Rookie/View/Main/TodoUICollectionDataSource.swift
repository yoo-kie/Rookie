//
//  TodoUICollectionDataSource.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/27.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

class TodoUICollectionDataSource: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    typealias HandlerType = (IndexPath) -> Void
    let handler: HandlerType
    var todoTasks: [Tasks] = []
    
    init(handler: @escaping HandlerType) {
        self.handler = handler
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width / 1.5,
            height: collectionView.frame.height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if todoTasks.count == 0 {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
        
        return todoTasks.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? TodayCollectionViewCell
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath)
        }
        
        cell.bind(tasks: todoTasks, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        handler(indexPath)
    }
    
}
