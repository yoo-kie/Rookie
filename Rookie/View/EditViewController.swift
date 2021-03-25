//
//  EditViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/02.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class EditViewController: BaseViewController {
    
    @IBOutlet public var editTableView: UITableView!
    
    var editDate: String = ""
    var todayTasks: [Tasks] = []
    
    private let editModel: EditModel = EditModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = editDate
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTableViewUI()
    }
    
    @IBAction func clickAddButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: Constant.Add.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constant.Add.ok, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.editModel.addTask(text: alert.textFields?[0].text, date: self.editDate) {
                self.reloadTableViewUI()
            }
        }
        let cancel = UIAlertAction(title: Constant.Add.cancel, style: .cancel)

        alert.addTextField { textField in
            textField.placeholder = Constant.Add.placeHolder
        }

        alert.addAction(cancel)
        alert.addAction(ok)

        alert.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configureTableView() {
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.register(
            UINib(nibName: "EditTableViewCell", bundle: nil),
            forCellReuseIdentifier: "editCell"
        )
    }
    
    func reloadTableViewUI() {
        editModel.fetchTasks(with: editDate) { [weak self] tasks in
            guard let self = self else { return }
            self.todayTasks = tasks
            self.editTableView.reloadData()
            self.configureTableViewHeight()
        }
    }
    
    func configureTableViewHeight() {
        for constraint in editTableView.constraints where constraint.identifier == "etvHeight" {
            constraint.constant = editTableView.contentSize.height + 5
        }
        
        editTableView.layoutIfNeeded()
    }
    
}

// MARK: - TableView Delegation & DataSource

extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            editModel.deleteTask(with: self.todayTasks[indexPath.row].id) { [weak self] in
                guard let self = self else { return }
                self.reloadTableViewUI()
            }
        }
    }
    
}
