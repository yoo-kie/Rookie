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
    
    private let menuModel = MenuModel()
    private var rookiesUICollectionViewDataSource = RookiesUICollectionViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureColletionView()
        setMenuUI()
        
        menuModel.fetchRookies(with: menuDate) { [weak self] rookies in
            guard let self = self else { return }
            self.rookiesUICollectionViewDataSource.rookies = rookies
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
        rookiesCollectionView.delegate = rookiesUICollectionViewDataSource
        rookiesCollectionView.dataSource = rookiesUICollectionViewDataSource
        rookiesCollectionView.register(
            UINib(nibName: "RookiesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "rookiesCell"
        )
    }
    
}
