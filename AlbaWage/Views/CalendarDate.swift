//
//  CalendarDate.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import Foundation

enum DateType {
    // 선택 가능한 날짜
    case `default`
    // 선택 불가능한 날짜
    case disabled
}

struct CalendarDate: Hashable {
    let id = UUID()
    var year: Int
    var month: Int
    var day: Int
    var type: DateType
    
    let dateFormatter = DateFormatter()
    
    var date: Date {
        let string = "\(year)-\(month)-\(day)"
        let date = toFormattedDate(string) ?? .now
        
        let timeZone = TimeZone.autoupdatingCurrent
        let secondsFromGMT = timeZone.secondsFromGMT(for: date)
        let localizedDate = date.addingTimeInterval(TimeInterval(secondsFromGMT))
        
        return localizedDate
    }
}

// MARK: - Initializers
extension CalendarDate {
    init(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        self.year = components.year ?? 0
        self.month = components.month ?? 0
        self.day = components.day ?? 0
        self.type = .default
    }
}

// MARK: - Methods
extension CalendarDate {
    // 'year', 'month'의 첫번째 요일을 정수형으로 리턴
    func startDayOfWeek() -> Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        let date = calendar.date(from: components) ?? Date()
        
        return calendar.component(.weekday, from: date) - 1
    }
    
    // 'year', 'month'의 총 날짜 수를 리턴
    func daysOfMonth() -> Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        let date = calendar.date(from: components) ?? Date()
        
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    // 현재 'Date'가 매개변수의 'date' 보다 작다면 true를 리턴
    func compareYearAndMonth(with date: CalendarDate) -> Bool {
        if year < date.year {
            return true
        } else if year == date.year && month <= date.month {
            return true
        } else {
            return false
        }
    }
    
    // 이전 달의 'CalendarDate'를 리턴
    func previousMonth() -> CalendarDate {
        if month == 1 {
            return CalendarDate(year: year - 1, month: 12, day: day, type: type)
        } else {
            return CalendarDate(year: year, month: month - 1, day: day, type: type)
        }
    }
    
    // 다음 달의 'CalendarDate'를 리턴
    func nextMonth() -> CalendarDate {
        if month == 12 {
            return CalendarDate(year: year + 1, month: 1, day: day, type: type)
        } else {
            return CalendarDate(year: year, month: month + 1, day: day, type: type)
        }
    }
    
    // 다음 날짜의 'CalendarDate'를 리턴
    func nextDay() -> CalendarDate {
        if day == self.daysOfMonth() {
            return nextMonth()
        } else {
            return CalendarDate(year: year, month: month, day: day + 1, type: type)
        }
    }
}

// MARK: - Comparable
extension CalendarDate: Comparable {
    static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        } else {
            return lhs.day < rhs.day
        }
    }
    
    static func == (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}

extension CalendarDate {
    func toFormattedDate(_ date: String) -> Date? {
        let dateFormatter = DateFormatter.getDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.date(from: date)
      }
}
