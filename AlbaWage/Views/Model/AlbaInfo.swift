//
//  AlbaInfo.swift
//  AlbaWage
//
//  Created by 서동환 on 1/21/25.
//

import Foundation

struct AlbaInfo: Codable, Hashable {
    let workPlace: String  // 근무지
    let salaryType: String  // 급여 유형
    let salary: Int? // 월급
    let wage: Int?  // 시급
    let payday: Int  // 급여일
}
