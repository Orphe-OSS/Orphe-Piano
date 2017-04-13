//
//  Player.swift
//  Orphe-Instrument
//
//  Created by kyosuke on 2017/01/02.
//  Copyright © 2017 no new folk studio Inc. All rights reserved.
//

import Orphe

public protocol EnumEnumerable {
    associatedtype Case = Self
}

@objc public protocol PlayerDelegate:class {
    @objc optional func didTriggerLight(side:ORPSide)
    @objc optional func didBangAccompany()
}

public extension EnumEnumerable where Case: Hashable {
    private static var iterator: AnyIterator<Case> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Case.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }
    
    public static func enumerate() -> EnumeratedSequence<AnySequence<Case>> {
        return AnySequence(self.iterator).enumerated()
    }
    
    public static var cases: [Case] {
        return Array(self.iterator)
    }
    
    public static var count: Int {
        return self.cases.count
    }
}

enum SourceList :String, EnumEnumerable {
    case g_TriggerLight = "g_TriggerLight"
    case g_TriggerLightHSV = "g_TriggerLightHSV"
    case g_AccompanyBanged = "g_AccompanyBanged"
}

class Player : NSObject, PdReceiverDelegate{
    
    public weak var delegate:PlayerDelegate?
    
    let sideArray = ["LEFT","RIGHT"]
    
    let audioController = PdAudioController() // PureData
    var pdPointer:UnsafeMutableRawPointer?
    
    class var sharedInstance : Player {
        struct Static {
            static let instance : Player = Player()
        }
        return Static.instance
    }
    
    func pdSetup(){
        let dispatcher = PdDispatcher()
        for source in SourceList.cases{
            dispatcher.add(self, forSource: source.rawValue)
        }
        PdBase.setDelegate(dispatcher)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSensorData(notification:)), name: .OrpheDidUpdateSensorData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCatchGestureEvent(notification:)), name: .OrpheDidCatchGestureEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AVAudioSessionRouteChange(notification:)), name: .AVAudioSessionRouteChange, object: nil)
        
        updateSampleRate()
        audioController.isActive = true
    }
    
    func openPdFile(){
        
        pdSetup()
        
        if pdPointer == nil {
            pdPointer = PdBase.openFile("main.pd", path: Bundle.main.resourcePath!+"/pd-patches")
            if pdPointer != nil{
                print("open pd file")
            }
            else{
                print("open pd error")
            }
        }
    }
    
    func closePdFile(){
        if pdPointer != nil{
            PdBase.closeFile(pdPointer!)
            pdPointer = nil
            print("close pd file")
        }
        audioController.isActive = false
    }
    
    func receivePrint(message:String){
        print(message)
    }
    
    //MARK: - Notification
    func didUpdateSensorData(notification:Notification){
        guard let userInfo = notification.userInfo else {return}
        let orphe = userInfo[OrpheDataUserInfoKey] as! ORPData
        
        let sideStr = sideArray[orphe.side.hashValue]
        
        var list: [AnyObject] = [sideStr as AnyObject, "sensorValues" as AnyObject]
        for q in orphe.getQuat(){
            list.append(q as AnyObject)
        }
        for q in orphe.getEuler(){
            list.append(q as AnyObject)
        }
        
        for q in orphe.getAcc(){
            list.append(q as AnyObject)
        }
        
        for q in orphe.getGyro(){
            list.append(q as AnyObject)
        }
        
        list.append(orphe.getMag() as AnyObject)
        
        
        PdBase.sendList(list, toReceiver: "g_message")
    }
    
    func didCatchGestureEvent(notification:Notification) {
        guard let userInfo = notification.userInfo else {return}
        let gestureEvent = userInfo[OrpheGestureUserInfoKey] as! ORPGestureEventArgs
        let orphe = userInfo[OrpheDataUserInfoKey] as! ORPData
        
        let sideStr = sideArray[orphe.side.hashValue]
        let direction = ""
        
        var kind = ""
        var position = ""
        switch gestureEvent.getGestureKind() {
        case .STEP_TOE:
            kind = "STEP"
            position = "TOE"
        case .STEP_FLAT:
            kind = "STEP"
            position = "FLAT"
        case .STEP_HEEL:
            kind = "STEP"
            position = "HEEL"
        case .KICK:
            kind = "KICK"
        default:
            break
        }
        
        let power = gestureEvent.getPower()
        
        let list: [AnyObject] = [sideStr as AnyObject,
                                 "gesture" as AnyObject,
                                 kind as AnyObject,
                                 direction as AnyObject,
                                 position as AnyObject,
                                 power as AnyObject,
                                 ]
        PdBase.sendList(list, toReceiver: "g_message")
        
    }
    
    func AVAudioSessionRouteChange(notification:Notification) {
        PRINT(AVAudioSession.sharedInstance().currentRoute.outputs)
        PRINT("preferredSampleRate:",AVAudioSession.sharedInstance().preferredSampleRate)
        PRINT("sample rate:",AVAudioSession.sharedInstance().sampleRate)
        
        updateSampleRate()
    }
    
    func updateSampleRate(){
        let sampleRate = AVAudioSession.sharedInstance().sampleRate
        audioController.configurePlayback(withSampleRate: Int32(sampleRate), numberChannels: 2, inputEnabled: false, mixingEnabled: true)
    }
}

extension Player: PdListener{
    func receiveBang(fromSource source: String!) {
        switch source {
        case SourceList.g_AccompanyBanged.rawValue:
            delegate?.didBangAccompany?()
        default:
            break
        }
    }
    
    func receive(_ received: Float, fromSource source: String!) {
        
    }
    
    func receiveList(_ list: [Any]!, fromSource source: String!) {
        let side = ORPSide(rawValue: list[0] as! Int32)!
        delegate?.didTriggerLight?(side: side)
//        switch source {
//            
//        case SourceList.g_TriggerLight.rawValue:
//            let lightNum = list[1] as! UInt8
//            trigger(lightNum: lightNum, side: side)
//            
//        case SourceList.g_TriggerLightHSV.rawValue:
//            let lightNum = list[1] as! UInt8
//            let hue = list[2] as! UInt16
//            let sat = list[3] as! UInt8
//            let bri = list[4] as! UInt8
//            for orp in ORPManager.sharedInstance.getOrpheArray(side: side){
//                orp.triggerLightWithHSVColor(lightNum: lightNum, hue: hue, saturation: sat, brightness: bri)
//            }
//            
//        default:
//            break
//        }
    }
    
    func trigger(lightNum:UInt8, side:ORPSide){
        for orp in ORPManager.sharedInstance.getOrpheArray(side: side){
            orp.triggerLight(lightNum: lightNum)
        }
    }
}
