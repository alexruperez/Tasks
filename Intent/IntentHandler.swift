//
//  IntentHandler.swift
//  Intent
//
//  Created by Alejandro Ruperez Hernando on 8/2/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INAddTasksIntentHandling {

    // MARK: - INAddTasksIntentHandling

    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
    }

}
