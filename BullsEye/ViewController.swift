//
//  ViewController.swift
//  BullsEye
//
//  Created by David Park on 5/19/16.
//  Copyright © 2016 David Park. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    var currentValueTop = 0
    var currentValueBot = 0
    var targetValue = 0
    var score = 0
    var round = 0
    var upperLeft = 0
    var upperRight = 0
    var lowerLeft = 0
    var lowerRight = 0
    
    var operation: String = ""
    var indexValue = 0
    var operationValue = 0
    //let operatorArray:[(Int,Int)->Int] = [(+), (-), (*), (/)]
    //let operators: [String:(Int,Int) ->Int] = ["plus": (+), "minus": (-), "divide": (/), "multiply": (*)]
    
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var sliderLower: UISlider!
    
    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var operationLabel: UILabel!
    
    @IBOutlet weak var upperLeftLabel: UILabel!
    
    @IBOutlet weak var upperRightLabel: UILabel!
    
    @IBOutlet weak var lowerLeftLabel: UILabel!
    
    @IBOutlet weak var lowerRightLabel: UILabel!
    
    @IBOutlet weak var targetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //operationChooser()
        startNewGame()
        updateLabels()
        
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, forState: .Normal)
        sliderLower.setThumbImage(thumbImageNormal, forState: .Normal)
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, forState: .Highlighted)
        sliderLower.setThumbImage(thumbImageHighlighted, forState: .Highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft"){
            let trackLeftResizable = trackLeftImage.resizableImageWithCapInsets(insets)
            slider.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
            sliderLower.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
        }
        if let trackRightImage = UIImage(named: "SliderTrackRight"){
            let trackRightResizable = trackRightImage.resizableImageWithCapInsets(insets)
            slider.setMaximumTrackImage(trackRightResizable, forState: .Normal)
            sliderLower.setMaximumTrackImage(trackRightResizable, forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNewRound(){
        round += 1
        operationChooser()
        
        upperLeft = 1 + Int(arc4random_uniform(50))
        upperRight = 50 + Int(arc4random_uniform(51))
        lowerLeft = 1 + Int(arc4random_uniform(50))
        lowerRight = 50 + Int(arc4random_uniform(51))
        
        slider!.minimumValue = Float(upperLeft)
        slider!.maximumValue = Float(upperRight)
        sliderLower!.minimumValue = Float(lowerLeft)
        sliderLower!.maximumValue = Float(lowerRight)
        
        var lowerbound = 0
        var upperbound = 0
        
        if indexValue == 0{                                             // add
            lowerbound = upperLeft + lowerLeft
            upperbound = upperRight + lowerRight
        } else if indexValue == 1{                                      // subtract
            lowerbound = 0                                         //lowerbound set to 0 to avoid neg target
            upperbound = upperRight - lowerLeft
        } else if indexValue == 2{                                      // multiply
            lowerbound = upperLeft * lowerLeft
            upperbound = upperRight * lowerRight
        } else{                                                         // divide
            lowerbound = 1                                         //lowerbound is a fraction rounded up to 1
            upperbound = upperRight / lowerLeft
        }
        let upperboundUInt = UInt32(upperbound)
        let lowerboundUInt = UInt32(lowerbound)
        targetValue = lowerbound + Int(arc4random_uniform(upperboundUInt - lowerboundUInt) + 1)
        
        currentValueTop = (upperLeft + upperRight)/2
        currentValueBot = (lowerLeft + lowerRight)/2
        slider.value = Float(currentValueTop)
        sliderLower.value = Float(currentValueBot)
        
        updateLabels()
    }
    
    func updateLabels(){
        targetLabel.text = String(targetValue)
        scoreLabel.text = String(score)
        roundLabel.text = String(round)
        upperLeftLabel.text = String(upperLeft)
        upperRightLabel.text = String(upperRight)
        lowerLeftLabel.text = String(lowerLeft)
        lowerRightLabel.text = String(lowerRight)
        operationLabel.text = operation
    }
    
    func startNewGame(){
        score = 0
        round = 0
        startNewRound()
    }
    
    @IBAction func startOver(){
        startNewGame()
        updateLabels()
        
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        view.layer.addAnimation(transition, forKey: nil)
    }
    
    func operationChooser(){
        indexValue = Int(arc4random_uniform(3))
        
        switch indexValue {
        case 0: operation = "+"
        case 1: operation = "-"
        case 2: operation = "*"
        default: operation = "/"
        }
    }
    
    @IBAction func showAlert(){
        switch indexValue {
        case 0: operationValue = currentValueTop + currentValueBot
        case 1: operationValue = currentValueTop - currentValueBot
        case 2: operationValue = currentValueTop * currentValueBot
        default: operationValue = currentValueTop / currentValueBot
        }
    
        let difference = abs(targetValue - operationValue)
        var points = 0
        
        let title: String
        if difference == 0{
            title = "Perfect!"
            points += 500
            
        } else if difference < 5{
            title = "You almost had it!!"
            points += 150
        } else if difference < 10{
            title = "Pretty good!"
            points += 100
        } else if difference < 50{
            title = "Kindof but not really"
            points += 50
        } else if difference < 100{
            title = "In the general ballpark"
            points += 25
        }
        else{
            title = "Not even close..."
        }
        
        score += points
        
        let message = "You scored \(points) points"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle:  .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.startNewRound()
            self.updateLabels()})
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderMoved(slider: UISlider){
        currentValueTop = lroundf(slider.value)
        currentValueBot = lroundf(slider.value)
    }
}

