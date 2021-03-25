//
//  RookiesCollectionViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2020/10/25.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class RookiesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var characterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(rookies: [Rookie], indexPath: IndexPath) {
        characterImageView.image = UIImage.init(named: rookies[indexPath.row].rawValue)
    }
    
}
