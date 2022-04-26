
import UIKit
import CoreData

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
  
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "Do you want to add a new task?", if: true)
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData(completion: {result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    private func showAlert(with title: String, and message: String, if saveMode: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if saveMode == true {
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
           }
            alert.addAction(saveAction)
        } else {
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.edit(task)
                self.tableView.reloadData()
               }
                alert.addAction(editAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        
            present(alert, animated: true)

    }
    
//    private func showAlert(with title: String, and message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
//            self.save(task)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        alert.addTextField { textField in
//            textField.placeholder = "New Task"
//        }
//        present(alert, animated: true)
//    }

    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName) { task in
            self.taskList.append(task)
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func edit(_ taskName: String) {
        guard let cellIndex = tableView.indexPathForSelectedRow else { return }
        let task = taskList[cellIndex.row]
        StorageManager.shared.edit(taskName, for: task)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            StorageManager.shared.delete(task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Edit", and: "Do you want to edit the task?", if: false)
    }
}

// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
    
    
}
