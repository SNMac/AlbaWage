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
    let log = OSLog(subsystem: "com.snmac.AlbaWage", category: "CalendarView")
    
    private let disposeBag = DisposeBag()
    
    public weak var delegate: CalendarViewDelegate?
    
    // Day Item 간의 spacing 정의
    public var itemSpacing: CGFloat = 0 {
        didSet {
            calendarCollectionView.reloadData()
            updateCalendarCollectionView()
        }
    }
    
    // 요일 간의 spacing 정의
    public var lineSpacing: CGFloat = 5 {
        didSet {
            calendarCollectionView.reloadData()
            updateCalendarCollectionView()
        }
    }
    
    // 달력의 시작을 정의
    public var startDate: Date {
        didSet {
            self.dataSource = dataSource(from: startDate, to: endDate)
        }
    }
    
    // 달력의 끝을 정의
    public var endDate: Date {
        didSet {
            self.dataSource = dataSource(from: startDate, to: endDate)
        }
    }
    
    // 현재 CalendarView의 page
    public var nowPage: Int = 0
    
    // 현재 page의 date
    public var nowPagingDate: Date
    
    // 선택된 date
    public var selectedDate: Date?
    
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
    public init(_ nowPagingDate: Date) {
        self.nowPagingDate = nowPagingDate
        self.startDate = Calendar.current.date(byAdding: .year, value: -150, to: nowPagingDate) ?? nowPagingDate
        self.endDate = Calendar.current.date(byAdding: .year, value: 150, to: nowPagingDate) ?? nowPagingDate
        super.init(frame: .zero)
        
        setupUI()
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        self.dataSource = dataSource(from: self.startDate, to: self.endDate)
        self.nowPage = self.dataSource.count / 2
    }
    
    public convenience init(selectedDate: Date, nowPagingDate: Date) {
        self.init(nowPagingDate)
        self.selectedDate = selectedDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        calendarCollectionView.scrollToItem(at: IndexPath(item: self.nowPage, section: .zero), at: .centeredHorizontally, animated: false)
        updateHeaderViewButton()
    }
}

// MARK: - UI Methods
private extension CalendarView {
    func setupUI() {
        let nowPagingDate = CalendarDate(date: nowPagingDate)
        
        setHeaderViewTitle(nowPagingDate)
        setHeaderViewButton()
        
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(headerView)
        self.addSubview(weekView)
        self.addSubview(calendarCollectionView)
    }
    
    func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        weekView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        calendarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
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
        
        cell.configure(dataSource[indexPath.row], itemSpacing: itemSpacing, lineSpacing: lineSpacing)
        
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
        nowPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        updateHeaderViewTitle()
        updateHeaderViewButton()
    }
}

// MARK: - Private Methods
private extension CalendarView {
    func updateCalendarCollectionView() {
        calendarCollectionView.snp.updateConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setHeaderViewTitle(_ date: CalendarDate) {
        headerView.monthText = "\(date.month)월"
        headerView.yearText = "\(date.year)"
    }
    
    func setHeaderViewButton() {
        headerView.prevMonthButtonView.addAction(UIAction(handler: { _ in
            self.nowPage -= 1
            self.calendarCollectionView.scrollToItem(at: IndexPath(item: self.nowPage, section: .zero), at: .centeredHorizontally, animated: true)
            self.updateHeaderViewTitle()
            self.updateHeaderViewButton()
        }), for: .touchUpInside)
        headerView.nextMonthButtonView.addAction(UIAction(handler: { _ in
            self.nowPage += 1
            self.calendarCollectionView.scrollToItem(at: IndexPath(item: self.nowPage, section: .zero), at: .centeredHorizontally, animated: true)
            self.updateHeaderViewTitle()
            self.updateHeaderViewButton()
        }), for: .touchUpInside)
    }
    
    func updateHeaderViewTitle() {
        if let date = dataSource[nowPage].first {
            setHeaderViewTitle(date)
        }
    }
    
    func updateHeaderViewButton() {
        if nowPage == 0 {
            headerView.prevButtonDisabled = true
        } else if nowPage == dataSource.count - 1 {
            headerView.nextButtonDisabled = true
        } else {
            headerView.prevButtonDisabled = false
            headerView.nextButtonDisabled = false
        }
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
