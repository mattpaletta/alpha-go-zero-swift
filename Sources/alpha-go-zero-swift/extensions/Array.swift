//
//  Array.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

public extension Array where Element: Numeric {
    static func *(left: [Int], right: Double) -> [Double] { // 1
        return left.map({ item in
            return Double(item * right)
        })
    }
    
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
    
    static func to_square<T>(array: [T]) -> [[T]] {
        var matrix: [[T]] = []
        let size = Int(sqrt(Double(array.count)))
        
        for i in 0 ..< size {
            for j in 0 ..< size {
                matrix[i][j] = array[i * j]
            }
        }
        
        return matrix
    }
    
    static func rotate<T>(matrix: [[T]]) -> [[T]] {
        var matrix_copy = matrix
        let size = matrix.count
        let layer_count = size / 2
    
        for layer in 0 ..< layer_count {
            let first = layer
            let last = size - first - 1
    
            for element in first ..< last {
                let offset = element - first
    
                let top = matrix_copy[first][element]
                let right_side = matrix_copy[element][last]
                let bottom = matrix_copy[last][last-offset]
                let left_side = matrix_copy[last-offset][first]
    
                matrix_copy[first][element] = left_side
                matrix_copy[element][last] = top
                matrix_copy[last][last-offset] = right_side
                matrix_copy[last-offset][first] = bottom
            }
        }
        return matrix_copy
    }

    
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
