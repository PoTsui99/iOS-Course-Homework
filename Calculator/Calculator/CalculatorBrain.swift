//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Administrator on 2020/10/4.
//  Copyright © 2020 tsuipo. All rights reserved.
//

import Foundation

struct CalculatorBrain{
    
    private struct PendingBinaryOperation{
    let firstOperand : Double
    let function : ((Double,Double) -> Double)
    func perform(with secondOperand : Double) -> Double{
                return function(firstOperand,secondOperand)
            }
    }
    
    private var accumulator : Double? // 可选类型
    mutating public func setAcc(x : Double){
        accumulator = x
    }
    // 为二元运算的结构体类型
    private var pbo : PendingBinaryOperation?

    mutating func setOperand(_ operand : Double){
        accumulator = operand
    }
    
    var result : Double?{
        get{
            return accumulator
        }
    }
    
    mutating public func setPboNil(){
        pbo = nil
    }
    
    private enum Operation {
        case Constant(Double)
        // 一元运算
        case UnaryOperation((Double) -> Double)
        // 二元运算
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    private var operations : Dictionary< String, Operation > =
    [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        // 运用了闭包表达式
        "inc" : Operation.UnaryOperation({(x : Double) -> Double in return x+1}),
        "+" : Operation.BinaryOperation(+),
        "-" : Operation.BinaryOperation(-),
        "÷" : Operation.BinaryOperation(/),
        "×" : Operation.BinaryOperation(*),
        "=" : Operation.Equals
    ]
    
    mutating func performOperaion(_ symbol : String){
        if let operation = operations[symbol] {
            switch(operation){
            case .BinaryOperation(let function):
                if accumulator != nil{
                    pbo = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                    accumulator = nil
                }
            case .Equals:
                if pbo != nil && accumulator != nil {
                    accumulator = pbo?.perform(with: accumulator!)
                    // pbo结构体重置
                    print(pbo?.firstOperand)
                    pbo = nil
                }
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                if accumulator != nil{
                    accumulator = function(accumulator!)
                }
            }
        }
    }
}
