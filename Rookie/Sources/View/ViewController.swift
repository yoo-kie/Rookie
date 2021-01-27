//
//  ViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/01.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import WidgetKit

final class ViewController: UIViewController {
    private let mainModel: MainModel = MainModel()
    
    @IBOutlet var todayProgressLabel: UILabel!
    @IBOutlet var todayProgressImage: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    
    @IBOutlet var allDatesLabel: UILabel!
    @IBOutlet var diaryBtn: UIButton!
    
    @IBOutlet var mainSegmentedControl: UISegmentedControl!
    @IBOutlet var mainListProgressLabel: UILabel!
    
    @IBOutlet var todayCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var mainTasks = [Tasks]()
    private var mainDoneTasks = [Tasks]()
    private var mainRookie = "뽀짝이1"
    
    private var today: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        return formatter.string(from: Date())
    }()
    
    private var tomorrow: String = {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return ""
        }
          
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        return formatter.string(from: date)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainModel.delegate = self
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "TodayCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "todayCell")
        
        self.setBasicUIUX()
        
        mainModel.fetchDates(of: today)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadMainTasks()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let date = self.navigationItem.title ?? ""
        let dest = segue.destination
        
        if let evc = dest as? EditViewController {
            evc.editDate = date
        } else if let mvc = dest as? MenuViewController {
            mvc.menuDate = date
        }
    }
    
    func setBasicUIUX() {
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        self.navigationItem.title = today
        
        diaryBtn.layer.cornerRadius = 10
        
        self.addLongPressOnCollectionView()
    }

    @IBAction func selectMainListDate(_ sender: UISegmentedControl) {
        self.reloadMainTasks()
    }
    
    func reloadMainTasks() {
        switch self.mainSegmentedControl.selectedSegmentIndex {
        case 0:
            mainModel.fetchMain(of: today)
        case 1:
            mainModel.fetchMain(of: tomorrow)
        default:
            mainModel.fetchMain(of: today)
        }
    }
    
    func updateTodayProgress() {
        let totalCount = self.mainTasks.count
        let doneCount = self.mainDoneTasks.count
        
        if self.mainSegmentedControl.selectedSegmentIndex == 0 {
            var imageName = "\(mainRookie)_"
            
            let level = (4.0 &/ Float(totalCount)) * Float(doneCount)
            switch level {
            case 0..<1 :
                todayProgressLabel.text = "오늘도 즐거운 하루가 될 거예요-!"
                imageName += "1"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 1..<2 :
                todayProgressLabel.text = "잘했어요! 으쌰으쌰-!"
                imageName += "2"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 2..<3 :
                todayProgressLabel.text = "훌륭한데요-?:)"
                imageName += "3"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 3..<4 :
                todayProgressLabel.text = "맛있는 거 먹으면서 푹 쉬어요!"
                imageName += "4"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 4 :
                todayProgressLabel.text = "오늘 하루도 수고했어요:)"
                imageName += "5"
                todayProgressImage.image = UIImage.init(named: imageName)
            default:
                print("no more level up")
            }
            
            UIView.animate(withDuration: 1.0) {
                self.todayProgressView.setProgress(Float(doneCount) &/ Float(totalCount), animated: true)
            }
            
            self.setWidgetData(doneCount: doneCount, totalCount: totalCount, imageName: imageName)
        }
        
        self.mainListProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
    
    func actionSheetStyleAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                      y: self.view.bounds.midY,
                                                      width: 0,
                                                      height: 0)
                
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.present(alert, animated: true, completion: nil)
        }
        
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when) {
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func setWidgetData(doneCount: Int, totalCount: Int, imageName: String) {
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
    func mainModel(mainTasks: [Tasks], mainDoneTasks: [Tasks]) {
        self.mainTasks = mainTasks
        self.mainDoneTasks = mainDoneTasks
        self.updateTodayProgress()
        self.todayCollectionView.reloadData()
    }
    
    func mainModel(thisMonthDates: [String]) {
        self.allDatesLabel.text = "\(thisMonthDates.count)일"
    }
    
    func mainModel(mainRookie: String) {
        self.mainRookie = mainRookie
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.todayCollectionView {
            if self.mainTasks.count == 0 {
                self.todayCollectionView.isHidden = true
            } else {
                self.todayCollectionView.isHidden = false
            }
            return self.mainTasks.count
        } else {
            return 50
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.todayCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? TodayCollectionViewCell else {
                return TodayCollectionViewCell()
            }
            
            return self.setTodayCell(cell: cell, indexPath: indexPath)
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func setTodayCell(cell: TodayCollectionViewCell, indexPath: IndexPath) -> TodayCollectionViewCell {
        let todayTasks = mainTasks
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.todayCollectionView {
            let task = mainTasks[indexPath.row]
            let id = task.id
            let doneYN = task.done_yn
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell else {
                return
            }
            
            if doneYN == "N" {
                cell.todayLabel.textColor = .white
                cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let updateData: [String: Any] = ["id": id, "done_yn": "Y"]
                self.mainModel.updateTask(of: updateData, completionHandler: nil)
            } else if doneYN == "Y" {
                cell.todayLabel.textColor = .black
                cell.todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
                let updateData: [String: Any] = ["id": id, "done_yn": "N"]
                self.mainModel.updateTask(of: updateData, completionHandler: nil)
            }
            
            self.reloadMainTasks()
        }
    }
    
    func addLongPressOnCollectionView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress))
        self.todayCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }

        let location = gestureRecognizer.location(in: self.todayCollectionView)
        
        if let indexPath: IndexPath = self.todayCollectionView.indexPathForItem(at: location) {
            let task = mainTasks[indexPath.row]
        
            if task.done_yn == "N" {
                let actionSheet = UIAlertController(title: task.title, message: nil, preferredStyle: .actionSheet)
                
                var tomorrowAction = UIAlertAction()
                if self.mainSegmentedControl.selectedSegmentIndex == 0 {
                    tomorrowAction = UIAlertAction(title: "내일하기", style: .default) { _ in
                        let updateData: [String: Any] = ["id": task.id, "date": self.tomorrow]
                        self.mainModel.updateTask(of: updateData) {
                            self.reloadMainTasks()
                        }
                    }
                } else if self.mainSegmentedControl.selectedSegmentIndex == 1 {
                    tomorrowAction = UIAlertAction(title: "오늘하기", style: .default) { _ in
                        task.date = self.today
                        let updateData: [String: Any] = ["id": task.id, "date": self.today]
                        self.mainModel.updateTask(of: updateData) {
                            self.reloadMainTasks()
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                
                actionSheet.addAction(tomorrowAction)
                actionSheet.addAction(cancelAction)
                actionSheet.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
                
                self.present(actionSheet, animated: true, completion: nil)
            } else {
                self.actionSheetStyleAlert(message: "이미 완료된 일입니다-!")
            }
        }
    }
}

infix operator &/
extension Float {
    public static func &/ (lhs: Float, rhs: Float) -> Float {
        if rhs == 0 {
            return 0
        }
        
        return lhs / rhs
    }
}
