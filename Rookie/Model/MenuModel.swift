//
//  MenuModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/18.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

protocol MenuModelDelegate {
    func menuModel(rookies: [Rookie])
}

final class MenuModel {
    var delegate: MenuModelDelegate?
    
    func fetchRookieCollection(of today: String) {
        var rookies: [Rookie] = []
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        let thisMonthDates = DBManager.shared.fetchDates(on: month)
        
        switch thisMonthDates.count {
        case 0..<10:
            rookies.append(.R1)
        case 10..<20:
            rookies.append(contentsOf: [.R1, .R2])
        default:
            rookies.append(contentsOf: [.R1, .R2, .R3])
        }
        
        delegate?.menuModel(rookies: rookies)
    }
}
