//
//  WeekView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import SnapKit

final class WeekView: UIStackView {
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        distribution = .fillEqually
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension WeekView {
    func setupUI() {
        setViewHierarchy()
    }
    
    func setViewHierarchy() {
        daysOfWeek.forEach { addArrangedSubview(label($0)) }
    }
}

// MARK: - Private Methods
private extension WeekView {
    func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        if text == "일" {
            label.textColor = .red
        } else if text == "토" {
            label.textColor = .tintColor
        } else {
            label.textColor = .label
        }
        label.font = .systemFont(ofSize: 14)
        
        return label
    }
}
