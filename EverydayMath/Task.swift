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
    case Mass, Length, Area, Volume, Currency
    
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
        }
    }
}

class Task {
    var identifier: String
    var name: String
    var image: UIImage
    var category: TaskCategory
    var taskConfiguration: TaskConfiguration?

    init(identifier: String, name: String, category: TaskCategory, image: UIImage) {
        self.identifier = identifier
        self.name = name
        self.category = category
        self.image = image
    }

    func run(configuration: TaskConfiguration) throws -> TaskRun {
        return DefaultTaskRun(task: self, config: configuration)
    }
}


class TaskFactory {
    static let tasks: [Task] = [
        Task(identifier: "mass_i", name: "Imperial", category: .Mass, image: UIImage(named: "ic_mass")!),
        Task(identifier: "mass_m", name: "Metric", category: .Mass, image: UIImage(named: "ic_mass")!),
        Task(identifier: "mass_mi", name: "Combined", category: .Mass, image: UIImage(named: "ic_mass")!),
        
        Task(identifier: "length_i", name: "Imperial", category: .Length, image: UIImage(named: "ic_length")!),
        Task(identifier: "length_m", name: "Metric", category: .Length, image: UIImage(named: "ic_length")!),
        Task(identifier: "length_mi", name: "Combined", category: .Length, image: UIImage(named: "ic_length")!),
        
        Task(identifier: "area_i", name: "Imperial", category: .Area, image: UIImage(named: "ic_area")!),
        Task(identifier: "area_m", name: "Metric", category: .Area, image: UIImage(named: "ic_area")!),
        Task(identifier: "area_mi", name: "Combined", category: .Area, image: UIImage(named: "ic_area")!),
    ]
    static var tasksByCategory: [TaskCategory: [Task]] = {
        return  TaskFactory.tasks.reduce([:]) { (var dict, var task: Task) -> Dictionary<TaskCategory, Array<Task>> in
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
        return TaskFactory.tasks.reduce([], combine: { (var arr: [TaskCategory], var task: Task) -> [TaskCategory] in
            if !arr.contains(task.category) {
                arr.append(task.category)
            }
            
            return arr
        })
    }()
    
    init() {
    }
}