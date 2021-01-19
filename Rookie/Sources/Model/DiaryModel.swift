//
//  DiaryModel.swift
//  Rookie
//
//  Created by 유연주 on 2021/01/19.
//  Copyright © 2021 yookie. All rights reserved.
//

import Foundation

protocol DiaryModelDelegate {
    func diaryModel(eventDates: [String])
}
class DiaryModel {
    var delegate: DiaryModelDelegate?
    
    func fetchEventDates() {
        let eventDates = DBManager.shared.getAllDates()
        delegate?.diaryModel(eventDates: eventDates)
    }
}
