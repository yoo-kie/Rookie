//
//  DetailModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/19.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

protocol DetailModelDelegate {
    func detailModel(mainTasks: [Tasks], mainDoneTasks: [Tasks], mainRookie: String)
}

class DetailModel {
    var delegate: DetailModelDelegate?
    
    func fetchMain(of date: String) {
        let mainTasks = DBManager.shared.selectTasksWithDate(date)
        let mainDoneTasks = DBManager.shared.selectDoneTasksWithDate(date)
        guard let mainRookie = DBManager.shared.selectCharacterWithDate(date) else {
            return
        }
        delegate?.detailModel(mainTasks: mainTasks, mainDoneTasks: mainDoneTasks, mainRookie: mainRookie)
    }
    
    func updateTask(of data: [String: Any], completionHandler: (() -> Void)?) {
        DBManager.shared.updateTask(data)
        
        guard let _completionHandler = completionHandler else {
            return
        }
        _completionHandler()
    }
}
