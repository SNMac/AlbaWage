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

    private let cellView = UIView()
    
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
        case .disabled:
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
        contentView.addSubview(cellView)
        cellView.addSubview(label)
    }
    
    private func setConstraints() {
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(1)
            make.centerX.equalToSuperview()
        }
    }
}

private extension DayCell {
    func setupUI(for type: DateType, isSelected: Bool) {
        label.textColor = textColor(for: type)
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.separator.withAlphaComponent(0.1).cgColor
//        cellView.layer.borderColor = UIColor.black.cgColor
        cellView.layer.backgroundColor = backgroundColor(isSelected: isSelected).cgColor
    }
    
    func textColor(for type: DateType) -> UIColor {
        switch type {
        case .default:
            return .label
        case .disabled:
            return .placeholderText
        }
    }
    
    func backgroundColor(isSelected: Bool) -> UIColor {
        return isSelected ? .tintColor.withAlphaComponent(0.1) : .clear
    }
}

