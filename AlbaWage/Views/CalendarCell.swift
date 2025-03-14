//
//  MonthCell.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import RxRelay
import SnapKit

// 특정 달의 달력을 표시하는 Cell
class MonthCell: UICollectionViewCell {
    private var itemSpacing: CGFloat = 0
    private var lineSpacing: CGFloat = 0
    
    enum Section: CaseIterable {
        case main
    }
    typealias Item = CalendarDate
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var calendarDates: [CalendarDate] = []
    
    var selectedDate: CalendarDate?
    var selectedDateRelay = PublishRelay<CalendarDate>()
    
    // MARK: - UI Components
    private let monthCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDataSource()
        monthCollectionView.delegate = self
        monthCollectionView.collectionViewLayout = layout()
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Configure Method
    func configure(_ dataSource: [CalendarDate], itemSpacing: CGFloat, lineSpacing: CGFloat) {
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        
        self.calendarDates = dataSource
    }
}

// MARK: - UI Methods
private extension MonthCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        contentView.addSubview(monthCollectionView)
    }
    
    func setConstraints() {
        monthCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
//extension MonthCell: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return calendarDates.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? DayCell else {
//            return UICollectionViewCell()
//        }
//
//        let calendarDate = calendarDates[indexPath.row]
//
//        cell.configure("\(calendarDate.day)", type: calendarDate.type)
//
////        if calendarDate == CalendarDate(date: .now) {
////            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
////            cell.isSelected = true
////        }
//
//        if calendarDate == selectedDate {
//            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
//            cell.isSelected = true
//        }
//
//        return cell
//    }
//}

// MARK: - UICollectionViewDelegate
extension MonthCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDateRelay.accept(calendarDates[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return false
        }
        
        return !cell.isSelected
    }
}

// MARK: - Internal Methods
extension MonthCell {
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
private extension MonthCell {
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration
        <DayCell, Item> { (cell, indexPath, mountain) in
            let calendarDate = self.calendarDates[indexPath.row]
            cell.configure("\(calendarDate.day)", type: calendarDate.type)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: monthCollectionView, cellProvider: { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(calendarDates)
        dataSource.apply(snapshot)
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 7), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1 / 6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
        group.interItemSpacing = .fixed(itemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = lineSpacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
