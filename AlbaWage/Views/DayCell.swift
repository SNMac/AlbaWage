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
    
    var isToday: Bool = false {
        didSet {
            setupUI(for: type, isSelected: isSelected, isToday: isToday)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setupUI(for: type, isSelected: isSelected, isToday: isToday)
        }
    }
    
    // MARK: - UI Components
    private let seperator: UIView = {
        let seperator = UILabel()
        seperator.backgroundColor = .separator
        
        return seperator
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        
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
        
//        switch type {
//        case .default:
//            self.isUserInteractionEnabled = true
//        case .disabled:
//            self.isUserInteractionEnabled = false
//        }
        self.isUserInteractionEnabled = true
        
        setupUI(for: type, isSelected: isSelected, isToday: isToday)
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
        cellView.addSubview(seperator)
        cellView.addSubview(label)
    }
    
    private func setConstraints() {
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        seperator.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
}

private extension DayCell {
    func setupUI(for type: DateType, isSelected: Bool, isToday: Bool) {
        if isToday {
            label.textColor = .systemBackground
            label.backgroundColor = .label
            cellView.layer.backgroundColor = UIColor.systemGray5.cgColor
        } else {
            label.textColor = textColor(for: type)
            label.backgroundColor = .clear
            cellView.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.bounds.width / 2.0
        
        cellView.layer.cornerRadius = 5
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = borderColor(isSelected: isSelected).cgColor
    }
    
    func textColor(for type: DateType) -> UIColor {
        switch type {
        case .default:
            return .label
        case .disabled:
            return .placeholderText
        }
    }
    
    func borderColor(isSelected: Bool) -> UIColor {
        return isSelected ? .tintColor : .clear
    }
}

