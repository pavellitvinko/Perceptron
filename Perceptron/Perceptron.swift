//
//  Perceptron.swift
//  Perceptron
//
//  Created by Pavel Litvinko on 26.10.14.
//  Copyright (c) 2014 Pavel Litvinko. All rights reserved.
//

import Cocoa

typealias Vector = [Double]

class Perceptron {
    private var classesCount = 0
    var weights: [Vector]
    private var trainingSample: [[Vector]]
    private var correctionCoeff = 1.0
    
    init(classesCount: Int, attributesCount: Int){
        self.classesCount = classesCount
        
        let zeroVector = Vector(count: attributesCount, repeatedValue: 0.0)
        weights = [Vector](count: classesCount, repeatedValue: zeroVector)
        trainingSample = [[Vector]](count: classesCount, repeatedValue: [])
    }
    
    func addTrainingSample(#classIndex: Int, sample: Vector){
       trainingSample[classIndex].append(sample)
    }
    
    func train(retrainIterationNum: Int = 0, maxRetrainCycles: Int = 2) -> Bool{
        var correctionApplied = false
        
        for classIndex in 0..<trainingSample.count {
            for vector in trainingSample[classIndex]{
                
                var response: [Double] = []
                
                for i in 0..<classesCount {
                    response.append(multiplyVectors(weights[i], vector)!)
                }
                
                if needCorrection(response, sample: vector, sampleClassIndex: classIndex) {
                    correctWeights(response, sample: vector, sampleClassIndex: classIndex)
                    correctionApplied = true
                }
            }
        }
        
        if correctionApplied {
            // Training is not completed, need to retrain with same samples
            if retrainIterationNum < maxRetrainCycles{
                return train(retrainIterationNum: retrainIterationNum + 1, maxRetrainCycles: maxRetrainCycles)
            } else
            {
                return false
            }
        } else {
            return true
        }
    }
    
    func classify(var vector: Vector) -> Int? {
        vector.append(1)
        if classesCount > 0 {
            var response: [Double] = []
            for i in 0..<classesCount {
                if let res = multiplyVectors(weights[i], vector) {
                    response.append(res)
                } else {
                    return nil
                }
            }
            var maxIndex = 0
            var max = response[0]
            for i in 0..<response.count {
                if response[i] > max {
                    maxIndex = i
                    max = response[i]
                }
            }
            return maxIndex
        } else {
            return nil
        }
    }
    
    private func needCorrection(response: [Double], sample: Vector, sampleClassIndex: Int) -> Bool {
        for i in 0..<response.count {
            if (i != sampleClassIndex) && (response[i] >= response[sampleClassIndex]) {
                return true
            }
        }
        return false
    }
    
    private func correctWeights(response: [Double], sample: Vector, sampleClassIndex: Int) {
        
        for i in 0..<weights.count {
            var coeff: Double
            
            if i == sampleClassIndex {
                coeff = correctionCoeff
            } else {
                coeff = -1 * correctionCoeff
            }
            
            weights[i] = sumVectors(weights[i], sample, withCoefficient: coeff)!
        }
    }
    
    private func sumVectors(a: Vector, _ b: Vector, withCoefficient coeff: Double = 1) -> Vector? {
        if a.count != b.count{
            return nil
        }
        var resultVector = Vector()
        
        for i in 0..<a.count {
            resultVector.append(a[i] + coeff*b[i])
        }
        return resultVector
    }
    
    private func multiplyVectors(a: Vector, _ b: Vector) -> Double? {
        if a.count != b.count{
            return nil
        }
        var sum = 0.0
        for i in 0..<a.count {
            sum += a[i] * b[i]
        }
        return sum
    }
}

func StringToVector(s: String) -> Vector {
    let values = s.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ", ."))
    var vector = Vector()
    for val in values {
        vector.append((val as NSString).doubleValue)
    }
    return vector
}
