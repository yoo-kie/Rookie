//
//  EditViewController.swift
//  RPG
//
//  Created by 유연주 on 2020/08/02.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet public var editTableView: UITableView!
    var editDate: String = "2020.08.20"
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.navigationItem.title = editDate
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9458019137, green: 0.8140015006, blue: 0.2600919008, alpha: 1)
        
        editTableView.delegate = self
        editTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initEditTableViewUI()
    }
    
    @IBAction func clickAddButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "추가하기", preferredStyle: .alert)
        let ok = UIAlertAction(title: "완료", style: .default) { (ok) in
            if !(alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                let task = Tasks()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                let today = formatter.string(from: Date())
                
                task.id = DBManager.shared.incrementTaskID()
                task.character = DBManager.shared.todayCharacter
                task.date = today
                task.title = alert.textFields?[0].text ?? " "
                task.done_yn = "N"
                DBManager.shared.addTask(task)
                self.initEditTableViewUI()
            }
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
        }

        alert.addTextField { (textField) in
            textField.placeholder = "ex) 영화보기"
        }

        alert.addAction(cancel)
        alert.addAction(ok)

        alert.view.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DBManager.shared.selectTasksWithDate(editDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
        cell.textLabel?.text = DBManager.shared.selectTasksWithDate(editDate)[indexPath.row].title
        
        let font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.medium)
        cell.textLabel!.font = font
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DBManager.shared.deleteTaskWithID(DBManager.shared.selectTasksWithDate(editDate)[indexPath.row].id)
            self.initEditTableViewUI()
        }
    }
    
    func initEditTableViewUI() {
        self.editTableView.reloadData()
        
        for constraint in self.editTableView.constraints {
            if constraint.identifier == "etvHeight" {
               constraint.constant = self.editTableView.contentSize.height + 5
            }
        }
        
        self.editTableView.layoutIfNeeded()
    }
    
}