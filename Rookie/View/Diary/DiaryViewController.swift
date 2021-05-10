//
//  DiaryViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/12/08.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit
import FSCalendar

final class DiaryViewController: UIViewController {
    
    private let diaryModel: DiaryModel = DiaryModel()
    
    private var eventDates: [String] = [String]()
    private var detailView: UIView = UIView()
    private var calendar: FSCalendar = FSCalendar()
    private var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diaryModel.fetchEventDates() { [weak self] dates in
            guard let self = self else { return }
            self.eventDates = dates
        }
        
        self.setCalendar()
        self.setDetailView()
    }
    
    @IBAction func touchCalendarSwitch(_ sender: UISwitch) {
        if sender.isOn {
            calendar.setScope(.month, animated: true)
        } else {
            calendar.setScope(.week, animated: true)
        }
    }
    
    func setCalendar() {
        self.view.addSubview(calendar)
        calendar = {
            calendar.backgroundColor = #colorLiteral(red: 0.9646689296, green: 0.9683507085, blue: 0.8333314061, alpha: 1)
            
            calendar.layer.cornerRadius = 20
            calendar.translatesAutoresizingMaskIntoConstraints = false
            calendar.dataSource = self
            calendar.delegate = self
            
            calendar.appearance.headerDateFormat = "YYYY년 M월"
            calendar.locale = Locale(identifier: "ko_KR")
            calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
            calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            
            calendar.scope = .week
            calendar.appearance.titleDefaultColor = UIColor.label
            calendar.appearance.headerTitleColor = #colorLiteral(red: 0.6084107161, green: 0.5521717668, blue: 0.3833938539, alpha: 1)
            calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.6084107161, green: 0.5521717668, blue: 0.3833938539, alpha: 1)
            calendar.appearance.todayColor = #colorLiteral(red: 0.9856333137, green: 0.4833418727, blue: 0.3519303203, alpha: 0.85)
            calendar.appearance.selectionColor = #colorLiteral(red: 0.8960625529, green: 0.7841166258, blue: 0.5069380999, alpha: 1)
            calendar.appearance.eventDefaultColor = #colorLiteral(red: 0.9856333137, green: 0.4833418727, blue: 0.3519303203, alpha: 0.85)
            calendar.appearance.eventSelectionColor = #colorLiteral(red: 0.9856333137, green: 0.4833418727, blue: 0.3519303203, alpha: 0.85)
            
            calendar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
            calendar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            calendar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            calendarHeightConstraint = calendar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.4)
            calendarHeightConstraint.isActive = true
            return calendar
        }()
    }
    
    func setDetailView() {
        self.view.addSubview(detailView)
        detailView = {
            detailView.translatesAutoresizingMaskIntoConstraints = false
            detailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            detailView.bottomAnchor.constraint(equalTo: calendar.topAnchor, constant: 0).isActive = true
            detailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            detailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            return detailView
        }()
        
        var defaultLabel = UILabel()
        defaultLabel.textColor = .systemGray2
        defaultLabel.text = "날짜를 선택해주세요-!"
        detailView.addSubview(defaultLabel)
        defaultLabel = {
            defaultLabel.translatesAutoresizingMaskIntoConstraints = false
            defaultLabel.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
            defaultLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor).isActive = true
            return defaultLabel
        }()
        
//        var gradientLineImage = UIImageView()
//        self.view.addSubview(gradientLineImage)
//        gradientLineImage = {
//            gradientLineImage.translatesAutoresizingMaskIntoConstraints = false
//            gradientLineImage.bottomAnchor.constraint(equalTo: detailView.bottomAnchor).isActive = true
//            gradientLineImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//            gradientLineImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//            gradientLineImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
//            gradientLineImage.image = #imageLiteral(resourceName: "gradient")
//            return gradientLineImage
//        }()
    }
    
}

extension DiaryViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        let selectDate = formatter.string(from: date)
        
        if self.eventDates.contains(selectDate) {
            return true
        } else {
            return false
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        let detailDate = formatter.string(from: date)
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else {
            return
        }
        
        self.remove()
        addChild(detailVC)
        detailVC.detailDate = detailDate
        detailVC.view.frame = detailView.bounds
        detailView.addSubview(detailVC.view)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        let cellDate = formatter.string(from: date)
        if self.eventDates.contains(cellDate) {
            return 1
        } else {
            return 0
        }
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func remove() {
        children.forEach {
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }
    
}
