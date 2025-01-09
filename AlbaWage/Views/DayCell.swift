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
        label.font = .boldSystemFont(ofSize: 15)
        
        return label
    }()
    private let seperator: UIView = {
        let seperator = UIView()
        seperator.backgroundColor = .lightGray
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let seperatorHeight: CGFloat = 1.0
        seperator.frame = CGRect(x: 0, y: contentView.bounds.height - seperatorHeight, width: contentView.bounds.width, height: seperatorHeight)
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
        squareView.addSubview(label)
        squareView.addSubview(seperator)
    }
    
    private func setConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
            
        squareView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

