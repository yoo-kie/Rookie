//
//  EditTableViewCell.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/25.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

class EditTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(title: String) {
        let font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
        textLabel!.font = font
        textLabel?.text = title
    }
    
}
