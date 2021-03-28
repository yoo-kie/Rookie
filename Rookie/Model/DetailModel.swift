//
//  DetailModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/19.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

final class DetailModel {
    
    func fetchTasks(of date: String, completionHandler: @escaping ([Tasks], [Tasks]) -> Void) {
        let mainTasks = DBManager.shared.selectTasks(with: date)
        let mainDoneTasks = DBManager.shared.selectDoneTasks(with: date)
        
        completionHandler(mainTasks, mainDoneTasks)
    }
    
    func fetchRookie(of date: String, completionHandler: @escaping (String) -> Void) {
        guard let mainRookie = DBManager.shared.selectRookie(with: date) else {
            return
        }
        
        completionHandler(mainRookie)
    }
    
    func updateTask(of data: [String: Any], completionHandler: (() -> Void)?) {
        DBManager.shared.updateTask(data)
        
        guard let _completionHandler = completionHandler else {
            return
        }
        
        _completionHandler()
    }
    
}
