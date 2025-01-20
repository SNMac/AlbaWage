//
//  DayCell.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import SnapKit

final class DayCell: UICollectionViewCell {
    private var type: DateType = .default
    
    override var isSelected: Bool {
        didSet {
            self.setupUI(for: type, isSelected: isSelected)
        }
    }
    
    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    private let seperator: UIView = {
        let seperator = UIView()
        seperator.backgroundColor = .separator
        
        return seperator
    }()
    
    private let squareView = UIView()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(_ day: String, type: DateType) {
        self.label.text = day
        self.type = type
        
        switch type {
        case .default:
            self.isUserInteractionEnabled = true
        case .disabled, .startDate:
            self.isUserInteractionEnabled = false
        }
        
        setupUI(for: type, isSelected: isSelected)
    }
}

// MARK: - UI Methods
private extension DayCell {
    private func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    private func setViewHierarchy() {
        contentView.addSubview(squareView)
        squareView.addSubview(seperator)
        squareView.addSubview(label)
    }
    
    private func setConstraints() {
        squareView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        seperator.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(seperator.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
}

private extension DayCell {
    func setupUI(for type: DateType, isSelected: Bool) {
        label.textColor = textColor(for: type, isSelected: isSelected)
    }
    
    func textColor(for type: DateType, isSelected: Bool) -> UIColor {
        switch type {
        case .default:
            return isSelected ? .secondaryLabel : .label
        case .disabled:
            return .placeholderText
        case .startDate:
            return .label
        }
    }
    
    func backgroundColor(for type: DateType, isSelected: Bool) -> UIColor {
        switch type {
        case .default:
            return isSelected ? .secondarySystemBackground : .systemBackground
        case .disabled:
            return .systemBackground
        case .startDate:
            return .secondarySystemBackground
        }
    }
}

