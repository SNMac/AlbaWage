//
//  DailyWorkInfo.swift
//  AlbaWage
//
//  Created by 서동환 on 7/17/24.
//

import Foundation

struct DailyWorkInfo: Identifiable, Codable {
    var id: UUID = UUID()
    var date: String
    var hour: Int
    var rate: Int
    // TODO: 시급인지 일급인지 월급인지 선택하는 기능 필요
}

extension DailyWorkInfo {
    private var dateComponent: DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date = formatter.date(from: self.date)
        let dc = calendar.dateComponents([.year, .month], from: date!)
        return dc
    }
    
    var monthlyIdentifier: String {
        return "\(dateComponent.year!)-\(dateComponent.month!)"
    }
}

extension DailyWorkInfo {
    
}
