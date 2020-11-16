//
//  DoneCollectionViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/20.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class LastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var lastView: UIView!
    @IBOutlet var lastLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lastView.layer.cornerRadius = 10
    }

    
}
