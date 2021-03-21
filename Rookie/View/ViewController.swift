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
    
    enum Todo: String, CaseIterable {
        case today = "오늘"
        case tomorrow = "내일"
    }
    
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var todayImageView: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    @IBOutlet var diaryLabel: UILabel!
    @IBOutlet var diaryButton: UIButton!
    @IBOutlet var todoSegmentedControl: UISegmentedControl! = UISegmentedControl(
        items: Todo.allCases.map { $0.rawValue }
    )
    @IBOutlet var todoProgressLabel: UILabel!
    @IBOutlet var todoCollectionView: UICollectionView!
    
    private var todoTasks: [Tasks] = [Tasks]()
    private var todoDoneTasks: [Tasks] = [Tasks]()
    private var rookie: String = ""
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
        
        fetchTodo()
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
        fetchTodo()
    }
    
    private func configureCollectionView() {
        todoCollectionView.delegate = self
        todoCollectionView.dataSource = self
        todoCollectionView.register(
            UINib(nibName: "TodayCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "todayCell"
        )
    }
    
    func setDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constant.Date.locale)
        formatter.dateFormat = Constant.Date.dataFormat
        
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        else { return }
        
        todayDate = formatter.string(from: Date())
        tomorrowDate = formatter.string(from: date)
    }
    
    func setMainUI() {
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        navigationItem.title = todayDate
        
        diaryButton.layer.cornerRadius = Constant.Button.cornerRadius
        
        addLongPressOnCollectionView()
    }
    
    func fetchTodo() {
        switch currentSegmentedControl {
        case .today:
            mainModel.fetchMain(of: todayDate)
        case .tomorrow:
            mainModel.fetchMain(of: tomorrowDate)
        }
    }
    
    func updateToday() {
        let totalCount = todoTasks.count
        let doneCount = todoDoneTasks.count
        
        if currentSegmentedControl == .today {
            let level: Rookie = fetchLevel(total: totalCount, done: doneCount)
            
            Rookie.name = "\(rookie)_"
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
                imageName: Rookie.name
            )
        }
        
        todoProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
    
    func fetchLevel(total: Int, done: Int) -> Rookie {
        let level = (4.0 / Float(total)) * Float(done)
        
        switch level {
        case 0..<1:
            return .L1
        case 1..<2:
            return .L2
        case 2..<3:
            return .L3
        case 3..<4:
            return .L4
        case 4:
            return .L5
        default:
            return .L1
        }
    }
    
    func setWidgetData(
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
        mainTasks tasks: [Tasks],
        mainDoneTasks doneTasks: [Tasks]
    ) {
        todoTasks = tasks
        todoDoneTasks = doneTasks
        updateToday()
        todoCollectionView.reloadData()
    }
    
    func mainModel(thisMonthDates: [String]) {
        diaryLabel.text = "\(thisMonthDates.count)일"
    }
    
    func mainModel(mainRookie: String) {
        rookie = mainRookie
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
        if collectionView == todoCollectionView {
            if todoTasks.count == 0 {
                todoCollectionView.isHidden = true
            } else {
                todoCollectionView.isHidden = false
            }
            return todoTasks.count
        } else {
            return 50
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == todoCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? TodayCollectionViewCell else {
                return TodayCollectionViewCell()
            }
            
            return setTodayCell(cell: cell, indexPath: indexPath)
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func setTodayCell(
        cell: TodayCollectionViewCell,
        indexPath: IndexPath
    ) -> TodayCollectionViewCell {
        let todayTasks = todoTasks
        let task = todayTasks[indexPath.row]
        let title = task.title
        let doneYN = task.done_yn
        
        cell.todayLabel.text = title
        
        if doneYN == "Y" {
            cell.todayLabel.textColor = .white
            cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            cell.todayLabel.textColor = .black
            cell.todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == todoCollectionView {
            let task = todoTasks[indexPath.row]
            let id = task.id
            let doneYN = task.done_yn
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell else {
                return
            }
            
            if doneYN == "N" {
                cell.todayLabel.textColor = .white
                cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let updateData: [String: Any] = ["id": id, "done_yn": "Y"]
                mainModel.updateTask(of: updateData, completionHandler: nil)
            } else if doneYN == "Y" {
                cell.todayLabel.textColor = .black
                cell.todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
                let updateData: [String: Any] = ["id": id, "done_yn": "N"]
                mainModel.updateTask(of: updateData, completionHandler: nil)
            }
            
            fetchTodo()
        }
    }
    
    func addLongPressOnCollectionView() {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(ViewController.handleLongPress)
        )
        todoCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }

        let location = gestureRecognizer.location(in: todoCollectionView)
        
        if let indexPath: IndexPath = todoCollectionView.indexPathForItem(at: location) {
            let task = todoTasks[indexPath.row]
        
            if task.done_yn == "N" {
                let actionSheet = UIAlertController(title: task.title, message: nil, preferredStyle: .actionSheet)
                
                var action = UIAlertAction()
                
                switch currentSegmentedControl {
                case .today:
                    action = UIAlertAction(title: "내일하기", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        let updateData: [String: Any] = ["id": task.id, "date": self.tomorrowDate]
                        self.mainModel.updateTask(of: updateData) {
                            self.fetchTodo()
                        }
                    }
                case .tomorrow:
                    action = UIAlertAction(title: "오늘하기", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        task.date = self.todayDate
                        let updateData: [String: Any] = ["id": task.id, "date": self.todayDate]
                        self.mainModel.updateTask(of: updateData) {
                            self.fetchTodo()
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                
                actionSheet.addAction(action)
                actionSheet.addAction(cancelAction)
                actionSheet.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
                
                present(actionSheet, animated: true, completion: nil)
            } else {
                actionSheetStyleAlert(message: "이미 완료된 일입니다-!")
            }
        }
    }
    
}
