//
//  Todo.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/22.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

enum Todo: String, CaseIterable {
    
    case today = "오늘"
    case tomorrow = "내일"
    
    var actionTitle: String {
        switch self {
        case .today:
            return "내일하기"
        case .tomorrow:
            return "오늘하기"
        }
    }
    
}
