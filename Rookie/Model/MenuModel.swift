//
//  MenuModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/18.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

final class MenuModel {
    
    func fetchRookies(with today: String, completionHandler: @escaping ([Rookie]) -> Void) {
        var rookies: [Rookie] = []
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        let dates = DBManager.shared.fetchDates(on: month)
        
        switch dates.count {
        case 0..<10:
            rookies.append(.R1)
        case 10..<20:
            rookies.append(contentsOf: [.R1, .R2])
        default:
            rookies.append(contentsOf: [.R1, .R2, .R3])
        }
        
        completionHandler(rookies)
    }
    
}
