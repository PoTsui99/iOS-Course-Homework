//
//  ViewController.swift
//  Calculator
//
//  Created by Administrator on 2020/9/26.
//  Copyright © 2020 tsuipo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var brain = CalculatorBrain()
    
    @IBOutlet weak var display: UILabel!
    
    // 用户是否正在输入数字,判断是覆盖还是截断
    var userIsTyping = false
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!

        // 标志位userIsTyping去除前导的0
        if digit == "CLR"{ // 清屏
            brain.setPboNil()
            display.text = "0"
            userIsTyping = false
            return
        }
        
        
        if userIsTyping {
            
            let textInDisplay = display.text!
            display.text = textInDisplay + digit
            
        } else {
            display.text = digit
            userIsTyping = true
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {

        var displayValue : Double{
            get{
                return Double(display.text!)!
            }
            set{
                display.text = String(newValue)
            }
        }

        if userIsTyping{
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        
        if let symbol = sender.currentTitle{
            brain.performOperaion(symbol)
        }
        
        if let result = brain.result{
            displayValue = result
        }
    }
    
}

