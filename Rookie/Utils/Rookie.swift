//
//  Common.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/21.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

enum Rookie: String {
    
    case R1 = "뽀짝이"
    case R2 = "뽀록희"
    case R3 = "키캡"
    
    static var todayRookie: String = R1.fullName
    
    var versions: Int {
        switch self {
        case .R1:
            return 3
        case .R2:
            return 2
        case .R3:
            return 1
        }
    }
    
    var fullName: String {
        let version = arc4random_uniform(UInt32(self.versions)) + 1
        return "\(self.rawValue)\(version)"
    }
    
}

enum Level {
    
    case L1
    case L2
    case L3
    case L4
    case L5
        
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
    
    var imageName: String {
        switch self {
        case .L1:
            return "\(Rookie.todayRookie)_1"
        case .L2:
            return "\(Rookie.todayRookie)_2"
        case .L3:
            return "\(Rookie.todayRookie)_3"
        case .L4:
            return "\(Rookie.todayRookie)_4"
        case .L5:
            return "\(Rookie.todayRookie)_5"
        }
    }
    
    static func fetchLevel(total: Int, done: Int) -> Level {
        let level = (4.0 / Float(total)) * Float(done)
        
        switch level {
        case 0..<1:
            return .L1
        case 1..<2:
            return .L2
        case 2..<3:
            return .L3
        case 3..<4:
            return .L4
        case 4:
            return .L5
        default:
            return .L1
        }
    }
    
}

