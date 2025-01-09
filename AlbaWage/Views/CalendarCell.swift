//
//  CalendarCell.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import RxRelay
import SnapKit

// 특정 달의 달력을 표시하는 Cell
class CalendarCell: UICollectionViewCell {
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    private var itemSpacing: CGFloat = 0
    private var lineSpacing: CGFloat = 0
    
    private var dataSource: [CalendarDate] = [] {
        didSet {
            monthCollectionView.reloadData()
        }
    }
    
    var selectedDate: CalendarDate?
    var selectedDateRelay = PublishRelay<CalendarDate>()
    
    // MARK: - UI Components
    private let monthCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        monthCollectionView.dataSource = self
        monthCollectionView.delegate = self
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Configure Method
    func configure(_ dataSource: [CalendarDate], itemWidth: CGFloat, itemHeight: CGFloat, itemSpacing: CGFloat, lineSpacing: CGFloat) {
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
        monthCollectionView.collectionViewLayout = collectionViewLayout()
        self.dataSource = dataSource
    }
}

// MARK: - UI Methods
private extension CalendarCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        contentView.addSubview(monthCollectionView)
    }
    
    func setConstraints() {
        monthCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? DayCell else {
            return UICollectionViewCell()
        }
        
        let calendarDate = dataSource[indexPath.row]
        
        cell.configure("\(calendarDate.day)", type: calendarDate.type)
        
        if calendarDate == selectedDate {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            cell.isSelected = true
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDateRelay.accept(dataSource[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return false
        }
        
        return !cell.isSelected
    }
}

// MARK: - Internal Methods
extension CalendarCell {
    func deSelectAllCell() {
        let count = monthCollectionView.visibleCells.count
        
        for row in (0..<count) {
            let indexPath = IndexPath(row: row, section: 0)
            
            if let cell = monthCollectionView.cellForItem(at: indexPath) {
                monthCollectionView.deselectItem(at: indexPath, animated: false)
                cell.isSelected = false
            }
        }
    }
}

// MARK: - Private Methods
private extension CalendarCell {
    func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 7), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(itemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = lineSpacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
