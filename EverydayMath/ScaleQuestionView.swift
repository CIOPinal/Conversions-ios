//
//  ScaleQuestionView.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 07.12.15.
//  Copyright © 2015 Petr Zvonicek. All rights reserved.
//

import UIKit

class ScaleQuestionView: UIView, TrackingScaleControlDelegate {
    
    var delegate: QuestionDelegate?
    var question: ScaleQuestion! {
        didSet {
            self.taskLabel.text = question.configuration.question
            self.toUnitLabel.text = question.configuration.toUnit
            
            self.scaleControl.minValue = CGFloat(question.configuration.scaleMin)
            self.scaleControl.maxValue = CGFloat(question.configuration.scaleMax)
            self.scaleControl.correctValue = CGFloat(question.configuration.correctValue)
            self.scaleControl.correctTolerance = CGFloat(question.configuration.correctTolerance)
        }
    }
    
    @IBOutlet var taskLabel: UILabel!
    @IBOutlet var scaleControl: TrackingScaleControl!
    @IBOutlet var toUnitLabel: UILabel!
    @IBOutlet var resultView: UIView!
    @IBOutlet var resultNumberLabel: UILabel!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
        scaleControl.delegate = self
        resultView.alpha = 0.0
    }
    
    // MARK: TrackingScaleControlDelegate
    
    func scaleControlDidAnswer(value: CGFloat) {
        let isCorrect = Float(value) > question.configuration.correctValue - question.configuration.correctTolerance && Float(value) < question.configuration.correctValue + question.configuration.correctTolerance
        
        if  isCorrect {
            resultNumberLabel.backgroundColor = UIColor.correctColor()
        } else {
            resultNumberLabel.backgroundColor = UIColor.errorColor()
        }
        resultNumberLabel.text = String(format: "%.2f", question.configuration.correctValue)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.resultView.alpha = 1.0
        }) { (let finished) -> Void in
            self.delegate?.questionCompleted(self.question, correct: isCorrect, answer: ["number": String(value)])
        }
    }
}
