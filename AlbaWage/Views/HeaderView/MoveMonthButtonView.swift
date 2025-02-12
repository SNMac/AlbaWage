//
//  MoveMonthButtonView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/21/25.
//

import UIKit

class MoveMonthButtonView: UIStackView {
    var prevButtonActive: Bool = true {
        didSet {
            self.prevMonthButton.isEnabled = prevButtonActive
            self.prevMonthButton.configuration?.baseForegroundColor = prevButtonActive ? .label : .placeholderText
        }
    }
    
    var nextButtonActive: Bool = true {
        didSet {
            self.nextMonthButton.isEnabled = nextButtonActive
            self.nextMonthButton.configuration?.baseForegroundColor = nextButtonActive ? .label : .placeholderText
        }
    }
    
    // MARK: - UI Components
    let prevMonthButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.left")
        buttonConfig.buttonSize = .medium
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    let todayButton: UIButton = {
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
    
    let nextMonthButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = UIImage(systemName: "chevron.right")
        buttonConfig.buttonSize = .medium
        
        let button = UIButton(configuration: buttonConfig)
        return button
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        distribution = .equalCentering
        spacing = 0
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MoveMonthButtonView {
    func setupUI() {
        setViewHierarchy()
    }
    
    func setViewHierarchy() {
        addArrangedSubview(prevMonthButton)
        addArrangedSubview(todayButton)
        addArrangedSubview(nextMonthButton)
    }
}
