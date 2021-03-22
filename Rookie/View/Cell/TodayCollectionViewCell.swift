//
//  TodayCollectionViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class TodayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var todayView: UIView!
    @IBOutlet var todayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todayView.layer.cornerRadius = 10
    }
    
    func bind(tasks: [Tasks], indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let title = task.title
        let doneYN = task.done_yn
        
        todayLabel.text = title
        
        if doneYN == "Y" {
            todayLabel.textColor = .white
            todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            todayLabel.textColor = .black
            todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
        }
    }
    
    func update(doneYN: String) {
        if doneYN == "N" {
            todayLabel.textColor = .white
            todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else if doneYN == "Y" {
            todayLabel.textColor = .black
            todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
        }
    }
    
}
