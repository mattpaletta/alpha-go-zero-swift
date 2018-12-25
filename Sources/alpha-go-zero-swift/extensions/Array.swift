//
//  Array.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

public extension Array where Element: Numeric {
    static func *(left: [Int], right: Double) -> [Double] { // 1
        return left.map { item in
            return Double(item) * right
        }
    }
    
    static func *(left: [Element], right: Element) -> [Element] { // 1
        return left.map({ item in
            return item * right
        })
    }
    
    static func +(left: [Element], right: Element) -> [Element] { // 1
        return left.map({ item in
            return item + right
        })
    }
    
    static func *(left: [[Element]], right: Element) -> [[Element]] { // 1
        return left.map({ (row: [Element]) -> [Element] in
            return row.map({ item in
                return item * right
            })
        })
    }
    
    static func to_square(_ array: [Double]) -> [[Double]] {
        var matrix: [[Double]] = []
        let size = Int(sqrt(Double(array.count)))
        
        for i in 0 ..< size {
            for j in 0 ..< size {
                matrix[i][j] = array[i * j]
            }
        }
        
        return matrix
    }
    
    static func mask(_ left: [Element], mask: [Int]) -> [Element] {
        return zip(left, mask).map { item, valid in
            if valid == 1 {
                return item
            } else {
                return 0
            }
        }
    }
}

public func pow(_ left: [Double], _ right: Double) -> [Double] {
    return left.map { item in
        return Foundation.pow(item, right)
    }
}

public func pow(_ left: [[Double]], _ right: Double) -> [[Double]] {
    return left.map { row in
        return row.map({ item in
            return Foundation.pow(item, right)
        })
    }
}

public extension Array where Element: Comparable {
    func argmax() -> Int {
        guard !self.isEmpty else {
            return 0
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
        }).first!
    }
}

public func fliplr<T>(_ array: [[T]]) -> [[T]] {
    var arr: [[T]] = []

    for j in 0 ..< array.count {
        var tmp: [T] = []

        // Add the second half
        for i in 0 ..< (array[j].count / 2) {
            tmp.append(array[j][array[j].count - i - 1])
        }
        
        // Add the first half
        for i in (array[j].count / 2) + 1 ..< array[j].count {
            tmp.append(array[i][j])
        }
        arr.append(tmp)
    }
    
    return arr
}

public func flatten<T>(_ array: [[T]]) -> [T] {
    var output: [T] = []
    for row in array {
        for item in row {
            output.append(item)
        }
    }
    
    return output
}

public func rotate<T>(_ array: [[T]], _ num: Int) -> [[T]] {
    func aux(_ matrix: [[T]]) -> [[T]] {
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

    if num >= 2 {
        return rotate(aux(array), num - 1)
    } else {
        return aux(array)
    }
}

public extension Array {
    public func pmap<T>(transformer: @escaping (Element) -> T) -> [T] {
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
