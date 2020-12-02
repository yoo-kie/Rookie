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
    
    var today = ""
    var tomorrow = ""
    var mainMonth = ""
    var mainDates = [String]()
    var mainList = [Tasks]()
    var mainDoneList = [Tasks]()
    
    @IBOutlet var oneWordLabel: UILabel!
    @IBOutlet var todayProgressImage: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    @IBOutlet var mainDateSC: UISegmentedControl!
    @IBOutlet var todayProgressLabel: UILabel!
    @IBOutlet var mainDatesLabel: UILabel!
    
    @IBOutlet var todayCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    @IBOutlet var lastCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        self.today = formatter.string(from: Date())
        
        self.navigationItem.title = self.today
        self.initMainListDate(date: self.today)
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        
        DBManager.shared.initAllMonthsAndDates()
        DBManager.shared.initSelectedDates(month) { (dates) in
            self.mainMonth = month
            self.mainDates = dates
            self.mainDatesLabel.text = "\(self.mainDates.count)개"
            self.resetTodayCharacter(today: self.today, thisMonthDates: dates)
        }
        
        guard let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return
        }
        self.tomorrow = formatter.string(from: tomorrowDate)
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "TodayCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "todayCell")
        
        lastCollectionView.delegate = self
        lastCollectionView.dataSource = self
        lastCollectionView.register(UINib(nibName: "LastCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "lastCell")
        
        self.addLongPressOnCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateMain()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let todayLayout = self.todayCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout, let lastLayout = self.lastCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            DispatchQueue.main.async {
                todayLayout.invalidateLayout()
                lastLayout.invalidateLayout()
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
    
    @IBAction func clickMonthPickerView(_ sender: UIButton) {
        if DBManager.shared.allMonths.count != 0 {
            let alert = UIAlertController(title: "지난 리스트", message: "\n\n\n\n\n\n", preferredStyle: .alert)
                    
            let pickerView = UIPickerView(frame: CGRect(x: 5, y: 30, width: 250, height: 140))
            pickerView.delegate = self
            pickerView.dataSource = self
            alert.view.addSubview(pickerView)
            
            if let defaultRow = DBManager.shared.allMonths.firstIndex(of: self.mainMonth) {
                pickerView.selectRow(defaultRow, inComponent: 0, animated: true)
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
            
            let ok = UIAlertAction(title: "완료", style: .default) { _ in
                DBManager.shared.initSelectedDates(self.mainMonth) { (dates) in
                    self.mainDates = dates
                    self.mainDatesLabel.text = "\(self.mainDates.count)개"
                    self.lastCollectionView.reloadData()
                }
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            }
            
            alert.addAction(cancel)
            alert.addAction(ok)
            alert.view.tintColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.actionSheetStyleAlert(message: "지난 리스트가 없습니다")
        }
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
    
    func initMainListDate(date: String) {
        self.mainList = DBManager.shared.selectTasksWithDate(date)
        self.mainDoneList = DBManager.shared.selectDoneTasksWithDate(date)
    }
    
    func resetTodayCharacter(today: String, thisMonthDates: [String]) {
        var name = ""
        var count: Int = 1
        
        switch thisMonthDates.count {
        case 0:
            name = "뽀짝이"
            DBManager.shared.characterCollection = ["뽀짝이"]
            count = 3
        case 1...10:
            name = "뽀짝이"
            DBManager.shared.characterCollection = ["뽀짝이"]
            count = 3
        case 11...20:
            name = "뽀록희"
            DBManager.shared.characterCollection = ["뽀짝이", "뽀록희"]
            count = 1
        case 21...31:
            name = "뽀록희"
            DBManager.shared.characterCollection = ["뽀짝이", "뽀록희"]
            count = 1
        default:
            name = "뽀짝이"
            DBManager.shared.characterCollection = ["뽀짝이"]
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
        if collectionView == self.lastCollectionView {
            return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height/1.5)
        } else {
            return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height/1.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.todayCollectionView {
            if self.mainList.count == 0 {
                self.todayCollectionView.isHidden = true
            } else {
                self.todayCollectionView.isHidden = false
            }
            return self.mainList.count
        } else if collectionView == self.lastCollectionView {
            if self.mainDates.count == 0 {
                self.lastCollectionView.isHidden = true
            } else {
                self.lastCollectionView.isHidden = false
            }
            return self.mainDates.count
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
        } else if collectionView == self.lastCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lastCell", for: indexPath) as? LastCollectionViewCell else {
                return LastCollectionViewCell()
            }
            
            return self.setLastCell(cell: cell, indexPath: indexPath)
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
    
    func setLastCell(cell: LastCollectionViewCell, indexPath: IndexPath) -> LastCollectionViewCell {
        let num = indexPath.row % 3
        switch num {
        case 0:
            cell.lastView.backgroundColor = #colorLiteral(red: 0.7111719847, green: 0.6382898092, blue: 0.442435503, alpha: 1)
        case 1:
            cell.lastView.backgroundColor = #colorLiteral(red: 0.5921568627, green: 0.5647058824, blue: 0.4705882353, alpha: 1)
        case 2:
            cell.lastView.backgroundColor = #colorLiteral(red: 0.7227522731, green: 0.6883900762, blue: 0.5979392529, alpha: 1)
        default:
            cell.lastView.backgroundColor = #colorLiteral(red: 0.7098039216, green: 0.8, blue: 0.9960784314, alpha: 1)
        }
        
        cell.lastLabel.text = self.mainDates[indexPath.row]
        
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
        } else if collectionView == self.lastCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? LastCollectionViewCell else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else {
                return
            }
            detailVC.detailDate = cell.lastLabel.text!
            self.present(detailVC, animated: true, completion: nil)
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

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DBManager.shared.allMonths.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DBManager.shared.allMonths[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if DBManager.shared.allMonths.count != 0 {
            self.mainMonth = DBManager.shared.allMonths[row]
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
