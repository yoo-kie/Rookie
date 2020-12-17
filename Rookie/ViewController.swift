//
//  ViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/01.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {
    
    var today: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        return formatter.string(from: Date())
    }()
    
    var tomorrow: String = {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return ""
        }
          
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        return formatter.string(from: date)
    }()
    
    var mainList = [Tasks]()
    var mainDoneList = [Tasks]()
    
    @IBOutlet var diaryBtn: UIButton!
    
    @IBOutlet var oneWordLabel: UILabel!
    @IBOutlet var todayProgressImage: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    @IBOutlet var mainDateSC: UISegmentedControl!
    @IBOutlet var todayProgressLabel: UILabel!
    @IBOutlet var allDatesLabel: UILabel!
    
    @IBOutlet var todayCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        self.navigationItem.title = self.today
    
        diaryBtn.layer.cornerRadius = 10
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        
        self.initMainListDate(date: self.today)
        DBManager.shared.initAllMonthsAndDates()
        DBManager.shared.initSelectedDates(month) { (dates) in
            self.resetTodayCharacter(today: self.today, thisMonthDates: dates)
            self.allDatesLabel.text = "\(dates.count)일"
        }
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "TodayCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "todayCell")
        
        self.addLongPressOnCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateMain()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let todayLayout = self.todayCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            DispatchQueue.main.async {
                todayLayout.invalidateLayout()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        
        guard let evc = dest as? EditViewController else {
            return
        }
        
        evc.editDate = self.navigationItem.title ?? ""
    }

    @IBAction func selectMainListDate(_ sender: UISegmentedControl) {
        self.updateMain()
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
    
}

extension ViewController {
    
    func resetTodayCharacter(today: String, thisMonthDates: [String]) {
        var name = ""
        var count: Int = 1
        
        switch thisMonthDates.count {
        case 0:
            name = "뽀짝이"
            DBManager.shared.characterCollection = ["뽀짝이"]
            count = 3
        case 1..<10:
            name = "뽀짝이"
            DBManager.shared.characterCollection = ["뽀짝이"]
            count = 3
        case 10..<20:
            name = "뽀록희"
            DBManager.shared.characterCollection = ["뽀짝이", "뽀록희"]
            count = 2
        default:
            name = "키캡"
            DBManager.shared.characterCollection = ["뽀짝이", "뽀록희", "키캡"]
            count = 1
        }
        
        let num = arc4random_uniform(UInt32(count)) + 1
        let dict = ["date": today, "name": "\(name)\(num)"]
        if let characterDict = UserDefaults.standard.dictionary(forKey: "character") {
            guard let date = characterDict["date"] as? String else {
                return
            }
            
            if date != today {
                UserDefaults.standard.setValue(dict, forKey: "character")
            }
        } else {
            UserDefaults.standard.setValue(dict, forKey: "character")
        }
        
        if let characterDict = UserDefaults.standard.dictionary(forKey: "character") {
            guard let name = characterDict["name"] as? String else {
                return
            }
            
            DBManager.shared.todayCharacter = name
        }
    }
    
    func initMainListDate(date: String) {
        self.mainList = DBManager.shared.selectTasksWithDate(date)
        self.mainDoneList = DBManager.shared.selectDoneTasksWithDate(date)
    }
    
    func updateMain() {
        switch self.mainDateSC.selectedSegmentIndex {
        case 0:
            self.initMainListDate(date: self.today)
        case 1:
            self.initMainListDate(date: self.tomorrow)
        default:
            self.initMainListDate(date: self.today)
        }
        
        let totalCount = self.mainList.count
        let doneCount = self.mainDoneList.count
        
        if self.mainDateSC.selectedSegmentIndex == 0 {
            var imageName = "\(DBManager.shared.todayCharacter)_"
            
            let level = (4.0 &/ Float(totalCount)) * Float(doneCount)
            switch level {
            case 0..<1 :
                oneWordLabel.text = "오늘도 즐거운 하루가 될 거예요-!"
                imageName += "1"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 1..<2 :
                oneWordLabel.text = "잘했어요! 으쌰으쌰-!"
                imageName += "2"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 2..<3 :
                oneWordLabel.text = "훌륭한데요-?:)"
                imageName += "3"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 3..<4 :
                oneWordLabel.text = "맛있는 거 먹으면서 푹 쉬어요!"
                imageName += "4"
                todayProgressImage.image = UIImage.init(named: imageName)
            case 4 :
                oneWordLabel.text = "오늘 하루도 수고했어요:)"
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
        
        self.todayProgressLabel.text = "\(doneCount)/\(totalCount)"
        self.todayCollectionView.reloadData()
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

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.todayCollectionView {
            if self.mainList.count == 0 {
                self.todayCollectionView.isHidden = true
            } else {
                self.todayCollectionView.isHidden = false
            }
            return self.mainList.count
        } else {
            return 50
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let todayTasks = self.mainList
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
            let task = self.mainList[indexPath.row]
            let id = task.id
            let doneYN = task.done_yn
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell else {
                return
            }
            
            if doneYN == "N" {
                cell.todayLabel.textColor = .white
                cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                DBManager.shared.updateTaskDoneYN(id, "Y")
            } else if doneYN == "Y" {
                cell.todayLabel.textColor = .black
                cell.todayView.backgroundColor = #colorLiteral(red: 0.9971911311, green: 0.9418782592, blue: 0.6368385553, alpha: 1)
                DBManager.shared.updateTaskDoneYN(id, "N")
            }
            
            self.updateMain()
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
            let task = self.mainList[indexPath.row]
        
            if task.done_yn == "N" {
                let actionSheet = UIAlertController(title: task.title, message: nil, preferredStyle: .actionSheet)
                
                var tomorrowAction = UIAlertAction()
                if self.mainDateSC.selectedSegmentIndex == 0 {
                    tomorrowAction = UIAlertAction(title: "내일하기", style: .default) { _ in
                        DBManager.shared.updateTaskDate(task.id, self.tomorrow)
                        self.updateMain()
                    }
                } else if self.mainDateSC.selectedSegmentIndex == 1 {
                    tomorrowAction = UIAlertAction(title: "오늘하기", style: .default) { _ in
                        DBManager.shared.updateTaskDate(task.id, self.today)
                        self.updateMain()
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
