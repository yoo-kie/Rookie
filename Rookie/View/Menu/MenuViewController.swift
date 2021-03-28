//
//  MenuViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/11/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import AVKit

final class MenuViewController: UIViewController {
    
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var rookiesCollectionView: UICollectionView!
    
    var menuDate: String = ""
    private var rookies: [Rookie] = []
    
    private let menuModel = MenuModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureColletionView()
        setMenuUI()
        
        menuModel.fetchRookies(with: menuDate) { [weak self] rookies in
            guard let self = self else { return }
            self.rookies = rookies
        }
    }

    func setMenuUI() {
        rookiesCollectionView.layer.cornerRadius = Constant.Layer.cornerRadius
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if let version = version {
            versionLabel.text = version
        }
    }
    
    func configureColletionView() {
        rookiesCollectionView.delegate = self
        rookiesCollectionView.dataSource = self
        rookiesCollectionView.register(
            UINib(nibName: "RookiesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "rookiesCell"
        )
    }
    
}

extension MenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
