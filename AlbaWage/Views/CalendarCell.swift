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
    
    func update(day: String, color: UIColor) {
        dayLabel.text = day
        dayLabel.textColor = color
    }
}
