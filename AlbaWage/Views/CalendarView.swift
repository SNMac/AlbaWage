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
    public var beginDate: Date
    
    // 달력의 끝을 정의
    public var endDate: Date
    
    // 현재 CalendarView의 page
    public var nowPage: Int = 0
    
    // 선택된 date
    public var selectedDate: Date?
    
    private var dataSource = [[CalendarDate]]() {
        didSet {
            calendarCollectionView.reloadData()
        }
    }
    
    private weak var selectedCell: MonthCell?
    
    // MARK: - UI Components
    private let headerView = HeaderView(workHour: 110, workMin: 30, wage: 1089530)  // 예시
    private let weekView = WeekView()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MonthCell.self, forCellWithReuseIdentifier: "MonthCell")
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    // MARK: - Initializers
    public init() {
        self.beginDate = Date(timeIntervalSinceReferenceDate: 0)
        self.endDate = Calendar.current.date(byAdding: .year, value: 200, to: beginDate) ?? .now
        super.init(frame: .zero)
        
        setupUI()
        configureDataSource()
        
        let offsetComps = Calendar.current.dateComponents([.month], from: beginDate, to: .now)
        self.nowPage = offsetComps.month ?? 0
    }
    
    public convenience init(selectedDate: Date) {
        self.init()
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
        let today = CalendarDate(date: .now)
        
        setHeaderViewTitle(today)
        setHeaderViewButton()
        
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
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
            make.top.equalTo(weekView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as? MonthCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(dataSource[indexPath.row], itemSpacing: self.itemSpacing, lineSpacing: self.lineSpacing)
        
        if let selectedDate = self.selectedDate {
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

// MARK: - UIScrollViewDelegate
extension CalendarView {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.nowPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        updateHeaderViewTitle()
        updateHeaderViewButton()
    }
}

// MARK: - Private Methods
private extension CalendarView {
    func configureDataSource() {
        var dataSource = [[CalendarDate]]()
        
        let calendarBeginDate = CalendarDate(date: self.beginDate)
        let calendarEndDate = CalendarDate(date: self.endDate)
        
        var currCalendarDate = calendarBeginDate
        currCalendarDate.day = 1
        var lastMonthCalendarDate = calendarBeginDate.previousMonth()
        
        while currCalendarDate.compareYearAndMonth(with: calendarEndDate) {
            var daysOfMonth = [CalendarDate]()
            
            let firstDayOfWeek = currCalendarDate.startDayOfWeek()
            let totalDays = currCalendarDate.daysOfMonth()
            let lastMonthTotalDays = lastMonthCalendarDate.daysOfMonth()
            
            // 첫 주의 빈 공간을 이전 달로 채움
            for count in (0..<firstDayOfWeek) {
                var calendarDate = currCalendarDate
                calendarDate.day = lastMonthTotalDays - firstDayOfWeek + count + 1
                calendarDate.type = .disabled
                
                daysOfMonth.append(calendarDate)
            }
            
            // 이번 달을 채움
            var iterCalendarDate = currCalendarDate
            iterCalendarDate.day = 1
            for _ in (0..<totalDays) {
                if iterCalendarDate < calendarBeginDate {
                    iterCalendarDate.type = .disabled
                } else if iterCalendarDate >= calendarEndDate {
                    iterCalendarDate.type = .disabled
                } else {
                    iterCalendarDate.type = .default
                }
                
                daysOfMonth.append(iterCalendarDate)
                
                iterCalendarDate = iterCalendarDate.nextDay()
            }
            
            lastMonthCalendarDate = currCalendarDate
            currCalendarDate = currCalendarDate.nextMonth()
            currCalendarDate.day = 1
            
            // 마지막 주 빈 공간을 다음 달로 채움
            iterCalendarDate = currCalendarDate
            iterCalendarDate.type = .disabled
            while daysOfMonth.count < 42 {
                daysOfMonth.append(iterCalendarDate)
                iterCalendarDate = iterCalendarDate.nextDay()
            }
            
            dataSource.append(daysOfMonth)
        }
        
        self.dataSource = dataSource
    }
    
    func scrollToPage(_ page: Int, animated: Bool) {
        calendarCollectionView.scrollToItem(at: IndexPath(item: page, section: .zero), at: .centeredHorizontally, animated: animated)
    }
    
    func setHeaderViewTitle(_ date: CalendarDate) {
        headerView.monthText = "\(date.month)"
        headerView.yearText = "\(date.year)"
    }
    
    func setHeaderViewButton() {
        let prevMonthButtonAction = UIAction(handler: { _ in
            self.nowPage -= 1
            self.scrollToPage(self.nowPage, animated: true)
            self.updateHeaderViewTitle()
            self.updateHeaderViewButton()
        })
        
        let todayButtonAction = UIAction(handler: { _ in
            let offsetComps = Calendar.current.dateComponents([.month], from: self.beginDate, to: .now)
            self.nowPage = offsetComps.month ?? 0
            self.scrollToPage(self.nowPage, animated: true)
            self.updateHeaderViewTitle()
            self.updateHeaderViewButton()
        })
        
        let nextMonthButtonAction = UIAction(handler: { _ in
            self.nowPage += 1
            self.scrollToPage(self.nowPage, animated: true)
            self.updateHeaderViewTitle()
            self.updateHeaderViewButton()
        })
        
        headerView.setButtonAction(prevMonthButtonAction, todayButtonAction, nextMonthButtonAction)
    }
    
    func updateCalendarCollectionView() {
        calendarCollectionView.snp.updateConstraints { make in
            make.top.equalTo(weekView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func updateHeaderViewTitle() {
        if let date = dataSource[nowPage].first {
            setHeaderViewTitle(date)
        }
    }
    
    func updateHeaderViewButton() {
        if nowPage == 0 {
            headerView.activePrevMonthButton(false)
        } else if nowPage == dataSource.count - 1 {
            headerView.activeNextMonthButton(false)
        } else {
            headerView.activePrevMonthButton(true)
            headerView.activeNextMonthButton(true)
        }
    }
}
