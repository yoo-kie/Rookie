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
    lazy var editUITableViewDataSource = EditUITableViewDataSource { id in
        self.editModel.deleteTask(with: id) { [weak self] in
            guard let self = self else { return }
            self.reloadTableViewUI()
        }
    }
    
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
        editTableView.delegate = editUITableViewDataSource
        editTableView.dataSource = editUITableViewDataSource
        editTableView.register(
            UINib(nibName: "EditTableViewCell", bundle: nil),
            forCellReuseIdentifier: "editCell"
        )
    }
    
    func reloadTableViewUI() {
        editModel.fetchTasks(with: editDate) { [weak self] tasks in
            guard let self = self else { return }
            self.todayTasks = tasks
            self.editUITableViewDataSource.todayTasks = tasks
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
