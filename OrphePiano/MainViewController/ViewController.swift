//
//  ViewController.swift
//  Orphe-Instrument
//
//  Created by kyosuke on 2017/01/01.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import UIKit
import Orphe
import C4

class ViewController: CanvasController{
    
    var isFirstDisplay = true
    
    var circleRadius = 160.0
    var circles = [CustomCircle]()
    
    @IBOutlet weak var openConnectViewButton: UIButton!
    
    override func setup() {
        circleRadius = canvas.width * 0.4
        canvas.backgroundColor = Color(red: 238, green: 238, blue: 238, alpha: 1)
        let offsetX = canvas.width*0.01
        let points = [Point(canvas.width/2-offsetX, canvas.center.y), Point(canvas.width/2+offsetX, canvas.center.y)]
        
        for (i, point) in points.enumerated(){
            let circle = CustomCircle(center: point, radius: circleRadius)
            circle.fillColor = clear
            circle.lineWidth = canvas.width*0.07
            let hue = makeRotatingHue(side: ORPSide(rawValue: Int32(i))!)
            let circleStrokeColor = Color(hue:hue, saturation:1, brightness:1, alpha:0.4)
            circle.strokeColor = circleStrokeColor
            canvas.add(circle)
            circles.append(circle)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Player.sharedInstance.delegate = self
        
        if isFirstDisplay == true {
            isFirstDisplay = false
            UIApplication.presentConnectViewController(animated:false)
        }
        
        self.view.bringToFront(openConnectViewButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSensorData(notification:)), name: .OrpheDidUpdateSensorData, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openSettingViewButtonAction(_ sender: Any) {
        UIApplication.presentConnectViewController()
    }
    
    //MARK: Orphe Notifications
    
    func didUpdateSensorData(notification:Notification){
        guard let userInfo = notification.userInfo else {return}
        let orphe = userInfo[OrpheDataUserInfoKey] as! ORPData
        let circle = circles[orphe.side.hashValue]
        
        
        
        //position
        let amp = canvas.width*1.2
        let centerX = map(Double(orphe.getGyro()[2]), min: 1, max: -1, toMin: circle.initPoint.x - amp, toMax: circle.initPoint.x + amp)
        circle.updateCenterX(centerX)
        
        let maxH = canvas.height/3
        let centerY = map(Double(orphe.getGyro()[0]), min: 1, max: -1, toMin: canvas.height-maxH - amp, toMax: maxH + amp)
        circle.updateCenterY(centerY)
        
    }
    
    var rotatingHue:Double = 0.4
    func makeRotatingHue(side:ORPSide)->Double{
        rotatingHue += 0.01
        if rotatingHue > 1 {
            rotatingHue -= 1
        }
        
        var hue = rotatingHue
        if side.hashValue == 0{
            hue += 0.5
            if hue > 1 {
                hue -= 1
            }
        }
        return hue
    }
    
    var animTimeStamp = Date()
    var animCounter = 0
    func animate(side:ORPSide){
        let circle = circles[side.hashValue]
        
        ShapeLayer.disableActions = true
        let fadeCircle = CustomCircle(center:circle.center, radius:circle.width/2)
        var col = white
        
        animCounter += 1
        
        let hue = makeRotatingHue(side:side)
        let minBrightness = 0.1
        switch animCounter % 4 {
        case 0:
            fadeCircle.lineWidth = canvas.width/7.2
            col = Color(hue:hue, saturation:random01()+0.6, brightness:random01()+0.3+minBrightness, alpha:0.5)
        case 1:
            fadeCircle.lineWidth = canvas.width/36
            col = Color(hue:hue, saturation:random01()+0.2, brightness:random01()*0.8+minBrightness, alpha:0.6)
        case 2:
            fadeCircle.lineWidth = canvas.width/180
            col = Color(hue:hue, saturation:random01()*0.4, brightness:0.2, alpha:0.7)
        case 3:
            fadeCircle.lineWidth = canvas.width/18
            col = Color(hue:hue, saturation:1, brightness:random01()*0.8+minBrightness, alpha:0.4)
        default:
            break
        }
        
        fadeCircle.fillColor = clear
        fadeCircle.strokeColor = col
        
        canvas.add(fadeCircle)
        
        ShapeLayer.disableActions = false
        let cColor = circle.strokeColor!
        circle.strokeColor = Color(hue:hue, saturation:cColor.saturation, brightness:cColor.brightness, alpha:cColor.alpha)
        ShapeLayer.disableActions = true
        
        
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animTimeStamp)
        animTimeStamp = Date()
        let maxFadeDuration = 2.0
        let minFadeDuration = 0.1
        var fadeDuration = 2.0
        fadeDuration = elapsedTime/0.285714
        if fadeDuration > maxFadeDuration{
            fadeDuration = maxFadeDuration
        }
        else if fadeDuration < minFadeDuration{
            fadeDuration = minFadeDuration
        }
        
        fadeCircle.startFade(duration:fadeDuration)
        
        ShapeLayer.disableActions = false
        
        if animCounter == Int.max{
            animCounter = 0
        }
        
        self.view.bringToFront(openConnectViewButton)
    }
}

//MARK: - PlayerDelegate
extension ViewController: PlayerDelegate{
    func didTriggerLight(side:ORPSide){
        animate(side:side)
        
        //orphe light
        for orp in ORPManager.sharedInstance.getOrpheArray(side: side){
            let color1 = circles[side.hashValue].strokeColor!
            let color2 = circles[1-side.hashValue].strokeColor!
            
            orp.triggerLightWithHSVColor(lightNum: 4, hue: UInt16(color1.hue*360), saturation: 150, brightness: 255)
            orp.triggerLightWithHSVColor(lightNum: 8, hue: UInt16(color2.hue*360), saturation: 150, brightness: 255)
        }
    }
    
    func didBangAccompany(){
        let offsetX:Double = random01()*canvas.height/2
        let offsetY:Double = random01()*canvas.width/2
        do{
            ShapeLayer.disableActions = true
            let fadeCircle = Circle(center: canvas.center, radius:canvas.width*0.1)
            fadeCircle.fillColor = Color(hue: gray.hue, saturation: gray.saturation, brightness: gray.brightness, alpha: 0.2)
            fadeCircle.strokeColor = clear
            ShapeLayer.disableActions = false
            
            canvas.add(fadeCircle)
            let fadeAnim = ViewAnimation(duration: 3){
                fadeCircle.fillColor = clear
                fadeCircle.transform.scale(10, 10)
            }
            fadeAnim.addCompletionObserver {
                fadeCircle.removeFromSuperview()
            }
            fadeAnim.curve = .Linear
            fadeAnim.animate()
        }
        
        
        let begin = Point(offsetX, offsetY)
        let end = Point(offsetX, offsetY)
        let line = Line(begin: begin, end: end)
        line.lineWidth = 1
        line.strokeColor = gray
        canvas.add(line)
        let fadeAnim = ViewAnimation(duration: 5){
            let offsetEdge:Double = 100
            var tiltY = random01()*self.canvas.height*2
            if random01() > 0.5{
                tiltY = tiltY*(-1)
            }
            let p1 = Point(0-offsetEdge,self.canvas.height/2+tiltY)
            let p2 = Point(self.canvas.width+offsetEdge,self.canvas.height/2-tiltY)
            line.endPoints = (p1,p2)
            line.strokeColor = clear
        }
        fadeAnim.addCompletionObserver {
            line.removeFromSuperview()
        }
        fadeAnim.curve = .Linear
        fadeAnim.animate()
        
        self.view.bringToFront(openConnectViewButton)
    }
}


