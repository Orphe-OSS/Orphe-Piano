//
//  DoubleCircle.swift
//  OrpheSynth
//
//  Created by kyosuke on 2017/02/09.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import C4

class CustomCircle:Shape{
    var firstDiameter:Double = 0
    var preDiameter:Double = 0
    var vibrateTimer: Foundation.Timer?
    var initPoint = Point(0,0)
    
    var centerXAverage = averageCalculator(elementCount:10)
    var centerYAverage = averageCalculator(elementCount:10)
    
    public override init(frame: Rect) {
        super.init()
        view.frame = CGRect(frame)
        
        let newPath = Path()
        newPath.addEllipse(bounds)
        path = newPath
    }
    
    convenience public init(center: Point, radius: Double) {
        let frame = Rect(center.x-radius, center.y-radius, radius * 2, radius * 2)
        self.init(frame: frame)
        self.initPoint = center
        preDiameter = radius*2
        firstDiameter = preDiameter
        self.shadow.radius = 10
        self.shadow.opacity = 0.2
    }
    
    func updateDiameter(_ diameter:Double){
        let scale = diameter/preDiameter
        self.transform.scale(scale, scale)
        preDiameter = diameter
    }
    
    func updateCenterX(_ x:Double){
        centerXAverage.update(value: x)
        self.center.x = centerXAverage.result
    }
    
    func updateCenterY(_ y:Double){
        centerYAverage.update(value: y)
        self.center.y = centerYAverage.result
    }
    
    var vibrateCounter:Double = 1
    var isVibrating = false
    func vibrateShape(duration:Double, amplitude:Double, cycleDuration:Double = 0.1){
        
        if !isVibrating{
            let d = firstDiameter
            let counterMax:Double = duration/(cycleDuration*2)
            vibrateCounter = 1
            let fanim = ViewAnimation(duration: cycleDuration){
                self.updateDiameter(d-amplitude*(1-(self.vibrateCounter/counterMax)))
            }
            let banim = ViewAnimation(duration: cycleDuration){
                self.updateDiameter(d)
            }
            fanim.addCompletionObserver {
                banim.animate()
            }
            banim.addCompletionObserver {
                self.vibrateCounter += 1
                if self.vibrateCounter < counterMax{
                    fanim.animate()
                }
                else{
                    self.isVibrating = false
                }
            }
            
            fanim.animate()
        }
    }
    
    func startFade(duration:Double){
        let fadeAnim = ViewAnimation(duration: duration){
            self.fillColor = clear
            self.strokeColor = clear
            self.transform.scale(0.8, 0.8)
        }
        fadeAnim.addCompletionObserver {
            self.removeFromSuperview()
        }
        fadeAnim.animate()
    }
}

class averageCalculator{
    var array = [Double]()
    var result:Double = 0
    var elementCount = 1
    
    init(elementCount:Int) {
        self.elementCount = elementCount
    }
    
    func update(value:Double){
        array.append(value)
        if array.count > elementCount{
            array.remove(at: 0)
        }
        result = calcAverage(array: array)
    }
    
    func calcAverage(array: [Double])->Double{
        var sum = 0.0
        for val in array{
            sum += val
        }
        return sum / Double(array.count)
    }
}
