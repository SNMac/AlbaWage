//
//  CalendarCell.swift
//  AlbaWage
//
//  Created by 서동환 on 7/26/24.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    private func configure() {
        
    }
    
    func update(day: String, index: Int) {
        dayLabel.text = day
        
        // 토, 일 색깔 설정
        switch index % 7 {
        case 0:
            dayLabel.textColor = .systemRed
        case 6:
            dayLabel.textColor = .systemBlue
        default:
            dayLabel.textColor = .label
        }
    }
}
