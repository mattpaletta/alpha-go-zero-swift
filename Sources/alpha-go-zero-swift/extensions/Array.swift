//
//  Array.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

public extension Array where Element: Numeric {
    static func *(left: [Element], right: Element) -> [Element] { // 1
        return left.map({ item in
            return item * right
        })
    }
    
    static func *(left: [[Element]], right: Element) -> [[Element]] { // 1
        return left.map({ (row: [Element]) -> [Element] in
            return row.map({ item in
                return item * right
            })
        })
    }
    
    
    static func ^(left: [Element], right: Element) -> [Element] { // 1
        return left.map({ item in
            return item ^ right
        })
    }
    
    static func ^(left: [[Element]], right: Element) -> [[Element]] { // 1
        return left.map({ (row: [Element]) -> [Element] in
            return row.map({ item in
                return item ^ right
            })
        })
    }
}

public extension Array where Element: Comparable {
    
    func argmax() -> [Int] {
        guard !self.isEmpty else {
            return []
        }
        
        let m = self.max(by: { (a: Element, b: Element) -> Bool in
            return a > b
        })
        
        return self.map({ (a) -> (Element, Array.Index?) in
            return (a, self.index(of: a))
        }).filter({ (arg) -> Bool in
            let (a, _) = arg
            return a == m
        }).map({ (_, i) -> Int in
            return i!
        })
    }
}

public extension Array {
    
    func pmap<T>(transformer: @escaping (Element) -> T) -> [T] {
        var result: [Int: [T]] = [:]
        guard !self.isEmpty else {
            return []
        }
        
        let coreCount = ProcessInfo.processInfo.activeProcessorCount
        let sampleSize = Int(ceil(Double(count) / Double(coreCount)))
        
        let group = DispatchGroup()
        
        for index in 0..<sampleSize {
            
            let startIndex = index * coreCount
            let endIndex = Swift.min((startIndex + (coreCount - 1)), count - 1)
            result[startIndex] = []
            
            group.enter()
            DispatchQueue.global().async {
                for index in startIndex...endIndex {
                    result[startIndex]?.append(transformer(self[index]))
                }
                group.leave()
            }
        }
        
        group.wait()
        return result.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
    }
    
    func pfilter(filter: @escaping (Element) -> Bool) -> [Element] {
        
        var result: [Int: [Element]] = [:]
        guard !self.isEmpty else {
            return []
        }
        
        let coreCount = ProcessInfo.processInfo.activeProcessorCount
        let sampleSize = Int(ceil(Double(count) / Double(coreCount)))
        
        let group = DispatchGroup()
        
        for index in 0..<sampleSize {
            
            let startIndex = index * coreCount
            let endIndex = Swift.min((startIndex + (coreCount - 1)), count - 1)
            result[startIndex] = []
            
            group.enter()
            DispatchQueue.global().async {
                for index in startIndex...endIndex where filter(self[index]) {
                    result[startIndex]?.append(self[index])
                }
                group.leave()
            }
        }
        
        group.wait()
        return result.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 }
    }
    
    
}
