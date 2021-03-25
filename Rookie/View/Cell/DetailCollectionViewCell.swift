//
//  DetailCollectionViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2020/09/07.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailView.layer.cornerRadius = Constant.Layer.cornerRadius
    }
    
    func bind(tasks: [Tasks], indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let title = task.title
        let doneYN = task.done_yn
        
        detailLabel.text = title
        
        if doneYN == "Y" {
            detailLabel.textColor = .white
            detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            detailLabel.textColor = .black
            detailView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
        }
    }
    
    func update(doneYN: String) {
        if doneYN == "N" {
            detailLabel.textColor = .white
            detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else if doneYN == "Y" {
            detailLabel.textColor = .black
            detailView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
        }
    }

}
