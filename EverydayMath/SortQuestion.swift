//
//  SortQuestion.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 20.12.15.
//  Copyright © 2015 Petr Zvonicek. All rights reserved.
//

import UIKit
import Unbox

class SortQuestion: Question {
    var delegate: QuestionDelegate?
    let configuration: SortQuestionConfiguration
    let properties: QuestionProperties = QuestionProperties(questionId: "E", fastTime: 5, neutralTime: 10)
    
    init(config: SortQuestionConfiguration) {
        configuration = config
    }
    
    func getView() -> UIView {
        let view = SortQuestionView.loadFromNibNamed("SortQuestionView") as! SortQuestionView
        view.question = self
        view.delegate = self.delegate
        return view
    }

    func identifier() -> String {
        return String(ObjectIdentifier(self).uintValue)
    }    
}

struct SortQuestionConfiguration: QuestionConfiguration {
    let question: String
    let topDescription: String
    let bottomDescription: String
    let answers: [SortQuestionItem]
    
    init(unboxer: Unboxer) {
        question = unboxer.unbox("question")
        topDescription = unboxer.unbox("topDescription")
        bottomDescription = unboxer.unbox("bottomDescription")
        answers = unboxer.unbox("answers")
    }
    
    func presentedAnswers() -> [SortQuestionItem] {
        return answers.sort({ $0.presentedPosition < $1.presentedPosition })
    }
    
    func correctAnswers() -> [SortQuestionItem] {
        return answers.sort({ $0.correctPosition < $1.correctPosition })
    }
}

struct SortQuestionItem: Unboxable {
    let title: String
    let correctPosition: Int
    let presentedPosition: Int
    let errorExplanation: String?
    
    init(unboxer: Unboxer) {
        title = unboxer.unbox("title")
        correctPosition = unboxer.unbox("correctPosition")
        presentedPosition = unboxer.unbox("presentedPosition")
        errorExplanation = unboxer.unbox("errorExplanation")
    }
}

extension SortQuestionItem: Equatable {}

func ==(lhs: SortQuestionItem, rhs: SortQuestionItem) -> Bool {
    return lhs.title == rhs.title
}
