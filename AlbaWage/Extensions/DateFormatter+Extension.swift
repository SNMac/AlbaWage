//
//  DateFormatter+Extension.swift
//  AlbaWage
//
//  Created by 서동환 on 2/5/25.
//

import Foundation

extension DateFormatter {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    static func getDateFormatter() -> DateFormatter {
        return dateFormatter
    }
}
