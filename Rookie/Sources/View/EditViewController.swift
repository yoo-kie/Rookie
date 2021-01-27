//
//  EditViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/02.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class EditViewController: UIViewController {
    private let editModel: EditModel = EditModel()
    
    @IBOutlet public var editTableView: UITableView!
    
    var editDate: String = "2020.08.20 월"
    var todayTasks = [Tasks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        editModel.delegate = self
        
        self.navigationItem.title = editDate
        
        editTableView.delegate = self
        editTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initEditTableViewUI()
    }
    
    @IBAction func clickAddButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "추가하기", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "완료", style: .default) { [self] _ in
            editModel.addTodayTask(text: alert.textFields?[0].text, date: editDate) {
                self.initEditTableViewUI()
            }
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addTextField { (textField) in
            textField.placeholder = "ex) 영화보기"
        }

        alert.addAction(cancel)
        alert.addAction(ok)

        alert.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func initEditTableViewUI() {
        editModel.fetchTodayTasks(of: editDate)
        self.editTableView.reloadData()
        
        for constraint in self.editTableView.constraints where constraint.identifier == "etvHeight" {
            constraint.constant = self.editTableView.contentSize.height + 5
        }
        self.editTableView.layoutIfNeeded()
    }
}

// MARK: - EditModel 연동 Delegation
extension EditViewController: EditModelDelegate {
    func editModel(todayTasks: [Tasks]) {
        self.todayTasks = todayTasks
    }
}

// MARK: - TableView Delegation & DataSource
extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todayTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
        cell.textLabel?.text = self.todayTasks[indexPath.row].title
        
        let font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
        cell.textLabel!.font = font
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            editModel.deleteTodayTask(with: self.todayTasks[indexPath.row].id) {
                self.initEditTableViewUI()
            }
        }
    }
}
