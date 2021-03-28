//
//  EditUITableViewDataSource.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/29.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

class EditUITableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    typealias HandlerType = (Int) -> Void
    let handler: HandlerType
    var todayTasks: [Tasks] = []
    
    init(handler: @escaping HandlerType) {
        self.handler = handler
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return todayTasks.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as? EditTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
        }
        
        cell.bind(title: todayTasks[indexPath.row].title)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            handler(todayTasks[indexPath.row].id)
        }
    }
    
}
