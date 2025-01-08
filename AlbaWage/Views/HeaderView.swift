//
//  HeaderView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import SnapKit

final class HeaderView: UIView {
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    var leftDisabled: Bool = false {
        didSet {
            self.leftImageView.tintColor = leftDisabled ? .systemGray5 : .systemGray2
        }
    }
    
    var rightDisabled: Bool = false {
        didSet {
            self.rightImageView.tintColor = rightDisabled ? .systemGray5 : .systemGray2
        }
    }
    
    // MARK: - UI Components
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "chevron.left")
        imageView.contentMode = .scaleAspectFill
        imageView.image = image?.withAlignmentRectInsets(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
        imageView.tintColor = .systemGray5
        
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFill
        imageView.image = image?.withAlignmentRectInsets(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
        imageView.tintColor = .systemGray2
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - Initializers
    init(text: String = "") {
        super.init(frame: .zero)
        self.text = text
        
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
        addSubview(leftImageView)
        addSubview(label)
        addSubview(rightImageView)
    }
    
    func setConstraints() {
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(116)
        }
        
        leftImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(label.snp.leading).offset(-6)
        }
        
        rightImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(label.snp.trailing).offset(6)
        }
    }
}
