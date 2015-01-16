//
//  ViewController.swift
//  Perceptron
//
//  Created by Pavel Litvinko on 26.10.14.
//  Copyright (c) 2014 Pavel Litvinko. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var samplesView: NSTextView!
    @IBOutlet weak var sampleVectorField: NSTextField!
    @IBOutlet weak var testVectorField: NSTextField!
    

    @IBOutlet var perseptronWidthsField: NSTextView!
    @IBOutlet weak var statusMessage: NSTextField!
    @IBOutlet weak var classificationResult: NSTextField!

    var attributesCount: Int = 0
    var classesCount: Int = 0
    var samplesPerClass: Int = 0
    var maxCyclesCount: Int = 2

    var sampleClass: Int = 0
    var perceptron: Perceptron?
    var trainingSamples: [[Vector]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func Train(sender: AnyObject) {
        perceptron = Perceptron(classesCount: classesCount, attributesCount: attributesCount+1)
        
        for i in 0..<trainingSamples.count {
            for vector in trainingSamples[i]{
                perceptron!.addTrainingSample(classIndex: i, sample: vector)
            }
        }
        
        if perceptron!.train(retrainIterationNum: 0, maxRetrainCycles: maxCyclesCount) {
            statusMessage.stringValue = "Perceptron trained successfully!"
        } else {
            statusMessage.stringValue = "Unable to train Perceptron! Bad data?"
        }
        
        displayPerseptronWeights()
    }

    @IBAction func generateTrainingSamples(sender: AnyObject) {
        trainingSamples.removeAll(keepCapacity: false)
        
        for i in 0..<classesCount {
            trainingSamples.append([])
            for j in 0..<samplesPerClass {
                var vector = Vector()
                for k in 0..<attributesCount {
                    vector.append(Double(random(lower: -10, upper: 10)))
                }
                vector.append(1)
                trainingSamples[i].append(vector)
            }
        }
       
        displayTrainingSamples()
    }
    
    @IBAction func addTrainingVector(sender: AnyObject) {
        if (sampleClass < 1) || (sampleClass-1 > classesCount) {
            statusMessage.stringValue = "Invalid class!"
            return
        }
        var vector = StringToVector(sampleVectorField.stringValue)
        vector.append(1)
        while trainingSamples.count < classesCount {
            trainingSamples.append([])
        }
        trainingSamples[sampleClass - 1].append(vector)
        displayTrainingSamples()
    }
    
    @IBAction func classify(sender: AnyObject) {
        let vector = StringToVector(testVectorField.stringValue)
        if let classIndex = perceptron?.classify(vector) {
            classificationResult.stringValue = "Vector belongs to \(classIndex+1) class"
        } else {
            classificationResult.stringValue = "Unable to classify!"
        }
    }

    func displayPerseptronWeights() {
        var s = ""
        for i in 0..<perceptron!.weights.count {
            let vector = perceptron!.weights[i]
            s += "d(\(i+1)) ☞ "
            for j in 0..<vector.count {
                s += "\(vector[j]) "
            }
            s += "\n"
        }
        perseptronWidthsField.string = s
    }
    func displayTrainingSamples() {
        var s = ""
        for i in 0..<trainingSamples.count {
            s += "\(i+1) class:\n"
            for vector in trainingSamples[i] {
                s += "("
                for j in vector {
                    s += "\(j) "
                }
                s += ")\n"
            }
        }
        samplesView.string = s
    }
    
    func random(#lower: Int32, upper: Int32) -> Int32 {
        let r = arc4random_uniform(UInt32(Int64(upper) - Int64(lower)))
        return Int32(Int64(r) + Int64(lower))
    }
    
}

