//
//  GameViewController.swift
//  EverydayMath
//
//  Created by Petr Zvoníček on 08.11.15.
//  Copyright © 2015 Petr Zvonicek. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var gameRun: GameRun?
    
    @IBOutlet var topBar: GameHeaderView!
    @IBOutlet var gameView: UIView!
    @IBOutlet var continueButtonView: UIView!
    
    var currentTaskView: UIView? {
        willSet(taskView) {
            if let taskView = taskView {
                gameView.addSubview(taskView)
                
                if let currentTaskView = currentTaskView {
                    taskView.frame = CGRectOffset(gameView.bounds, gameView.bounds.width, 0)
                    taskView.translatesAutoresizingMaskIntoConstraints = true
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        taskView.frame = self.gameView.bounds
                        currentTaskView.frame = CGRectOffset(currentTaskView.frame, -currentTaskView.frame.size.width, 0)
                    }, completion: { (val: Bool) -> Void in
                        currentTaskView.removeFromSuperview()
                    })
                } else {
                    taskView.frame = gameView.bounds
                }
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gameRun = gameRun as? TaskBased {
            topBar.progressView.components = gameRun.tasks.count
        }
        gameRun?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        if let gameRun = gameRun where !gameRun.finished {
            gameRun.start()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @IBAction func pauseGame() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func continueButtonPressed() {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.continueButtonView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, 320, 70)
        }
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.continueButtonView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), 320, 70)
        }) { (let completed) -> Void in
            self.continueButtonView.removeFromSuperview()
            
            if let gameRun = self.gameRun as? TaskBased {
                gameRun.nextTask()
            }
        }
    }
}

extension GameViewController: GameRunDelegate {
    // MARK: GameRunDelegate methods
    
    func gameRun(gameRun: protocol<GameRun, TaskBased>, showTask task: Task, index: Int) {
        currentTaskView = task.getView()        
        print("show view")
    }
    
    func gameRun(gameRun: protocol<GameRun, TaskBased>, taskCompleted task: Task, index: Int, result: TaskResult) {
        continueButtonView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), 320, 70)
        self.view.addSubview(continueButtonView)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.continueButtonView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, 320, 70)
        }) { _ -> Void in
            self.topBar.progressView.updateStateForComponent(index, state: result.progressViewState())
        }
    }
    
    func gameRunCompleted(gameRun: GameRun){
        print("game completed")
        performSegueWithIdentifier("completedSegue", sender: self)
    }
    
    func gameRunTimeouted(gameRun: GameRun){
        print("game timeouted")
        performSegueWithIdentifier("timeOutSegue", sender: self)
    }
    
    func gameRunAborted(gameRun: GameRun){
        print("game aborted")
    }

}
