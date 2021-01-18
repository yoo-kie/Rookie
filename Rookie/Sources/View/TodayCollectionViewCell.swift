//
//  TodayCollectionViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class TodayCollectionViewCell: UICollectionViewCell {
    @IBOutlet var todayView: UIView!
    @IBOutlet var todayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todayView.layer.cornerRadius = 10
    }
}
