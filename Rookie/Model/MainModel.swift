//
//  MainModel.swift
//  Rookie
//
//  Created by 유연주 on 2020/12/28.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation

protocol MainModelDelegate {
    func mainModel(mainTasks: [Tasks], mainDoneTasks: [Tasks])
    func mainModel(thisMonthDates: [String])
    func mainModel(mainRookie: String)
}

final class MainModel {
    var delegate: MainModelDelegate?
    
    func fetchMain(of date: String) {
        let mainTasks = DBManager.shared.selectTasksWithDate(date)
        let mainDoneTasks = DBManager.shared.selectDoneTasksWithDate(date)
        
        delegate?.mainModel(mainTasks: mainTasks, mainDoneTasks: mainDoneTasks)
    }
    
    func fetchDates(of today: String) {
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        
        let thisMonthDates = DBManager.shared.getDates(of: month)
        self.setRookie(of: today, thisMonthDates: thisMonthDates)
        delegate?.mainModel(thisMonthDates: thisMonthDates)
    }
    
    func setRookie(of today: String, thisMonthDates: [String]) {
        let rookies = DBManager.shared.rookiesCollection
        var todayRookie: String = ""
        var rookieVersionCount: Int = 1
        
        switch thisMonthDates.count {
        case 0..<10:
            todayRookie = rookies[0]
            rookieVersionCount = 3
        case 10..<20:
            todayRookie = rookies[1]
            rookieVersionCount = 2
        default:
            todayRookie = rookies[2]
            rookieVersionCount = 1
        }
        
        let randomVersion = arc4random_uniform(UInt32(rookieVersionCount)) + 1
        let todayRookieName = "\(todayRookie)\(randomVersion)"
        
        if let rookieName = DBManager.shared.selectCharacterWithDate(today) {
            DBManager.shared.todayRookie = rookieName
        } else {
            DBManager.shared.todayRookie = todayRookieName
        }
        
        delegate?.mainModel(mainRookie: DBManager.shared.todayRookie)
    }
    
    func updateTask(of data: [String: Any], completionHandler: (() -> Void)?) {
        DBManager.shared.updateTask(data)
        
        guard let _completionHandler = completionHandler else {
            return
        }
        _completionHandler()
    }
}

enum UpdateProperty {
    case character
    case date
    case title
    case done_yn
}
