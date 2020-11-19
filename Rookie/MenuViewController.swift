//
//  MenuViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/11/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet var characterCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        characterCollectionView.delegate = self
        characterCollectionView.dataSource = self
        characterCollectionView.register(UINib(nibName: "CharacterCollectionViewCell", bundle: nil),
                                         forCellWithReuseIdentifier: "characterCell")
        characterCollectionView.layer.cornerRadius = 10
    }

}

extension MenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.characterCollectionView {
            return CGSize(width: 30, height: 30)
        } else {
            return CGSize(width: 30, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.characterCollectionView {
            return DBManager.shared.characterCollection.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.characterCollectionView {
            guard let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as? CharacterCollectionViewCell else {
                return CharacterCollectionViewCell()
            }
            
            return self.setCharaterCell(cell: cell, indexPath: indexPath)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func setCharaterCell(cell: CharacterCollectionViewCell, indexPath: IndexPath) -> CharacterCollectionViewCell {
        cell.characterImageView.image = UIImage.init(named: DBManager.shared.characterCollection[indexPath.row])
        return cell
    }
    
}
