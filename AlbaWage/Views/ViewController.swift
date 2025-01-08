//
//  ViewController.swift
//  AlbaWage
//
//  Created by 서동환 on 7/16/24.
//

import UIKit
import SnapKit
import OSLog

// TODO: 알바할때 사용가능한 체크리스트(알바 끝날때마다 체크 초기화되도록 설정)

class ViewController: UIViewController {
    let log = OSLog(subsystem: "github.com-SNMac.Albawage", category: "ViewController")
    
    let calendarView = CalendarView(startDate: .now)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(calendarView)
        calendarView.delegate = self
        calendarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - CalendarViewDelegate
extension ViewController: CalendarViewDelegate {
    func didSelect(_ date: Date) {
        os_log("date: %@", log: log, type: .debug, date as CVarArg)
    }
}