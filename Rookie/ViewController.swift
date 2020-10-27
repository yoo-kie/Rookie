//
//  ViewController.swift
//  RPG
//
//  Created by 유연주 on 2020/08/01.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {
    
    var today = "" // 오늘 날짜
    var mainMonth = "" // 현재 선택된 년월 ex) 2020.09
    var mainDates = [String]() // 현재 선택된 년월의 일자들 ex) 2020.09.26
    var characterCollection = [String]()
    
    @IBOutlet var oneWordLabel: UILabel!
    @IBOutlet var todayProgressImage: UIImageView!
    @IBOutlet var todayProgressView: UIProgressView!
    @IBOutlet var todayProgressLabel: UILabel!
    @IBOutlet var mainDatesLabel: UILabel!
    
    @IBOutlet var characterCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "characterCell")
        
        return cv
    }()
    
    @IBOutlet var todayCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: "todayCell")
        
        return cv
    }()
    
    @IBOutlet var lastCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(LastCollectionViewCell.self, forCellWithReuseIdentifier: "lastCell")
        
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        self.today = formatter.string(from: Date())
        
        self.navigationItem.title = self.today
        
        let endIndex = today.index(today.startIndex, offsetBy: 7)
        let month = String(today[today.startIndex..<endIndex])
        
        DBManager.shared.initAllMonthsAndDates()
        DBManager.shared.initSelectedDates(month) { (dates) in
            self.mainMonth = month
            self.mainDates = dates
            self.mainDatesLabel.text = "\(self.mainDates.count)개"
            self.resetTodayCharacter(today: self.today, thisMonthDates: dates)
        }
        
        characterCollectionView.delegate = self
        characterCollectionView.dataSource = self
        characterCollectionView.register(UINib(nibName: "CharacterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "characterCell")
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        todayCollectionView.register(UINib(nibName: "TodayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "todayCell")
        
        lastCollectionView.delegate = self
        lastCollectionView.dataSource = self
        lastCollectionView.register(UINib(nibName: "LastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "lastCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.todayCollectionView.reloadData()
        self.updateProgressView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        
        guard let evc = dest as? EditViewController else {
            return
        }
        
        evc.editDate = self.navigationItem.title ?? ""
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
            
            let ok = UIAlertAction(title: "완료", style: .default) { (ok) in
                DBManager.shared.initSelectedDates(self.mainMonth) { (dates) in
                    self.mainDates = dates
                    self.mainDatesLabel.text = "\(self.mainDates.count)개"
                    self.lastCollectionView.reloadData()
                }
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
            }
            
            alert.addAction(cancel)
            alert.addAction(ok)

            alert.view.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "지난 리스트가 없습니다", preferredStyle: .actionSheet)
            if UIDevice.current.userInterfaceIdiom == .pad { // 디바이스 타입이 iPad일때
                if let popoverController = alert.popoverPresentationController { // ActionSheet가 표현되는 위치를 저장해줍니다.
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.present(alert, animated: true, completion: nil)
            }
            
            let when = DispatchTime.now() + 1.0
            DispatchQueue.main.asyncAfter(deadline: when){
              alert.dismiss(animated: true, completion: nil)
            }
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
                self.characterCollection = ["뽀짝이"]
                count = 3
                break
            case 1...10:
                name = "뽀짝이"
                self.characterCollection = ["뽀짝이"]
                count = 3
                break
            case 11...20:
                name = "뽀록희"
                self.characterCollection = ["뽀짝이", "뽀록희"]
                count = 1
                break
            case 21...31:
                name = "뽀록희"
                self.characterCollection = ["뽀짝이", "뽀록희"]
                count = 1
                break
            default:
                name = "뽀짝이"
                characterCollection = ["뽀짝이"]
                count = 1
        }
        
        let num = arc4random_uniform(UInt32(count)) + 1
        let dict = ["date" : today, "name" : "\(name)\(num)"]
        if let characterDict = UserDefaults.standard.dictionary(forKey: "character") {
            // 오늘 일자와 다르면
            if characterDict["date"] as! String != today {
                UserDefaults.standard.setValue(dict, forKey: "character")
            }
        } else {
            UserDefaults.standard.setValue(dict, forKey: "character")
        }
        
        if let characterDict = UserDefaults.standard.dictionary(forKey: "character") {
            DBManager.shared.todayCharacter = characterDict["name"] as! String
        }
    }
    
    func updateProgressView() {
        var imageName = "\(DBManager.shared.todayCharacter)_"
        let totalCount = DBManager.shared.selectTasksWithDate(self.today).count
        let doneCount = DBManager.shared.selectDoneTasksWithDate(self.today).count
        
        let level = (4.0 &/ Float(totalCount)) * Float(doneCount)
        
        switch level {
        case 0..<1 :
            oneWordLabel.text = "오늘도 즐거운 하루가 될 거예요-!"
            imageName = imageName + "1"
            todayProgressImage.image = UIImage.init(named: imageName)
            break
        case 1..<2 :
            oneWordLabel.text = "잘했어요! 으쌰으쌰-!"
            imageName = imageName + "2"
            todayProgressImage.image = UIImage.init(named: imageName)
            break
        case 2..<3 :
            oneWordLabel.text = "훌륭한데요-?:)"
            imageName = imageName + "3"
            todayProgressImage.image = UIImage.init(named: imageName)
            break
        case 3..<4 :
            oneWordLabel.text = "맛있는 거 먹으면서 푹 쉬어요!"
            imageName = imageName + "4"
            todayProgressImage.image = UIImage.init(named: imageName)
            break
        case 4 :
            oneWordLabel.text = "오늘 하루도 수고했어요:)"
            imageName = imageName + "5"
            todayProgressImage.image = UIImage.init(named: imageName)
            break
        default:
            print("no more level up")
        }
        
        UIView.animate(withDuration: 1.0) {
            self.todayProgressView.setProgress(Float(doneCount) &/ Float(totalCount), animated: true)
        }
        
        self.todayProgressLabel.text = "\(doneCount)/\(totalCount)"
        
        // 위젯킷 사용은 iOS14 이상부터만
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
        if collectionView == self.characterCollectionView {
            return CGSize(width: 50, height: 50)
        } else {
            return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height/1.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.characterCollectionView {
            return self.characterCollection.count
        } else if collectionView == self.todayCollectionView {
            if DBManager.shared.selectTasksWithDate(self.today).count == 0 {
                self.todayCollectionView.isHidden = true
            } else {
                self.todayCollectionView.isHidden = false
            }
            return DBManager.shared.selectTasksWithDate(self.today).count
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
        if collectionView == self.characterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as! CharacterCollectionViewCell
            cell.characterImageView.image = UIImage.init(named: self.characterCollection[indexPath.row])
            
            return cell
        } else if collectionView == self.todayCollectionView {
            let todayTasks = DBManager.shared.selectTasksWithDate(self.today)
            
            let task = todayTasks[indexPath.row]
            let title = task.title
            let doneYN = task.done_yn
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as! TodayCollectionViewCell
            
            cell.todayLabel.text = title
            
            if doneYN == "Y" {
                cell.todayLabel.textColor = .white
                cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            } else {
                cell.todayLabel.textColor = .black
                cell.todayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            }
            
            return cell
        } else if collectionView == self.lastCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lastCell", for: indexPath) as! LastCollectionViewCell
            
            let num = indexPath.row % 3
            switch num {
                case 0:
                    cell.lastView.backgroundColor = #colorLiteral(red: 0.583560884, green: 0.6693264246, blue: 0.5371844769, alpha: 1)
                    break
                case 1:
                    cell.lastView.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.6352941176, blue: 0.7098039216, alpha: 1)
                    break
                case 2:
                    cell.lastView.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.4588235294, blue: 0.5176470588, alpha: 1)
                    break
                default:
                    cell.lastView.backgroundColor = #colorLiteral(red: 0.583560884, green: 0.6693264246, blue: 0.5371844769, alpha: 1)
            }
            
            cell.lastLabel.text = self.mainDates[indexPath.row]
            
            return cell
        } else {
            let cell = UICollectionViewCell()
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.todayCollectionView {
            let task = DBManager.shared.selectTasksWithDate(self.today)[indexPath.row]
            let id = task.id
            let doneYN = task.done_yn
            
            let cell = collectionView.cellForItem(at: indexPath) as! TodayCollectionViewCell
            
            if doneYN == "N" {
                cell.todayLabel.textColor = .white
                cell.todayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                DBManager.shared.updateTask(id, "Y")
            } else {
                cell.todayLabel.textColor = .black
                cell.todayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                DBManager.shared.updateTask(id, "N")
            }
            
            self.updateProgressView()
            self.todayCollectionView.reloadData()
            
            // 루키루키
            if doneYN == "Y" {
                self.todayCollectionView.setContentOffset(.zero, animated: true)
            }
        } else if collectionView == self.lastCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! LastCollectionViewCell
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
            detailVC.detailDate = cell.lastLabel.text!
            self.present(detailVC, animated: true, completion: nil)
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
    
    public static func &/(lhs: Float, rhs: Float) -> Float {
        if rhs == 0 {
            return 0
        }
        
        return lhs / rhs
    }
    
}

