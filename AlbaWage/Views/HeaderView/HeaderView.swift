//
//  HeaderView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import SnapKit

final class HeaderView: UIView {
    var monthText: String = "" {
        didSet {
            monthLabel.text = "\(monthText)월"
        }
    }
    
    var yearText: String = "" {
        didSet {
            yearLabel.text = yearText
        }
    }
    
    // MARK: - UI Components
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 26, weight: .regular)
        label.textColor = .label
        
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let wageInfoView = WageInfoView()
    
    private let moveMonthButtonView = MoveMonthButtonView()
    
    // MARK: - Initializers
    init(
        monthText: String = "",
        yearText: String = "",
        workHour: Int = 0,
        workMin: Int = 0,
        wage: Int = 0
    ) {
        super.init(frame: .zero)
        self.monthText = monthText
        self.yearText = yearText
        self.wageInfoView.workHour = workHour
        self.wageInfoView.workMin = workMin
        self.wageInfoView.wage = wage
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension HeaderView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        addSubview(monthLabel)
        addSubview(yearLabel)
        addSubview(wageInfoView)
        addSubview(moveMonthButtonView)
    }
    
    func setConstraints() {
        monthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
        yearLabel.snp.makeConstraints { make in
            make.leading.equalTo(monthLabel.snp.trailing).offset(10)
            make.centerY.equalTo(monthLabel)
        }
        
        wageInfoView.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        moveMonthButtonView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension HeaderView {
    func activePrevMonthButton(_ active: Bool) {
        moveMonthButtonView.prevButtonActive = active
    }
    
    func activeNextMonthButton(_ active: Bool) {
        moveMonthButtonView.nextButtonActive = active
    }
    
    func setButtonAction(_ prevMonthButtonAction: UIAction, _ todayButtonAction: UIAction, _ nextMonthButtonAction: UIAction) {
        moveMonthButtonView.prevMonthButton.addAction(prevMonthButtonAction, for: .touchUpInside)
        moveMonthButtonView.todayButton.addAction(todayButtonAction, for: .touchUpInside)
        moveMonthButtonView.nextMonthButton.addAction(nextMonthButtonAction, for: .touchUpInside)
    }
}
