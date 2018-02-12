//
//  TasksViewController.swift
//  Tasks
//
//  Created by Alejandro Ruperez Hernando on 8/2/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UIKit
import Intents

class TasksViewController: UITableViewController {
    private var tasks = [INTask]() {
        didSet {
            navigationItem.rightBarButtonItem = tasks.isEmpty ? nil : editButtonItem
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: TaskTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TaskTableViewCell.self))
    }

    // MARK: - Private Methods

    private func insert(_ text: String) {
        let title = INSpeakableString(spokenPhrase: text)
        let currentDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: Date())
        let task = INTask(title: title, status: .notCompleted, taskType: .completable, spatialEventTrigger: nil, temporalEventTrigger: nil, createdDateComponents: currentDateComponents, modifiedDateComponents: currentDateComponents, identifier: UUID().uuidString)
        tasks.append(task)
        let indexPath = IndexPath(row: tasks.count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func update(text: String? = nil, isOn: Bool? = nil, indexPath: IndexPath) {
        guard tasks.count > indexPath.row else {
            return
        }
        let oldTask = tasks[indexPath.row]
        var title = oldTask.title
        if let text = text {
            title = INSpeakableString(spokenPhrase: text)
        }
        var status = oldTask.status
        if let isOn = isOn {
            status = isOn ? .completed : .notCompleted
        }
        let currentDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: Date())
        let task = INTask(title: title, status: status, taskType: oldTask.taskType, spatialEventTrigger: oldTask.spatialEventTrigger, temporalEventTrigger: oldTask.temporalEventTrigger, createdDateComponents: oldTask.createdDateComponents, modifiedDateComponents: currentDateComponents, identifier: oldTask.identifier)
        tasks[indexPath.row] = task
    }

    private func delete(_ indexPath: IndexPath) {
        guard tasks.count > indexPath.row else {
            return
        }
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self), for: indexPath) as! TaskTableViewCell

        if tasks.count > indexPath.row {
            cell.config(tasks[indexPath.row].title.spokenPhrase, delegate: self)
        } else {
            cell.config(delegate: self)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tasks.count > indexPath.row
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tasks.count > indexPath.row
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tasks.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // TODO: Show detail
    }

}

extension TasksViewController: TaskTableViewCellDelegate {

    // MARK: - Task Cell Delegate

    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, isOn: Bool) {
        if let indexPath = tableView.indexPath(for: taskTableViewCell) {
            update(isOn: isOn, indexPath: indexPath)
        }
    }

    func taskTableViewCellDidChange(_ taskTableViewCell: TaskTableViewCell, text: String) {
        if let indexPath = tableView.indexPath(for: taskTableViewCell) {
            if !text.isEmpty {
                if taskTableViewCell.isAddCellType {
                    insert(text)
                } else {
                    update(text: text, indexPath: indexPath)
                }
            } else {
                delete(indexPath)
            }
        }
    }

}

