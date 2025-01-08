//
//  CalendarView.swift
//  AlbaWage
//
//  Created by 서동환 on 1/6/25.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import OSLog

public protocol CalendarViewDelegate: AnyObject {
    func didSelect(_ date: Date)
}

public final class CalendarView: UIView {
    let log = OSLog(subsystem: "github.com-SNMac.Albawage", category: "CalendarView")
    
    private let disposeBag = DisposeBag()
    
    public weak var delegate: CalendarViewDelegate?
    
    public override var intrinsicContentSize: CGSize {
        var size = calendarSize
        let stackViewHeight = weekView.frame.height
        size.height += stackViewHeight + 64
        
        return size
    }
    
    // Day Item의 높이 정의
    public var itemHeight: CGFloat = 40 {
        didSet {
            calendarCollectionView.reloadData()
            updateCalendarCollectionView()
        }
    }
    
    // Day Item 간의 spacing 정의
    public var itemSpacing: CGFloat = 9 {
        didSet {
            calendarCollectionView.reloadData()
            updateCalendarCollectionView()
        }
    }
    
    // 요일 간의 spacing 정의
    public var lineSpacing: CGFloat = 6 {
        didSet {
            calendarCollectionView.reloadData()
            updateCalendarCollectionView()
        }
    }
    
    // 달력의 'startDate'를 정의(해당 날짜를 기준으로 이전 날짜들은 disabled됨)
    public var startDate: Date {
        didSet {
            self.dataSource = dataSource(from: startDate, to: endDate)
        }
    }
    
    // 달력의 'endDate'를 정의(default는 startDate를 기준으로 5년)
    public var endDate: Date {
        didSet {
            self.dataSource = dataSource(from: startDate, to: endDate)
        }
    }
    
    // 선택된 date
    public var selectedDate: Date?
    
    private var calendarSize: CGSize {
        return CGSize(width: itemHeight * 7 + itemSpacing * 6, height: itemHeight * 6 + lineSpacing * 5)
    }
    
    private var weekLabelSpacing: CGFloat {
        return itemHeight + itemSpacing - 14
    }
    
    private var dataSource = [[CalendarDate]]() {
        didSet {
            calendarCollectionView.reloadData()
        }
    }
    
    private weak var selectedCell: CalendarCell?
    
    // MARK: - UI Components
    private let headerView = HeaderView()
    private let weekView = WeekView()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    // MARK: - Initializers
    public init(startDate: Date, endDate: Date? = nil) {
        self.startDate = startDate
        self.endDate = endDate ?? (Calendar.current.date(byAdding: .year, value: 5, to: startDate) ?? startDate)
        super.init(frame: .zero)
        
        setupUI()
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        self.dataSource = dataSource(from: startDate, to: self.endDate)
    }
    
    public convenience init(selectedDate: Date, startDate: Date, endDate: Date? = nil) {
        self.init(startDate: startDate, endDate: endDate)
        self.selectedDate = selectedDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension CalendarView {
    func setupUI() {
        weekView.spacing = weekLabelSpacing
        let startDate = CalendarDate(date: startDate)
        
        headerView.text = "\(startDate.year)년 \(startDate.month)월"
        headerView.leftDisabled = true
        
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(headerView)
        self.addSubview(weekView)
        self.addSubview(calendarCollectionView)
    }
    
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        weekView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalTo(calendarCollectionView).offset(itemHeight / 2 - 7)
        }
        
        calendarCollectionView.snp.makeConstraints {
            $0.centerX.bottom.equalToSuperview()
            $0.size.equalTo(calendarSize)
            $0.top.equalTo(weekView.snp.bottom).offset(10)
        }
        self.isUserInteractionEnabled = true
        calendarCollectionView.isUserInteractionEnabled = true
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        os_log("dataSource.count = %d", log: log, type: .debug, dataSource.count)
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(dataSource[indexPath.row], itemHeight: itemHeight, itemSpacing: itemSpacing, lineSpacing: lineSpacing)
        
        if let selectedDate = selectedDate {
            let calendarDate = CalendarDate(date: selectedDate)
            cell.selectedDate = calendarDate
        }
        
        cell.selectedDateRelay
            .bind(with: self) { owner, calendarDate in
                owner.selectedDate = calendarDate.date
                owner.delegate?.didSelect(calendarDate.date)
                if let selectedCell = owner.selectedCell, selectedCell !== cell {
                    selectedCell.deSelectAllCell()
                }
                owner.selectedCell = cell
            }
            .disposed(by: disposeBag)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

// MARK: - UIScrollViewDelegate
extension CalendarView {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if page == 0 {
            headerView.leftDisabled = true
        } else if page == dataSource.count {
            headerView.rightDisabled = true
        } else {
            headerView.leftDisabled = false
            headerView.rightDisabled = false
        }
        
        if let date = dataSource[page].first {
            setHeaderViewTitle(date)
        }
    }
}

// MARK: - Private Methods
private extension CalendarView {
    func updateCalendarCollectionView() {
        calendarCollectionView.snp.updateConstraints {
            $0.size.equalTo(calendarSize)
        }
    }
    
    func setHeaderViewTitle(_ date: CalendarDate) {
        headerView.text = "\(date.year)년 \(date.month)월"
    }
    
    func dataSource(from startDate: Date, to endDate: Date) -> [[CalendarDate]] {
        var dataSource = [[CalendarDate]]()
        
        let startCalendarDate = CalendarDate(date: startDate)
        let endCalendarDate = CalendarDate(date: endDate)
        
        var currentCalendarDate = startCalendarDate
        currentCalendarDate.day = 1
        var lastMonthCalendarDate = startCalendarDate.previousMonth()
        
        while currentCalendarDate.compareYearAndMonth(with: endCalendarDate) {
            var daysOfMonth = [CalendarDate]()
            
            let firstDayOfWeek = currentCalendarDate.startDayOfWeek()
            let totalDays = currentCalendarDate.daysOfMonth()
            let lastMonthTotalDays = lastMonthCalendarDate.daysOfMonth()
            
            // 첫 주의 빈 공간을 이전 달로 채움
            for count in (0..<firstDayOfWeek) {
                var calendarDate = currentCalendarDate
                calendarDate.day = lastMonthTotalDays - firstDayOfWeek + count + 1
                calendarDate.type = .disabled
                
                daysOfMonth.append(calendarDate)
            }
            
            // 이번 달을 채움
            var calendarDate = currentCalendarDate
            calendarDate.day = 1
            for _ in (0..<totalDays) {
                if calendarDate < startCalendarDate {
                    calendarDate.type = .disabled
                } else if calendarDate == startCalendarDate {
                    calendarDate.type = .startDate
                } else if calendarDate >= endCalendarDate {
                    calendarDate.type = .disabled
                } else {
                    calendarDate.type = .default
                }
                
                daysOfMonth.append(calendarDate)
                
                calendarDate = calendarDate.nextDay()
            }
            
            lastMonthCalendarDate = currentCalendarDate
            currentCalendarDate = currentCalendarDate.nextMonth()
            currentCalendarDate.day = 1
            
            // 마지막 주 빈 공간을 다음 달로 채움
            calendarDate = currentCalendarDate
            calendarDate.type = .disabled
            while daysOfMonth.count < 42 {
                daysOfMonth.append(calendarDate)
                calendarDate = calendarDate.nextDay()
            }
            
            dataSource.append(daysOfMonth)
        }
        
        return dataSource
    }
}
