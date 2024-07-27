//
//  CalendarViewController.swift
//  AlbaWage
//
//  Created by 서동환 on 7/16/24.
//

import UIKit
import Combine


// TODO: 알바할때 사용가능한 체크리스트(알바 끝날때마다 체크 초기화되도록 설정)
class CalendarViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var weekStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previousCalendarCollectionView: UICollectionView!
    @IBOutlet weak var presentCalendarCollectionView: UICollectionView!
    @IBOutlet weak var followingCalendarCollectionView: UICollectionView!
    
    private let calendar = Calendar.current
    private var calendarDate = Date()
    private var previousDays = [String]()
    private var presentDays = [String]()
    private var followingDays = [String]()
    private let calendarHeight: CGFloat = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
        configureScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func configureCalendar() {
        previousCalendarCollectionView.delegate = self
        previousCalendarCollectionView.dataSource = self
        presentCalendarCollectionView.delegate = self
        presentCalendarCollectionView.dataSource = self
        followingCalendarCollectionView.delegate = self
        followingCalendarCollectionView.dataSource = self
        
        today()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        
        let screenSize = screen()?.bounds
        scrollView.contentSize = CGSize(width: screenSize!.width * 3, height: calendarHeight)
        
        let width = screenSize!.width
        let prevXPosition = self.view.frame.width * CGFloat(0)
        previousCalendarCollectionView.frame = CGRect(x: prevXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 1
        
        let presentXPosition = self.view.frame.width * CGFloat(1)
        presentCalendarCollectionView.frame = CGRect(x: presentXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 2
        
        let followingXPosition = self.view.frame.width * CGFloat(2)
        followingCalendarCollectionView.frame = CGRect(x: followingXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 3
        
        scrollView.setContentOffset(CGPoint(x: presentXPosition, y: 0), animated: false)
    }
    
    private func today() {
        let components = self.calendar.dateComponents([.year, .month], from: Date())
        self.calendarDate = self.calendar.date(from: components) ?? Date()
        updateCalendar()
    }
    
    @IBAction func todayButtonTapped(_ sender: Any) {
        today()
    }
    
    private func startDayOfTheWeek() -> Int {
        return self.calendar.component(.weekday, from: self.calendarDate) - 1
    }
    
    private func endDate() -> Int {
        return self.calendar.range(of: .day, in: .month, for: self.calendarDate)?.count ?? Int()
    }
    
    private func updateTitle() {
        let date = dateFormatter(date: calendarDate)
        headerLabel.text = date
    }
    
    private func updateDays() {
        self.presentDays.removeAll()
        let startDayOfTheWeek = startDayOfTheWeek()
        let totalDays = startDayOfTheWeek + endDate()
        
        for day in Int()..<totalDays {
            if day < startDayOfTheWeek {
                self.presentDays.append("")
                continue
            }
            self.presentDays.append("\(day - startDayOfTheWeek + 1)")
        }
        
        presentCalendarCollectionView.reloadData()
    }
    
    private func updateCalendar() {
        updateTitle()
        updateDays()
    }
    
    private func moveMonth(isNext: Bool) {
        let addingMonth = isNext ? 1 : -1
        self.calendarDate = self.calendar.date(byAdding: DateComponents(month: addingMonth), to: self.calendarDate) ?? Date()
        updateCalendar()
    }
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        moveMonth(isNext: false)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        moveMonth(isNext: true)
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = weekStackView.frame.width / 7
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presentDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let dayColor: UIColor
        switch indexPath.item % 7 {
        case 0:
            dayColor = .systemRed
        case 6:
            dayColor = .systemBlue
        default:
            dayColor = .label
        }
        cell.update(day: self.presentDays[indexPath.item], color: dayColor)
        return cell
    }
}

extension CalendarViewController {
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        let result = formatter.string(from: date)
        return result
    }
    
    private func numberFormatter(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let result = formatter.string(from: NSNumber(integerLiteral: price)) ?? ""
        return result
    }
}

extension CalendarViewController {
    func screen() -> UIScreen? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // 방법 1) 공식문서
            return view.window?.windowScene?.screen
        }
        
        // 방법 2) UIApplication를 통해 window 접근
        return window.screen
    }
}
