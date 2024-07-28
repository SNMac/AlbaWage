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
    
    private let calendarHeight: CGFloat = 500
    private let calendar = Calendar.current
    private var calendarDate: [Date] = Array(repeating: Date(), count: 3)  // [0] = previousCalendarDate, [1] = presentCalendarDate, [2] = followingCalendarDate
    private var days: [[String]] = Array(repeating: [], count: 3)  // [0] = previousDays, [1] = presentDays, [2] = followingDays
    
    private var scrollDirection: Int = 0  // -1 = left, 0 = none, 1 = right
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScrollView()
        configureCalendar()
    }
    
    private func configureScrollView() {
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenSize = screen()?.bounds
        scrollView.contentSize = CGSize(width: screenSize!.width * 3, height: calendarHeight)
        
        let width = screenSize!.width
        let previousXPosition = self.view.frame.width * CGFloat(0)
        previousCalendarCollectionView.frame = CGRect(x: previousXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 1
        
        let presentXPosition = self.view.frame.width * CGFloat(1)
        presentCalendarCollectionView.frame = CGRect(x: presentXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 2
        
        let followingXPosition = self.view.frame.width * CGFloat(2)
        followingCalendarCollectionView.frame = CGRect(x: followingXPosition, y: 0, width: width, height: calendarHeight)
        scrollView.contentSize.width = self.view.frame.width * 3
        
        scrollView.setContentOffset(CGPoint(x: presentXPosition, y: 0), animated: false)
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
    
    private func today() {
        let components = self.calendar.dateComponents([.year, .month], from: Date())
        self.calendarDate[1] = self.calendar.date(from: components) ?? Date()
        self.calendarDate[0] = self.calendar.date(byAdding: DateComponents(month: -1), to: self.calendarDate[1]) ?? Date()
        self.calendarDate[2] = self.calendar.date(byAdding: DateComponents(month: 1), to: self.calendarDate[1]) ?? Date()
        updateCalendars()
    }
    
    @IBAction func todayButtonTapped(_ sender: Any) {
        today()
    }
    
    private func startDayOfTheWeek(calendar: Date) -> Int {
        return self.calendar.component(.weekday, from: calendar) - 1
    }
    
    private func endDate(calendar: Date) -> Int {
        return self.calendar.range(of: .day, in: .month, for: calendar)?.count ?? Int()
    }
    
    private func updateCalendars() {
        updateDays()
    }
    
    private func updateTitle() {
        let date = dateFormatter(date: calendarDate[1])
        headerLabel.text = date
    }
    
    private func updateDays() {
        days[0].removeAll()
        days[1].removeAll()
        days[2].removeAll()
        
        let startDayOfTheWeek = [
            startDayOfTheWeek(calendar: calendarDate[0]),
            startDayOfTheWeek(calendar: calendarDate[1]),
            startDayOfTheWeek(calendar: calendarDate[2])
        ]
        let totalDays = [
            startDayOfTheWeek[0] + endDate(calendar: calendarDate[0]),
            startDayOfTheWeek[1] + endDate(calendar: calendarDate[1]),
            startDayOfTheWeek[2] + endDate(calendar: calendarDate[2])
        ]
        
        for i in 0...2 {
            for day in Int()..<totalDays[i] {
                if day < startDayOfTheWeek[i] {
                    self.days[i].append("")
                    continue
                }
                self.days[i].append("\(day - startDayOfTheWeek[i] + 1)")
            }
        }
        
        previousCalendarCollectionView.reloadData()
        presentCalendarCollectionView.reloadData()
        followingCalendarCollectionView.reloadData()
    }
    
    private func moveMonth(isNext: Bool, isButtonAction: Bool) {
        print("moveMonth()")
        let addingMonth = isNext ? 1 : -1
        self.calendarDate[0] = self.calendar.date(byAdding: DateComponents(month: addingMonth), to: self.calendarDate[0]) ?? Date()
        self.calendarDate[1] = self.calendar.date(byAdding: DateComponents(month: addingMonth), to: self.calendarDate[1]) ?? Date()
        self.calendarDate[2] = self.calendar.date(byAdding: DateComponents(month: addingMonth), to: self.calendarDate[2]) ?? Date()
        
        if isButtonAction == true {
            let xPosition = self.view.frame.width * (isNext ? CGFloat(2) : CGFloat(0))
            scrollView.setContentOffset(CGPoint(x: xPosition, y: 0), animated: true)
        }
        
        updateTitle()
    }
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        moveMonth(isNext: false, isButtonAction: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        moveMonth(isNext: true, isButtonAction: true)
    }
    
    private func centerToPresentCalendar() {
        let xPosition = self.view.frame.width * CGFloat(1)
        scrollView.setContentOffset(CGPoint(x: xPosition, y: 0), animated: false)
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
        if collectionView == previousCalendarCollectionView {
            return self.days[0].count
        } else if collectionView == presentCalendarCollectionView {
            return self.days[1].count
        } else {  // collectionView == followingCalendarCollectionView
            return self.days[2].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == previousCalendarCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviousCalendarCell", for: indexPath) as? CalendarCell else {
                return UICollectionViewCell()
            }
            cell.update(day: self.days[0][indexPath.item], index: indexPath.item)
            return cell
            
        } else if collectionView == presentCalendarCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PresentCalendarCell", for: indexPath) as? CalendarCell else {
                return UICollectionViewCell()
            }
            cell.update(day: self.days[1][indexPath.item], index: indexPath.item)
            return cell
            
        } else {  // collectionView == followingCalendarCollectionView
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingCalendarCell", for: indexPath) as? CalendarCell else {
                return UICollectionViewCell()
            }
            cell.update(day: self.days[2][indexPath.item], index: indexPath.item)
            return cell
        }
    }
}

extension CalendarViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch targetContentOffset.pointee.x {
        case self.view.frame.width * CGFloat(0):  // left
            print("scrollViewWillEndDragging() - left")
            scrollDirection = -1
        case self.view.frame.width * CGFloat(1):  // none
            print("scrollViewWillEndDragging() - none")
            scrollDirection = 0
        case self.view.frame.width * CGFloat(2):  // right
            print("scrollViewWillEndDragging() - right")
            scrollDirection = 1
        default:
            break
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating()")
        switch scrollDirection {
        case -1:  // left
            moveMonth(isNext: false, isButtonAction: false)
            centerToPresentCalendar()
            updateCalendars()
        case 1:  // right
            moveMonth(isNext: true, isButtonAction: false)
            centerToPresentCalendar()
            updateCalendars()
        default:  // none
            break
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation()")
        centerToPresentCalendar()
        updateCalendars()
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
    
    private func screen() -> UIScreen? {  // UIScreen.main 대안
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // 방법 1) 공식문서
            return view.window?.windowScene?.screen
        }
        
        // 방법 2) UIApplication를 통해 window 접근
        return window.screen
    }
}
