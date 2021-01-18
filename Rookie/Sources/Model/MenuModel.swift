//
//  MenuModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/18.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

protocol MenuModelDelegate {
    func menuModel(rookies: [String])
}

class MenuModel {
    var delegate: MenuModelDelegate?
    
    func fetchRookieCollection(of today: String) {
        var rookies = DBManager.shared.rookiesCollection
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        let thisMonthDates = DBManager.shared.getDates(of: month)
        
        switch thisMonthDates.count {
        case 0..<10:
            rookies = Array(arrayLiteral: rookies[0])
        case 10..<20:
            rookies = Array(rookies[0...1])
        default:
            rookies = Array(rookies[0...2])
        }
        
        delegate?.menuModel(rookies: rookies)
    }
}
