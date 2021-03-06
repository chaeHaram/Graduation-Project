//
//  ToDoViewController.swift
//  diaryToDo
//
//  Created by Chae_Haram on 2022/03/12.
//

import UIKit
import FSCalendar

class ToDoViewController: UIViewController {

    @IBOutlet weak var toDoCalendarView: FSCalendar!
    @IBOutlet weak var toDoTableView: UITableView!
    @IBOutlet weak var todoDateLabel: UILabel!
    
    var calendarList: [ToDo] = []
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        toDoTableView.dataSource = self
        toDoTableView.delegate = self
        
        toDoCalendarSetting()
        toDoCalendarView.isHidden = true
        
        todoDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: Date())
        
        toDoTableView.reloadData()
        toDoCalendarView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recentToDoView()
        
        toDoTableView.reloadData()
        toDoCalendarView.reloadData()
    }
    
    func recentToDoView() {
        let sortedList = MyDB.toDoList.sorted(by: { $0.startDate > $1.startDate })
        
        let recentToDoDate: Date = MyDB.toDoList[sortedList.endIndex - 1].startDate
        calendarList = []
        
        for data in sortedList {
            if recentToDoDate == data.startDate {
                calendarList.append(data)
                todoDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: data.startDate)
            }
        }
    }
    
    func toDoCalendarSetting() {
        toDoCalendarView.delegate = self
        toDoCalendarView.dataSource = self
        
        toDoCalendarView.locale = Locale(identifier: "ko-KR")
        toDoCalendarView.appearance.selectionColor = .systemBlue
    }
    
    @IBAction func previousToDoButton(_ sender: UIButton) {
        let sortedList = MyDB.toDoList.sorted(by: { $0.startDate > $1.startDate })
        
        var previousDate: Date = selectedDate
        calendarList = []
        
        for data in sortedList { // ?????? ?????? ?????? ??????
            if selectedDate > data.startDate {
                previousDate = data.startDate
                break
            }
        }
        
        for data in MyDB.toDoList { // ????????? ????????? ????????? db??? ????????? ????????? ???????????? ???????????? ??????
            if previousDate == data.startDate {
                calendarList.append(data)
            }
        }
        
        toDoTableView.reloadData()
        selectedDate = previousDate
        todoDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: selectedDate)
    }
    
    @IBAction func nextToDoButton(_ sender: UIButton) {
        var nextDate: Date = selectedDate
        
        calendarList = []
        
        for data in MyDB.toDoList {
            if selectedDate < data.startDate {
                nextDate = data.startDate
                break
            }
        }
        
        for data in MyDB.toDoList {
            if nextDate == data.startDate {
                calendarList.append(data)
            }
        }
        
        toDoTableView.reloadData()
        selectedDate = nextDate
        todoDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: selectedDate)
    }
    
    
    @IBAction func addToDoButton(_ sender: UIBarButtonItem) {
        guard let addToDo = self.storyboard?.instantiateViewController(withIdentifier: AddToDoViewController.identifier) as? AddToDoViewController else { return }
        addToDo.viewType = .add
        self.navigationController?.pushViewController(addToDo, animated: true)
    }
    
    @IBAction func graphButon(_ sender: UIBarButtonItem) {
        guard let graphVC = self.storyboard?.instantiateViewController(withIdentifier: "GraphVC") as? GraphViewController else { return }
        self.navigationController?.pushViewController(graphVC, animated: true)
    }
    
    
    @objc func checkToDoButton(_ sender: UIButton) {
        if sender.isSelected {
            sender.setImage(UIImage(systemName: "circle"),for: .normal)
            sender.isSelected = false
            MyDB.toDoList[sender.tag].isChecked = false
        } else {
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            sender.isSelected = true
            MyDB.toDoList[sender.tag].isChecked = true
        }
    }
    
    @IBAction func calendarButton(_ sender: UIBarButtonItem) {
        if toDoCalendarView.isHidden == true {
            toDoCalendarView.isHidden = false
        } else {
            toDoCalendarView.isHidden = true
        }
        
        toDoCalendarSetting()
    }
}

extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as? ToDoTableViewCell else { return UITableViewCell() }
        let todo = calendarList[indexPath.row]
        
        cell.toDoTitleLabel.text = todo.title
        cell.toDoCheckButton.tag = indexPath.row
        cell.toDoCheckButton.addTarget(self, action: #selector(checkToDoButton), for: .touchUpInside)
        cell.toDoExpireDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: todo.endDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MyDB.toDoList.removeAll { item in
                item.title == calendarList[indexPath.row].title && item.memo == calendarList[indexPath.row].memo
            }
            calendarList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ToDoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editToDoVC = self.storyboard?.instantiateViewController(withIdentifier: AddToDoViewController.identifier) as? AddToDoViewController else { return }
        editToDoVC.viewType = .edit
        editToDoVC.editToDo = calendarList[indexPath.row]
        editToDoVC.editRow = indexPath.row
        self.navigationController?.pushViewController(editToDoVC, animated: true)
    }
}

extension ToDoViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for todo in MyDB.toDoList {
            let toDoEvent = todo.startDate
            
            if toDoEvent == date {
                let count = MyDB.toDoList.filter { todo in
                    todo.startDate == date
                }.count
                
                if count >= 3 {
                    return 3
                } else {
                    return count
                }
            }
        }
        
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        todoDateLabel.text = DateFormatter.customDateFormatter.dateToStr(date: date)
        
        calendarList = MyDB.toDoList.filter { toDo in
            toDo.startDate == date
        }
        
        toDoTableView.reloadData()
        selectedDate = date
        
        if calendarList.count == 0 {
            UIAlertController.showAlert(message: "????????? ????????? ????????????.", vc: self)
        }
    }
}
