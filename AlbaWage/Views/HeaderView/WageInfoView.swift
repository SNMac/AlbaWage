//
//  WageInfoView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/21/25.
//

import UIKit
import SnapKit

final class WageInfoView: UIStackView {
    var workHour: Int = 0 {
        didSet {
            workTimeLabel.text = "\(workHour)시간 \(workMin)분"
        }
    }
    
    var workMin: Int = 0 {
        didSet {
            workTimeLabel.text = "\(workHour)시간 \(workMin)분"
        }
    }
    
    var wage: Int = 0 {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let result = numberFormatter.string(for: wage) ?? "0"
            
            wageLabel.text = "₩\(result)"
        }
    }
    
    // MARK: - UI Components
    private let workTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        
        return label
    }()
    
    private let wageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        
        return label
    }()
    
    // MARK: - Initializers
    init(workHour: Int = 0, workMin: Int = 0, wage: Int = 0) {
        super.init(frame: .zero)
        self.workHour = workHour
        self.workMin = workMin
        self.wage = wage
        
        axis = .vertical
        alignment = .center
        distribution = .fillEqually
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 5
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension WageInfoView {
    func setupUI() {
        setViewHierarchy()
    }
    
    func setViewHierarchy() {
        addArrangedSubview(workTimeLabel)
        addArrangedSubview(wageLabel)
    }
}
