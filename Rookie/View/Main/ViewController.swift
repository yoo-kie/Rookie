//
//  ViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/01.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import WidgetKit

// SplashViewController -> Main으로
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
    @IBOutlet var editButton: UIButton!
    @IBOutlet var todoCollectionView: UICollectionView!
    
    private var todoTasks: [Tasks] = []
    private var todoDoneTasks: [Tasks] = []
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
    lazy var todoUICollectionDataSource = TodoUICollectionDataSource { indexPath in
        let task = self.todoTasks[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
        
        let toggle = doneYN == "Y" ? "N" : "Y"
        let updateData: [String: Any] = ["id": id, "done_yn": toggle]
        self.mainModel.updateTask(of: updateData) {
            self.fetchTasks()
            
            guard let cell = self.todoCollectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell
            else { return }
            
            cell.update(doneYN: doneYN)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setDate()
        setMainUI()
        mainModel.fetchDates(of: todayDate) { dates in
            self.diaryLabel.text = "\(dates.count)일"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTasks()
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let date = navigationItem.title else { return }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(identifier: "EditViewController") as? EditViewController
        else { return }
        
        editVC.editDate = date
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func tapMenuButton(_ sender: UIBarButtonItem) {
        guard let date = navigationItem.title else { return }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let menuVC = storyboard.instantiateViewController(identifier: "MenuViewController") as? MenuViewController
        else { return }
        
        menuVC.menuDate = date
        
        navigationController?.pushViewController(menuVC, animated: true)
    }
    
    @IBAction func tapDiaryButton(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let diaryVC = storyboard.instantiateViewController(identifier: "DiaryViewController") as? DiaryViewController
        else { return }
        
        navigationController?.pushViewController(diaryVC, animated: true)
    }
    
    @IBAction func touchTodoSegementedControl(_ sender: UISegmentedControl) {
        fetchTasks()
    }
    
    private func configureCollectionView() {
        todoCollectionView.delegate = self.todoUICollectionDataSource
        todoCollectionView.dataSource = self.todoUICollectionDataSource
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
        editButton.layer.cornerRadius = Constant.Layer.cornerRadius
        diaryButton.layer.cornerRadius = Constant.Layer.cornerRadius
        addLongPressOnCollectionView()
    }
    
    private func fetchTasks() {
        var date: String
        switch currentSegmentedControl {
        case .today:
            date = todayDate
        case .tomorrow:
            date = tomorrowDate
        }
        
        mainModel.fetchTasks(with: date) { (tasks, doneTasks) in
            self.todoTasks = tasks
            self.todoUICollectionDataSource.todoTasks = tasks
            self.todoDoneTasks = doneTasks
            self.updateRookie()
            self.todoCollectionView.reloadData()
        }
    }
    
    private func updateRookie() {
        guard currentSegmentedControl == .today else { return }
        
        let totalCount = todoTasks.count
        let doneCount = todoDoneTasks.count
        
        let level: Level = Level.fetchLevel(total: totalCount, done: doneCount)
        
        todayLabel.text = level.labelText
        todayImageView.image = UIImage(named: level.imageName)
        
        if doneCount == 0 || totalCount == 0 {
            self.todayProgressView.setProgress(
                .zero,
                animated: true
            )
        } else {
            UIView.animate(withDuration: 1.0) {
                self.todayProgressView.setProgress(
                    Float(doneCount) / Float(totalCount),
                    animated: true
                )
            }
        }
        
        todayProgressLabel.text = "\(doneCount)/\(totalCount)"
        
        setWidgetData(
            doneCount: doneCount,
            totalCount: totalCount,
            imageName: level.imageName
        )
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
            
            let action = UIAlertAction(title: currentDay.actionTitle, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                let updateData: [String: Any] = ["id": task.id, "date": date]
                self.mainModel.updateTask(of: updateData) {
                    self.fetchTasks()
                }
            }
            
            let cancelAction = UIAlertAction(
                title: Constant.Defer.cancel,
                style: .cancel, handler: nil
            )
            
            actionSheet.addAction(action)
            actionSheet.addAction(cancelAction)
            actionSheet.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
}
