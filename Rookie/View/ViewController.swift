//
//  ViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/01.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import WidgetKit

final class ViewController: BaseViewController {
    
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var todayImageView: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    @IBOutlet var diaryLabel: UILabel!
    @IBOutlet var diaryButton: UIButton!
    @IBOutlet var todoSegmentedControl: UISegmentedControl! = UISegmentedControl(
        items: Todo.allCases.map { $0.rawValue }
    )
    @IBOutlet var todayProgressLabel: UILabel!
    @IBOutlet var todoCollectionView: UICollectionView!
    
    private var todoTasks: [Tasks] = [Tasks]()
    private var todoDoneTasks: [Tasks] = [Tasks]()
    private var todayDate: String = ""
    private var tomorrowDate: String = ""
    private var currentSegmentedControl: Todo {
        let index = todoSegmentedControl.selectedSegmentIndex
        
        guard let title = todoSegmentedControl.titleForSegment(at: index),
              let todoDay: Todo = Todo(rawValue: title)
        else { return .today }
        
        return todoDay
    }
    
    private let mainModel: MainModel = MainModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainModel.delegate = self
        configureCollectionView()
        setDate()
        setMainUI()
        
        mainModel.fetchDates(of: todayDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTasks()
    }
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        guard let date = navigationItem.title else { return }
        
        let destinationVC = segue.destination
        
        if let editVC = destinationVC as? EditViewController {
            editVC.editDate = date
        } else if let menuVC = destinationVC as? MenuViewController {
            menuVC.menuDate = date
        }
    }
    
    @IBAction func touchTodoSegementedControl(_ sender: UISegmentedControl) {
        fetchTasks()
    }
    
    private func configureCollectionView() {
        todoCollectionView.delegate = self
        todoCollectionView.dataSource = self
        todoCollectionView.register(
            UINib(nibName: "TodayCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "todayCell"
        )
    }
    
    private func setDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constant.Date.locale)
        formatter.dateFormat = Constant.Date.dataFormat
        
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        else { return }
        
        todayDate = formatter.string(from: Date())
        tomorrowDate = formatter.string(from: date)
    }
    
    private func setMainUI() {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        navigationItem.title = todayDate
        
        diaryButton.layer.cornerRadius = Constant.Layer.cornerRadius
        
        addLongPressOnCollectionView()
    }
    
    private func fetchTasks() {
        switch currentSegmentedControl {
        case .today:
            mainModel.fetchTasks(with: todayDate)
        case .tomorrow:
            mainModel.fetchTasks(with: tomorrowDate)
        }
    }
    
    private func updateRookie() {
        let totalCount = todoTasks.count
        let doneCount = todoDoneTasks.count
        
        if currentSegmentedControl == .today {
            let level: Level = Level.fetchLevel(total: totalCount, done: doneCount)
            
            todayLabel.text = level.labelText
            todayImageView.image = level.image
            
            UIView.animate(withDuration: 1.0) {
                self.todayProgressView.setProgress(
                    Float(doneCount) / Float(totalCount),
                    animated: true
                )
            }
            
            setWidgetData(
                doneCount: doneCount,
                totalCount: totalCount,
                imageName: "\(Rookie.todayRookie)_"
            )
        }
        
        todayProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
    
    private func setWidgetData(
        doneCount: Int,
        totalCount: Int,
        imageName: String
    ) {
        if #available(iOS 14.0, *) {
            if let groupUserDafaults = UserDefaults(suiteName: "group.com.yookie.rookie") {
                groupUserDafaults.setValue(doneCount, forKey: "doneCount")
                groupUserDafaults.setValue(totalCount, forKey: "totalCount")
                groupUserDafaults.setValue(imageName, forKey: "todayProgressImage")
                
                WidgetCenter.shared.reloadTimelines(ofKind: "RookieWidget")
            }
        }
    }
    
}

extension ViewController: MainModelDelegate {
    
    func mainModel(
        todoTasks tasks: [Tasks],
        todoDoneTasks doneTasks: [Tasks]
    ) {
        todoTasks = tasks
        todoDoneTasks = doneTasks
        
        updateRookie()
        todoCollectionView.reloadData()
    }
    
    func mainModel(dates: [String]) {
        diaryLabel.text = "\(dates.count)일"
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width / 1.5,
            height: collectionView.frame.height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if todoTasks.count == 0 {
            todoCollectionView.isHidden = true
        } else {
            todoCollectionView.isHidden = false
        }
        return todoTasks.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? TodayCollectionViewCell
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath)
        }
        cell.bind(tasks: todoTasks, indexPath: indexPath)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let task = todoTasks[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
            
        guard let cell = collectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell
        else { return }
            
        cell.update(doneYN: doneYN)
        
        let toggle = doneYN == "Y" ? "N" : "Y"
        let updateData: [String: Any] = ["id": id, "done_yn": toggle]
        mainModel.updateTask(of: updateData, completionHandler: nil)
        
        fetchTasks()
    }
    
}

extension ViewController {
    
    private func addLongPressOnCollectionView() {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(ViewController.handleLongPress)
        )
        todoCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .ended { return }
        let location = gestureRecognizer.location(in: todoCollectionView)
        
        if let indexPath: IndexPath = todoCollectionView.indexPathForItem(at: location) {
            action(indexPath: indexPath)
        } else {
            actionSheetStyleAlert(message: Constant.Defer.doneMessage)
        }
    }

    private func action(indexPath: IndexPath) {
        let task = todoTasks[indexPath.row]
    
        if task.done_yn == "N" {
            let currentDay: Todo = currentSegmentedControl
            let date = currentDay == .today ? tomorrowDate : todayDate
            
            let actionSheet = UIAlertController(
                title: task.title,
                message: nil,
                preferredStyle: .actionSheet
            )
            
            var action = UIAlertAction()
            
            action = UIAlertAction(title: currentDay.actionTitle, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                let updateData: [String: Any] = ["id": task.id, "date": date]
                self.mainModel.updateTask(of: updateData) {
                    self.fetchTasks()
                }
            }
            
            let cancelAction = UIAlertAction(title: Constant.Defer.cancel, style: .cancel, handler: nil)
            
            actionSheet.addAction(action)
            actionSheet.addAction(cancelAction)
            actionSheet.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
}
