//
//  DetailCollectionViewCell.swift
//  RPG
//
//  Created by 유연주 on 2020/09/07.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet var detailView: UIView!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailView.layer.cornerRadius = 10
    }

}
