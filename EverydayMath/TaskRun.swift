//
//  TaskRun.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 09.11.15.
//  Copyright © 2015 Petr Zvonicek. All rights reserved.
//

import Foundation

// MARK: TaskRun protocols
protocol TaskRunDelegate {
    func taskRun(taskRun: TaskRun, showQuestion question: Question, index: Int)
    func taskRun(taskRun: TaskRun, questionCompleted question: Question, index: Int, result: QuestionResult)
    func taskRun(taskRun: TaskRun, questionGaveSecondTry question: Question, index: Int)
    func taskRunCompleted(taskRun: TaskRun)
    func taskRunAborted(taskRun: TaskRun)
}

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
        switch self {
        case .Result(0.5...1, _, _, _):
            return ("a", "b")
        case .Result(0, _, _, _):
            return ("Congratulations!", "You've successfully completed all questions")
        default:
            return ("Well done", "You're on the right track")
        }
    }
}

class TaskRun: QuestionDelegate {
    let task: Task
    let config: TaskConfiguration
    let questions: [Question]
    let log: TaskRunLog
    
    var currentQuestionIndex: Int?
    var currentQuestionPresentationDate: NSDate?
    var currentQuestionSecondTry = false
    
    var delegate: TaskRunDelegate?
    
    var running = false
    var finished = false {
        didSet(value) {
            if value {
                running = false
            }
        }
    }
    
    init(task: Task, config: TaskConfiguration) {
        self.task = task
        self.config = config
        self.questions = config.questions.flatMap(QuestionFactory.questionForConfiguration)
        self.log = TaskRunLog(taskRunId: config.taskRunId)
    }
    
    func start() {
        running = true
        nextQuestion()
    }
    
    func pause() {
        running = false
    }
    
    func resume() {
        running = true
    }
    
    func abort() {
        abortTaskRun()
    }
    
    func nextQuestion() {
        let index = currentQuestionIndex != nil ? currentQuestionIndex! + 1 : 0
        
        if var nextQuestion = questions[safe: index] {
            nextQuestion.delegate = self
            delegate?.taskRun(self, showQuestion: nextQuestion, index: index)
            currentQuestionIndex = index
            currentQuestionPresentationDate = NSDate()
            currentQuestionSecondTry = false
        } else {
            finishTaskRun()
        }
    }
    
    private func abortTaskRun() {
        finished = true
        delegate?.taskRunAborted(self)
        
        self.log.aborted = true
        APIClient.uploadTaskRunLog(self.log)
    }
    
    private func finishTaskRun() {
        finished = true
        delegate?.taskRunCompleted(self)
        
        self.log.aborted = false
        APIClient.uploadTaskRunLog(self.log)
    }
    
    // MARK: TaskDelegate
    
    func questionCompleted(question: Question, correct: Bool, accuracy: QuestionResultAccuracy?, answer: [String: AnyObject]) {
        guard let index = questions.indexOf(question) else {
            assertionFailure("task was not found")
            return
        }
        
        guard let currentQuestionPresentationDate = currentQuestionPresentationDate else {
            assertionFailure("task presentation date not found")
            return
        }
        
        let timeSpend = NSDate().timeIntervalSinceDate(currentQuestionPresentationDate)
        
        var result: QuestionResult
        if let accuracy = accuracy where correct {
            var speed: QuestionResultSpeed
            switch timeSpend {
            case 0...question.config().fastTime:
                speed = .Fast
            default:
                speed = .Slow
            }
            
            result = QuestionResult.Correct(accuracy, speed)
        } else {
            result = QuestionResult.Incorrect
        }
        
        let taskLog = QuestionRunLog(questionId: question.config().questionId, result: result, time: timeSpend, hintShown: currentQuestionSecondTry, answer: answer)
        log.appendQuestionLog(taskLog)

        delegate?.taskRun(self, questionCompleted: question, index: index, result: result)
    }
    
    func questionGaveSecondTry(question: Question) {
        guard let index = questions.indexOf(question) else {
            assertionFailure("task was not found")
            return
        }
        
        currentQuestionSecondTry = true
        delegate?.taskRun(self, questionGaveSecondTry: question, index: index)
    }
}