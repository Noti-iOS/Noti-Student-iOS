//
//  HomeVC.swift
//  IOS_Study
//
//  Created by 황윤경 on 2021/12/18.
//

import UIKit
import FSCalendar

class HomeVC: UIViewController {
    // 임시 Subject 데이터
    let subjects = [
        Subjects("수학", "윤경T", ["쎈 수학 p110~120", "곱셈공식 암기"]),
        Subjects("영어", "호준T", ["단어 Day 7 암기", "영어 문법(초록책) p20~24", "수능특강 p11~14","a","b","c"]),
        Subjects("과학", "은희T", ["p51~60", "주기율표 암기"])
    ]
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var weekMonthChangeBtn: UIButton!
    @IBOutlet weak var subjectCV: UICollectionView!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var currentPage: Date?
    private lazy var today: Date = { return Date() }()
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM, yyyy"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendar()
        setUpSubjectCV()
        setUpDelegate()
    }
    // 월-주 Change Btn
    @IBAction func changeWeekMonth(_ sender: Any) {
        if calendarView.scope == .week {
            calendarView.setScope(.month, animated: true)
            weekMonthChangeBtn.setTitle("주", for: .normal)
        } else {
            calendarView.setScope(.week, animated: true)
            weekMonthChangeBtn.setTitle("월", for: .normal)
        }
    }
    // 다음주, 다음달 Btn
    @IBAction func goNextMonthWeek(_ sender: Any) {
        if calendarView.scope == .week {
            scrollWeekPage(isPrev: false)
        } else {
            scrollCurrentPage(isPrev: false)
        }
    }
    // 이전주, 이전달 Btn
    @IBAction func goPrevMonthWeek(_ sender: Any) {
        if calendarView.scope == .week {
            scrollWeekPage(isPrev: true)
        } else {
            scrollCurrentPage(isPrev: true)
        }
    }
}
//MARK: Custom Function
extension HomeVC {
    // 캘린더 기본 Setting
    func setUpCalendar() {
        calendarView.delegate = self
        
        calendarView.layer.cornerRadius = 10
        calendarView.layer.shadowColor = UIColor.black.cgColor
        calendarView.layer.shadowRadius = 2
        calendarView.layer.shadowOffset = CGSize(width: 0, height: 4)
        calendarView.layer.shadowOpacity = 0.3
        
        calendarView.headerHeight = 0

        currentDate.text = self.dateFormatter.string(from: calendarView.currentPage)
        
        // 요일 Title
        calendarView.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendarView.appearance.weekdayTextColor = .black
        calendarView.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14)
        
        // 선택된 날 appearance
        calendarView.appearance.selectionColor = .white
        calendarView.appearance.borderSelectionColor = UIColor.lightGray
        calendarView.appearance.titleSelectionColor = .black
    }
    
    // subjectCV Setting
    func setUpSubjectCV() {
        subjectCV.alwaysBounceVertical = true
        subjectCV.allowsSelection = false
    }
    
    // Next, Prev Month 이동
    func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        currentPage = cal.date(byAdding: dateComponents, to: currentPage ?? today)
        calendarView.setCurrentPage(currentPage!, animated: true)
    }
    
    //MARK: test
    func scrollWeekPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekOfMonth = isPrev ? -1 : 1
        currentPage = cal.date(byAdding: dateComponents, to: currentPage ?? today)
        calendarView.setCurrentPage(currentPage!, animated: true)
    }
    
    // CollectionView DataSource, Delegate Setting
    func setUpDelegate() {
        subjectCV.dataSource = self
        subjectCV.delegate = self
    }
}

//MARK: FSCalendarDelegate
extension HomeVC: FSCalendarDelegate {
    // Title Month-Year Setting
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        currentDate.text = self.dateFormatter.string(from: calendar.currentPage)
    }
    // Week-Month Calendar Height Setting
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

//MARK: UICollectionViewDataSource
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 과목 + memo
        return subjects.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == subjects.count {
            let cell = subjectCV.dequeueReusableCell(withReuseIdentifier: Identifiers.memoCVC, for: indexPath) as! MemoCVC
            return cell
        } else {
            let cell = subjectCV.dequeueReusableCell(withReuseIdentifier: Identifiers.subjectListCVC, for: indexPath) as! SubjectListCVC
            cell.subjectName.text = subjects[indexPath.row].subjectName
            cell.teacher.text = subjects[indexPath.row].teacher
            cell.homeworkContents = subjects[indexPath.row].homework
            cell.homeworkListHeight.constant = CGFloat(cell.homeworkContents.count * 45)
            return cell
        }
    }
}

//MARK: UICollectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
       if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
           calendarView.setScope(.week, animated: true)
           weekMonthChangeBtn.setTitle("월", for: .normal)
       } else if scrollView.panGestureRecognizer.translation(in: scrollView).y > 200 {
           calendarView.setScope(.month, animated: true)
           weekMonthChangeBtn.setTitle("주", for: .normal)
       }
    }
}
