//
//  TaskRunResult.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 18.03.16.
//  Copyright © 2016 Petr Zvonicek. All rights reserved.
//

import Foundation

typealias taskCompletedMessage = (title: String, subtitle: String)
enum TaskRunResult {
    case Result(incorrectRatio: Float, slowRatio: Float, impreciseRatio: Float, preciseRatio: Float)
    
    static func createFromRunLog(runLog: [QuestionRunLog]) -> TaskRunResult {
        let correctQuestions = runLog.filter { $0.result.correct() }
        
        let incorrectRatio = 1 - (Float(correctQuestions.count) / Float(runLog.count))
        let slowRatio = Float(correctQuestions.filter { if case .Correct(_, .Slow) = $0.result { return true } else { return false }}.count) / Float(correctQuestions.count)
        let impreciseRatio = Float(correctQuestions.filter { if case .Correct(.Imprecise, _) = $0.result { return true } else { return false }}.count) / Float(correctQuestions.count)
        let preciseRatio = Float(correctQuestions.filter { if case .Correct(.Precise, _) = $0.result { return true } else { return false }}.count) / Float(correctQuestions.count)
        
        return .Result(incorrectRatio: incorrectRatio, slowRatio: slowRatio, impreciseRatio: impreciseRatio, preciseRatio: preciseRatio)
    }
    
    func message() -> taskCompletedMessage {
        print(self)
        
        switch self {
        case .Result(_, 0...0.5, 0.5...1, _):
            return ("Fast, but unprecise", "Great speed, try to work on your precision")
        case .Result(0...0.3, 0...0.3, _, _):
            return ("Perfect", "Great speed and corectness")
        case .Result(0.1...0.4, _, _, _):
            return ("Good job", "You did well")
        case .Result(0.7...1, _, _, _):
            return ("Don't give up", "Try it again")
        case .Result(0, _, _, _):
            return ("Congratulations!", "You've successfully completed all questions")
        default:
            return ("Well done", "You're on the right track")
        }
    }
}