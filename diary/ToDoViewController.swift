//
//  ToDoViewController.swift
//  diary
//
//  Created by Chae_Haram on 2022/01/19.
//

import UIKit

class ToDoViewController: UIViewController {
    
    //UI
    @IBOutlet weak var toDoListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toDoListTableView.reloadData()
    }
    
}
extension ToDoViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    } // tablr view cell 높이 설정
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editToDoVC = self.storyboard?.instantiateViewController(withIdentifier: "editToDoVC") as? EditToDoViewCoantroller else { return }
        editToDoVC.editToDo = ToDo.toDoList[indexPath.row]
        editToDoVC.row = indexPath.row
        self.navigationController?.pushViewController(editToDoVC, animated: true)
    }
}

extension ToDoViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ToDo.toDoList.count // 몇개의 줄을 보여줄지 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "toDoTableCell", for: indexPath) as? ToDoTableViewCell else { return UITableViewCell() }
        let todo = ToDo.toDoList[indexPath.row]
        cell.toDoTitleLabel.text = todo.title
        cell.toDoMemoLabel.text = todo.memo
        //cell.toDoStartTimeLabel.text = todo.
        //cell.toDoEndTimeLabel.text = toDoEndTime[indexPath.row]
        
        return cell
    }
}

