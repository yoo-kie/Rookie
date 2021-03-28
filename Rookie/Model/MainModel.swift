//
//  MainModel.swift
//  Rookie
//
//  Created by 유연주 on 2020/12/28.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation

protocol MainModelDelegate {
    
    func mainModel(todoTasks: [Tasks], todoDoneTasks: [Tasks])
    func mainModel(dates: [String])
    
}

final class MainModel {
    
    func fetchTasks(with date: String, completionHandler: @escaping ([Tasks], [Tasks]) -> Void) {
        let todoTasks = DBManager.shared.selectTasks(with: date)
        let todoDoneTasks = DBManager.shared.selectDoneTasks(with: date)
        
        completionHandler(todoTasks, todoDoneTasks)
    }
    
    func fetchDates(of today: String, completionHandler: @escaping ([String]) -> Void) {
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        
        let dates = DBManager.shared.fetchDates(on: month)
        configureTodayRookie(of: today, with: dates)
        completionHandler(dates)
    }
    
    func configureTodayRookie(of today: String, with dates: [String]) {
        if let todayRookie = DBManager.shared.selectRookie(with: today) {
            Rookie.todayRookie = todayRookie
        } else {
            let rookie = fetchRookie(count: dates.count)
            Rookie.todayRookie = rookie.fullName
        }
    }
    
    func fetchRookie(count: Int) -> Rookie {
        switch count {
        case 0..<10:
            return .R1
        case 10..<20:
            return .R2
        default:
            return .R3
        }
    }
    
    func updateTask(of data: [String: Any], completionHandler: (() -> Void)) {
        DBManager.shared.updateTask(data)
        completionHandler()
    }
    
}
