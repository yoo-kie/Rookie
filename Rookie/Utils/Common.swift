//
//  Common.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/21.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

enum Rookie {
    
    case L1
    case L2
    case L3
    case L4
    case L5
    
    static var name: String = "뽀짝이_"
        
    var labelText: String {
        switch self {
        case .L1:
            return "Level 1"
        case .L2:
            return "Level 2"
        case .L3:
            return "Level 3"
        case .L4:
            return "Level 4"
        case .L5:
            return "Level 5"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .L1:
            return UIImage.init(named: "\(Rookie.name)1")
        case .L2:
            return UIImage.init(named: "\(Rookie.name)2")
        case .L3:
            return UIImage.init(named: "\(Rookie.name)3")
        case .L4:
            return UIImage.init(named: "\(Rookie.name)4")
        case .L5:
            return UIImage.init(named: "\(Rookie.name)5")
        }
    }
    
}

