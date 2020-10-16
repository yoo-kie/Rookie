//
//  DBManager.swift
//  RPG
//
//  Created by 유연주 on 2020/08/21.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
    
    static let shared = DBManager()
     
    var allMonths = [String]() // 월 단위
    var allDates = [String]() // 일 단위
    
    var todayCharacter: String = "" // 오늘의 캐릭터
    
    let realm = try! Realm()
    
    func incrementTaskID() -> Int {
        return (realm.objects(Tasks.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func selectAllTasks() -> [Tasks] {
        let result = realm.objects(Tasks.self).toArray(type: Tasks.self)
        return result
    }
    
    func selectTasksWithID(_ id: Int) -> Tasks {
        let result = realm.objects(Tasks.self).filter("id = \(id)").toArray(type: Tasks.self)
        return result.first!
    }
    
    func selectTasksWithDate(_ date: String) -> [Tasks] {
        let result = realm.objects(Tasks.self).filter("date = '\(date)'").toArray(type: Tasks.self)
        return result
    }
    
    func selectDoneTasks() -> [Tasks] {
        let result = realm.objects(Tasks.self).filter("done_yn = 'Y'").toArray(type: Tasks.self)
        return result
    }
    
    func selectDoneTasksWithDate(_ date: String) -> [Tasks] {
        let result = realm.objects(Tasks.self).filter("date = '\(date)' and done_yn = 'Y'").toArray(type: Tasks.self)
        return result
    }
    
    func selectCharacterWithDate(_ date: String) -> String {
        let result = realm.objects(Tasks.self).filter("date = '\(date)'").distinct(by: ["character"])
        return result.first!.character
    }
    
    func addTask(_ task: Tasks) {
        try! realm.write {
            realm.add(task)
        }
    }
    
    func deleteTaskWithID(_ id: Int) {
        try! realm.write {
            realm.delete(realm.objects(Tasks.self).filter("id = \(id)"))
        }
    }
    
    func updateTask(_ id: Int, _ done_yn: String) {
        let task = self.selectTasksWithID(id)
        try! realm.write {
            task.done_yn = done_yn
        }
    }
    
    func initAllMonthsAndDates(){
        let result = realm.objects(Tasks.self).distinct(by: ["date"])
        
        var dates = [String]()
        
        for task in result {
            dates.append(task.date)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let today = formatter.string(from: Date())
        
        // 저장된 모든 요일
        allDates = dates.filter { $0 != today }.sorted().reversed()
        
        // 월로 정리
        allMonths = Array(Set<String>(allDates.map {
            let end = $0.index($0.startIndex, offsetBy: 7)
            let dateSubstr = String($0[$0.startIndex..<end])
            return dateSubstr
        })).sorted().reversed()
    }
    
    // 파라미터로 들어온 일자의 일자들 반환
    func initSelectedDates(_ month: String, completionHandler: @escaping ([String])->()) {
        var selectedDates = allDates.filter {
            let end = $0.index($0.startIndex, offsetBy: 7)
            let substring = String($0[$0.startIndex..<end])
            return substring == month
        }
        
        selectedDates = selectedDates.sorted().reversed()
        completionHandler(selectedDates)
    }
    
}

class Tasks: Object {

    @objc dynamic var id = 0
    @objc dynamic var character = "뽀짝이1"
    @objc dynamic var date = "0000.00.00"
    @objc dynamic var title = ""
    @objc dynamic var done_yn = "N"
    
    override static func primaryKey() -> String? {
      return "id"
    }
    
}

extension Results {
    
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
    
}
