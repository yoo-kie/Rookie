//
//  EditModel.swift
//  Rookie
//
//  Created by 유연주 on 2020/12/28.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation

protocol EditModelDelegate {
    func editModel(todayTasks: [Tasks])
}

final class EditModel {
    var delegate: EditModelDelegate?
    
    func fetchTodayTasks(of date: String) {
        let todayTasks = DBManager.shared.selectTasks(with: date)
        delegate?.editModel(todayTasks: todayTasks)
    }
    
    func addTodayTask(text title: String?, date: String, completionHandler: @escaping () -> ()) {
        if !(title?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            let task = Tasks()
            task.id = DBManager.shared.incrementTaskID()
            task.character = Rookie.todayRookie
            task.date = date
            task.title = title ?? " "
            task.done_yn = "N"
            
            DBManager.shared.addTask(task)
            completionHandler()
        }
    }
    
    func deleteTodayTask(with id: Int, completionHandler: @escaping () -> ()) {
        DBManager.shared.deleteTaskWithID(id)
        completionHandler()
    }
}
