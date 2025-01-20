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
            monthLabel.text = monthText
        }
    }
    
    var yearText: String = "" {
        didSet {
            yearLabel.text = yearText
        }
    }
    
    var prevButtonDisabled: Bool = false {
        didSet {
            self.prevMonthButtonView.configuration?.baseForegroundColor = prevButtonDisabled ? .placeholderText : .label
        }
    }
    
    var nextButtonDisabled: Bool = false {
        didSet {
            self.nextMonthButtonView.configuration?.baseForegroundColor = nextButtonDisabled ? .placeholderText : .label
        }
    }
    
    // MARK: - UI Components
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26)
        label.textColor = .label
        
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    let prevMonthButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.left")?.applyingSymbolConfiguration(.init(pointSize: 16))
        buttonConfig.buttonSize = .small
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    let todayButtonView: UIButton = {
        var container = AttributeContainer()
        container.font = .system(size: 14)
        
        var buttonConfig = UIButton.Configuration.gray()
        buttonConfig.attributedTitle = AttributedString("오늘", attributes: container)
        buttonConfig.baseForegroundColor = .label
        buttonConfig.cornerStyle = .capsule
        buttonConfig.buttonSize = .small
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    let nextMonthButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.right")?.applyingSymbolConfiguration(.init(pointSize: 16))
        buttonConfig.buttonSize = .small
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    // MARK: - Initializers
    init(text: String = "") {
        super.init(frame: .zero)
        self.yearText = text
        self.monthText = text
        
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
        addSubview(prevMonthButtonView)
        addSubview(todayButtonView)
        addSubview(nextMonthButtonView)
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
        
        prevMonthButtonView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }
        
        todayButtonView.snp.makeConstraints { make in
            make.leading.equalTo(prevMonthButtonView.snp.trailing)
            make.trailing.equalTo(nextMonthButtonView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        nextMonthButtonView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
    }
}
