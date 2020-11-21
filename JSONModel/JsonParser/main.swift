// JSON解码器: JSON文件 -> SWIFT的对象
// 要求支持对象(支持一级嵌套) & 数组(字符串 数值 null 对象)
//  Created by Administrator on 2020/9/24.
//  Copyright © 2020 tsuipo. All rights reserved.

import Foundation

// 基址
let baseUrlStr = "/Users/tsuipo/Desktop/iOS"
let baseUrl = URL(fileURLWithPath: baseUrlStr)
let productName = "test_nested"
let jsonName = productName + ".json"
// JSON文件位置
let jsonUrl = baseUrl.appendingPathComponent(jsonName)
// 尝试按utf8打开JSON文件
let jsonStr = try String(contentsOf: jsonUrl, encoding: .utf8)

// 分隔, 判断是不是数组
func getSplit(json: String, isArray: Bool) -> [String] {
    var realJson = json.trimmingCharacters(in: .whitespacesAndNewlines)
    if isArray {
        let chSet = CharacterSet(charactersIn: "[]")
        realJson = realJson.trimmingCharacters(in: chSet)
        realJson = realJson.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    if realJson == "" {
        return [String]()
    }
    realJson += ","
    var split = [String]()
    var curJson = ""
    var curStr = 1
    var balance = 0
    for i in 0..<realJson.count {
        let ch = realJson[realJson.index(realJson.startIndex, offsetBy: i)]
        if ch == "," && balance == 0 {
            curJson = curJson.trimmingCharacters(in: .whitespacesAndNewlines)
            if curJson == "" {
                curJson = "nil"
            }
            split.append(curJson)
            curJson = ""
            continue
        }
        curJson += String(ch)
        if ch == "{" || ch == "[" {
            balance += 1
        } else if ch == "}" || ch == "]" {
            balance -= 1
        } else if ch == "\"" {
            balance += curStr
            curStr = -curStr
        }
    }
    return split
}

//
func getPair(json: String) -> [(String, String)] {
    var realJson = json.trimmingCharacters(in: .whitespacesAndNewlines)
    let chSet = CharacterSet(charactersIn: "{}")
    realJson = realJson.trimmingCharacters(in: chSet)
    realJson = realJson.trimmingCharacters(in: .whitespacesAndNewlines)
    if realJson == "" {
        return [(String, String)]()
    }
    var pair = [(String, String)]()
    let split = getSplit(json: realJson, isArray: false)
    for eleJson in split {
        var idx = 0
        for i in 0..<eleJson.count {
            let ch = eleJson[eleJson.index(eleJson.startIndex, offsetBy: i)]
            if ch == ":" {
                idx = i
                break
            }
        }
        let key = (eleJson as NSString).substring(to: idx)
        let val = (eleJson as NSString).substring(from: idx + 2)
        var realKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let reakVal = val.trimmingCharacters(in: .whitespacesAndNewlines)
        let chSet = CharacterSet(charactersIn: "\"")
        realKey = realKey.trimmingCharacters(in: chSet)
        pair.append((realKey, reakVal))
    }
    return pair
}

func getDictKey(key: String, val: String) -> String {
    let type = getType(key: key, val: val, isTop: true)
    return key + type
}

// 初始化数组
var que = [(String, String)]()
// 初始化字典
var dict = [String: Bool]()

func getType(key: String, val: String, isTop: Bool) -> String {
    let realVal = val.trimmingCharacters(in: .whitespacesAndNewlines)
    let startCh = realVal[realVal.startIndex]
    var type = ""
    switch startCh {
    case "n", "N":
        type = "Nil"
    case "t", "T", "f", "F":
        type = "Bool"
    case "\"":
        type = "String?"
    case "[":
        let split = getSplit(json: realVal, isArray: true)
        var tmpDict = [String: Bool]()
        var firstVal: String? = nil
        for eleVal in split {
            let startEleCh = eleVal[eleVal.startIndex]
            if startEleCh == "n" || startCh == "N" {
                tmpDict["Nil"] = true
                continue
            }
            if firstVal == nil {
                firstVal = eleVal
            }
            let dictKey = getDictKey(key: key, val: eleVal)
            tmpDict[dictKey] = true
        }
        if tmpDict.isEmpty || tmpDict.count > 1 {
            type = "Any?"
        } else if tmpDict.keys.contains("Nil") {
            type = "Any?"
        } else {
            let startEleCh = firstVal![firstVal!.startIndex]
            if startEleCh == "{" {
                let dictKey = getDictKey(key: key, val: firstVal!)
                if dict.keys.contains(dictKey) == false {
                    dict[dictKey] = true
                    que.append((key, firstVal!))
                }
                type = "[" + key + "?]"
            } else {
                let eleType = getType(key: key, val: firstVal!, isTop: isTop)
                type = "[" + eleType + "?]"
            }
        }
    case "{":
        if isTop == false {
            type = key + "?"
            let dictKey = getDictKey(key: key, val: realVal)
            if dict.keys.contains(dictKey) == false {
                dict[dictKey] = true
                que.append((key, realVal))
            }
        } else {
            let pair = getPair(json: realVal)
            type = "struct " + key + ": Codable {\n"
            for (eleKey, eleVal) in pair {
                type += "\t" + eleKey + ": "
                type += getType(key: eleKey, val: eleVal, isTop: false) + "\n"
            }
            type += "}"
        }
    default:
        if realVal.contains(".") || realVal.contains("e") || realVal.contains("E") {
            type = "Float?"
        } else {
            type = "Int?"
        }
    }
    return type
}

// 直接调用
func getModel(json: String?) -> String {
    if json == nil {
        return ""
    }
    
    var model = ""
    var isFirst = true
    que.append((productName, json!))
    
    // 队列 循环
    while que.isEmpty == false {
        let (key, val) = que.first!
        que.remove(at: 0)
        if isFirst {
            isFirst = false
        } else {
            model += "\n"
        }
        model += getType(key: key, val: val, isTop: true) + "\n"
    }
    return model
}

let modelName = productName + ".swift"
let modelUrl = baseUrl.appendingPathComponent(modelName)
var modelStr = getModel(json: jsonStr)
print("SWIFT模型为:")
print(modelStr)
//let toPrint = modelStr.data(using: .utf8)
//let fileHandle = FileHandle(forWritingAtPath: baseUrlStr + "/" +  modelName)
//fileHandle.write(toPrint)
