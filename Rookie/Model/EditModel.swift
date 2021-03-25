//
//  EditModel.swift
//  Rookie
//
//  Created by 유연주 on 2020/12/28.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation

final class EditModel {
    
    func fetchTasks(with date: String, completionHandler: @escaping ([Tasks]) -> Void) {
        let todayTasks = DBManager.shared.selectTasks(with: date)
        completionHandler(todayTasks)
    }
    
    func addTask(text title: String?, date: String, completionHandler: @escaping () -> Void) {
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
    
    func deleteTask(with id: Int, completionHandler: @escaping () -> Void) {
        DBManager.shared.deleteTaskWithID(id)
        completionHandler()
    }
    
}
