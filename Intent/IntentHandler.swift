//
//  IntentHandler.swift
//  Intent
//
//  Created by Alejandro Ruperez Hernando on 8/2/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import Intents
import Core

extension INTask: Storable {}

class IntentHandler: INExtension, INAddTasksIntentHandling {

    private let storage = Storage<INTask>(groupIdentifier: "group.com.alexruperez.Tasks", path: "Tasks")

    // MARK: - Add Tasks Intent Handling

    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        guard let taskTitles = intent.taskTitles else {
            completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
            return
        }
        let currentDateComponents = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: Date())
        let tasks = taskTitles.flatMap({
            return INTask(title: $0, status: .notCompleted, taskType: .completable, spatialEventTrigger: intent.spatialEventTrigger, temporalEventTrigger: intent.temporalEventTrigger, createdDateComponents: currentDateComponents, modifiedDateComponents: currentDateComponents, identifier: UUID().uuidString)
        })
        let userActivity = NSUserActivity(activityType: String(describing: INAddTasksIntent.self))
        userActivity.requiredUserInfoKeys = Set(arrayLiteral: "tasks")
        userActivity.userInfo = ["tasks": tasks.flatMap({ $0.identifier })]
        guard storage.save(tasks) else {
            completion(INAddTasksIntentResponse(code: .failure, userActivity: userActivity))
            return
        }
        let response = INAddTasksIntentResponse(code: .success, userActivity: userActivity)
        response.addedTasks = tasks
        completion(response)
    }

}
