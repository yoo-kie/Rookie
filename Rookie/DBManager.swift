//
//  DBManager.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/21.
//  Copyright © 2020 yookie. All rights reserved.
//

import Foundation
import RealmSwift

// Realm 데이터를 관리하는 부분
// 싱글톤으로 구성

class DBManager {
    static let shared = DBManager()
    
    var realm: Realm {
        guard let realm = Realm.safeInit() else {
            return self.realm
        }
        return realm
    }
    
    var allMonths = [String]()
    var allDates = [String]()
    var todayCharacter: String = ""
    var characterCollection = [String]()
    
    func incrementTaskID() -> Int {
        return (realm.objects(Tasks.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func selectAllTasks() -> [Tasks] {
        let result = realm.objects(Tasks.self).toArray(type: Tasks.self)
        return result
    }
    
    func selectTasksWithID(_ idx: Int) -> Tasks {
        let result = realm.objects(Tasks.self).filter("id = \(idx)").toArray(type: Tasks.self)
        print(result)
        
        return result.first!
    }
    
    func selectTasksWithDate(_ date: String) -> [Tasks] {
        var result = realm.objects(Tasks.self).filter("date = '\(date)'").toArray(type: Tasks.self)
        result.sort { $0.done_yn < $1.done_yn }
        
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
        realm.safeWrite {
            realm.add(task)
        }
    }
    
    func deleteTaskWithID(_ idx: Int) {
        realm.safeWrite {
            realm.delete(realm.objects(Tasks.self).filter("id = \(idx)"))
        }
    }
    
    func updateTaskDoneYN(_ idx: Int, _ done_yn: String) {
        let task = self.selectTasksWithID(idx)
        realm.safeWrite {
            task.done_yn = done_yn
        }
    }
    
    func updateTaskDate(_ idx: Int, _ date: String) {
        let task = self.selectTasksWithID(idx)
        realm.safeWrite {
            task.date = date
        }
    }
    
    func initAllMonthsAndDates() {
        let result = realm.objects(Tasks.self).distinct(by: ["date"])
        
        var dates = [String]()
        
        for task in result {
            dates.append(task.date)
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy.MM.dd eee"
        let today = formatter.string(from: Date())
        
        allDates = dates.filter { $0 != today }.sorted().reversed()
        
        allMonths = Array(Set<String>(allDates.map {
            let end = $0.index($0.startIndex, offsetBy: 7)
            let dateSubstr = String($0[$0.startIndex..<end])
            return dateSubstr
        })).sorted().reversed()
    }
    
    // 파라미터로 들어온 월의 일자들 반환
    func initSelectedDates(_ month: String, completionHandler: @escaping ([String]) -> Void) {
        var selectedDates = allDates.filter {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko")
            formatter.dateFormat = "yyyy.MM.dd eee"
            let today = formatter.string(from: Date())
            
            let end = $0.index($0.startIndex, offsetBy: 7)
            let substring = String($0[$0.startIndex..<end])
            return ($0 <= today) && (substring == month)
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

extension Realm {
    static func safeInit() -> Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            print("Could not init Realm")
        }
        return nil
    }

    func safeWrite(_ block: () -> Void) {
        do {
            // Async safety, to prevent "Realm already in a write transaction" Exceptions
            if !isInWriteTransaction {
                try write(block)
            }
        } catch {
            print("Could not write Realm")
        }
    }
}

extension Results {
    
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
    
}
