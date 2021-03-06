//
//  Task.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 07.11.15.
//  Copyright © 2015 Petr Zvonicek. All rights reserved.
//

import Foundation

enum TaskError: ErrorType {
    case InvalidConfiguration
}

enum TaskCategory {
    case Mass, Length, Area, Volume, Currency, Temperature
    
    func description() -> String {
        switch self {
        case .Mass:
            return "Mass"
        case .Length:
            return "Length"
        case .Area:
            return "Area"
        case .Volume:
            return "Volume"
        case .Currency:
            return "Currency"
        case .Temperature:
            return "Temperature"
        }
    }
}

/// Representation of a task
class Task {
    var identifier: String
    var name: String
    var image: UIImage
    var category: TaskCategory

    init(identifier: String, name: String, category: TaskCategory, image: UIImage) {
        self.identifier = identifier
        self.name = name
        self.category = category
        self.image = image
    }

    /**
     Returns TaskRun for the task and provided configuration
     
     - parameter configuration: configuration to be run
     
     - returns: taskRun instance with for specified configuration
     */
    func run(configuration: TaskRunConfiguration) -> TaskRun {
        return TaskRun(task: self, config: configuration)
    }
}

/// Accessory class to all available tasks
class TaskFactory {
    static let tasks: [Task] = [
        //Task(identifier: "test", name: "TEST", category: .Length, image: UIImage(named: "ic_length")!),
        
        Task(identifier: "length_i", name: "Imperial", category: .Length, image: UIImage(named: "ic_length")!),
        Task(identifier: "length_m", name: "Metric", category: .Length, image: UIImage(named: "ic_length")!),
        Task(identifier: "length_c", name: "Combined", category: .Length, image: UIImage(named: "ic_length")!),
        
        Task(identifier: "mass_i", name: "Imperial", category: .Mass, image: UIImage(named: "ic_mass")!),
        Task(identifier: "mass_m", name: "Metric", category: .Mass, image: UIImage(named: "ic_mass")!),
        Task(identifier: "mass_c", name: "Combined", category: .Mass, image: UIImage(named: "ic_mass")!),
        
        Task(identifier: "area_c", name: "Combined", category: .Area, image: UIImage(named: "ic_area")!),
        
        Task(identifier: "temperature_c", name: "ºC\u{00a0}/\u{00a0}ºF", category: .Temperature, image: UIImage(named: "ic_temperature")!),

        Task(identifier: "currency_eur", name: "EUR", category: .Currency, image: UIImage(named: "ic_currency")!),
        Task(identifier: "currency_usd", name: "USD", category: .Currency, image: UIImage(named: "ic_currency")!),
        Task(identifier: "currency_czk", name: "CZK", category: .Currency, image: UIImage(named: "ic_currency")!),
    ]
    static var tasksByCategory: [TaskCategory: [Task]] = {
        return  TaskFactory.tasks.reduce([:]) { (dict, task: Task) -> Dictionary<TaskCategory, Array<Task>> in
            var dict = dict
            
            if var it = dict[task.category] {
                it.append(task)
                dict[task.category] = it
            } else {
                dict[task.category] = [task]
            }
            
            return dict
        }
    }()
    static var categories: [TaskCategory] = {
        return TaskFactory.tasks.reduce([], combine: { (arr: [TaskCategory], task: Task) -> [TaskCategory] in
            var arr = arr
            
            if !arr.contains(task.category) {
                arr.append(task.category)
            }
            
            return arr
        })
    }()
    
    init() {
    }
}