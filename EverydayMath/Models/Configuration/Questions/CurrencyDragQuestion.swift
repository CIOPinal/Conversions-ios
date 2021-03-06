//
//  CurrencyDragQuestion.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 10.01.16.
//  Copyright © 2016 Petr Zvonicek. All rights reserved.
//

import Foundation
import Unbox

/// Currency Drag question initialized with a specific conifugration
class CurrencyDragQuestion: Question {
    var delegate: QuestionDelegate?
    let configuration: CurrencyDragQuestionConfiguration
    
    init(config: CurrencyDragQuestionConfiguration) {
        configuration = config
    }
    
    func config() -> QuestionConfiguration {
        return configuration
    }
    
    func getView() -> UIView {
        let view = SortQuestionView.loadFromNibNamed("CurrencyDragQuestionView") as! CurrencyDragQuestionView
        view.question = self
        view.delegate = self.delegate
        return view
    }
    
    /**
     Verifies if the given answer is considered as correct (including tolerance interval)
     
     - parameter value: answer to be verified
     
     - returns: true if answer is correct, else false
     */    
    func verifyResult(notesSum: Float) -> Bool {
        return (abs(notesSum - self.configuration.toValue) < self.configuration.tolerance)
    }
    
    /**
     Checks if the given answer is considered as precise
     
     - parameter value: answer to be checked
     
     - returns: true if answer is precise, else false
     */    
    func isPrecise(notesSum: Float) -> Bool {
        return (abs(notesSum - self.configuration.toValue) < self.configuration.tolerance / 2)
    }
    
    func answerLogForAnswer(answer: Float, notes: [String]) -> AnswerLog {
        return ["answer": answer, "notes": notes, "correctAnswer": configuration.toValue, "tolerance": configuration.tolerance]
    }
    
    func identifier() -> String {
        return String(ObjectIdentifier(self).uintValue)
    }
}

/// Configuration of a note of a closed ended question
struct CurrencyDragQuestionConfigurationNote: Unboxable {
    let value: Float
    let currency: String
    var count: Int = 0
    
    init(unboxer: Unboxer) {
        value = unboxer.unbox("value")
        currency = unboxer.unbox("currency")
        if unboxer.dictionary.indexForKey("count") != nil {
            count = unboxer.unbox("count")
        }
    }
}

/// Configuration of the currency drag question
class CurrencyDragQuestionConfiguration: QuestionConfiguration, SimpleResultConfiguration, HintQuestionConfiguration {
    let fromValue: Float
    let fromCurrency: String
    let toValue: Float
    let toCurrency: String
    let tolerance: Float
    let correctNotes: [CurrencyDragQuestionConfigurationNote]
    let availableNotes: [CurrencyDragQuestionConfigurationNote]
    let hint: HintConfiguration?
    
    required init(unboxer: Unboxer) {
        fromValue = unboxer.unbox("fromValue")
        fromCurrency = unboxer.unbox("fromCurrency")
        toValue = unboxer.unbox("toValue")
        toCurrency = unboxer.unbox("toCurrency")
        tolerance = unboxer.unbox("tolerance")
        correctNotes = unboxer.unbox("correctNotes")
        availableNotes = unboxer.unbox("availableNotes")
        hint = unboxer.unbox("hint")
        
        super.init(unboxer: unboxer)        
    }
    
    func to() -> SimpleResult {
        return (nil, String(format: "%@ %@", NSNumberFormatter.formatter.stringFromNumber(toValue)!, toCurrency))
    }
}