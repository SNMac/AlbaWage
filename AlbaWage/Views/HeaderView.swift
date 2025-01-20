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
            self.prevMonthButtonView.tintColor = prevButtonDisabled ? .placeholderText : .label
        }
    }
    
    var nextButtonDisabled: Bool = false {
        didSet {
            self.nextMonthButtonView.tintColor = nextButtonDisabled ? .placeholderText : .label
        }
    }
    
    // MARK: - UI Components
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textColor = .label
        
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    let prevMonthButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.left")
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    let nextMonthButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.right")
        
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
            make.trailing.equalTo(nextMonthButtonView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        nextMonthButtonView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
    }
}
