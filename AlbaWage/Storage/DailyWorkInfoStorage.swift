//
//  DailyWorkInfoStorage.swift
//  AlbaWage
//
//  Created by 서동환 on 7/17/24.
//

import Foundation

final class DailyWorkInfoStorage {
    
    func persist(_ items: [DailyWorkInfo]) {
        Storage.store(items, to: .documents, as: "diary_list.json")
    }
    
    func fetch() -> [DailyWorkInfo] {
        let list = Storage.retrive("diary_list.json", from: .documents, as: [DailyWorkInfo].self) ?? []
        return list
    }
}
