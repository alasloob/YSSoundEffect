//
//  YSAudioEngine.swift
//  YSSoundEffects
//
//  Created by Youssef Eid on 04/07/1440 AH.
//  Copyright © 1440 Youssef Eid. All rights reserved.
//

import AVFoundation
import UIKit

protocol YSAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying()
}

class YSAudioEngie {

    // Properties
    var pitchValue: Float = 0.0
    var speedValue: Float = 1.0
    var isEcho = false
    var isReverb = false
    var delegate: YSAudioPlayerDelegate!
    
    fileprivate var audioFile: AVAudioFile!
    fileprivate var audioEngine: AVAudioEngine!
    fileprivate var audioNodes: AVAudioPlayerNode!
    fileprivate var nodes:[AVAudioNode] = []
    
    var timer: Timer!
    
    // initialize
    init(urlFileOfAudio: URL) {
        do {
            self.audioFile = try AVAudioFile(forReading: urlFileOfAudio)
        } catch {
            print("Opps!, I can't find file try agin later")
            self.alert(message: error.localizedDescription)
        }
    }
    
    func isPlaying() -> Bool {
        if let node = self.audioNodes {
            return node.isPlaying
        }
        return false
    }
    
    // MARK: Play Audio
    func playAudio() {
        
        self.nodes.removeAll()
        
        self.audioEngine = AVAudioEngine()
        self.audioNodes = AVAudioPlayerNode()
        self.audioEngine.attach(self.audioNodes)
        self.nodes.insert(self.audioNodes, at: 0)
        
        self.chnageRateAndPitch(engine: self.audioEngine)
        if self.isEcho {
            let echo = AVAudioUnitDistortion()
            echo.loadFactoryPreset(.multiEcho1)
            self.audioEngine.attach(echo)
            self.nodes.append(echo)
        }
        if self.isReverb {
            let reverb = AVAudioUnitReverb()
            reverb.loadFactoryPreset(.cathedral)
            reverb.wetDryMix = 40
            self.audioEngine.attach(reverb)
            self.nodes.append(reverb)
        }
        self.nodes.append(self.audioEngine.outputNode)
        self.connectNodes(self.nodes)
        
        self.audioNodes.stop()
        self.audioNodes.scheduleFile(self.audioFile, at: nil) {
            var deleySecound: Double = 0
            if let lastRenderTime = self.audioNodes.lastRenderTime,
                let playerTime = self.audioNodes.playerTime(forNodeTime: lastRenderTime) {
                if self.speedValue != 1 {
                    deleySecound = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(self.speedValue)
                } else {
                    deleySecound = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            self.timer = Timer(timeInterval: deleySecound, target: self, selector: #selector(self.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.timer, forMode: .default)
        }
        
        do {
            try self.audioEngine.start()
        } catch {
            print("Error Audio Engine")
            self.alert(message: error.localizedDescription)
            return
        }
        
        self.audioNodes.play()
    }
    
    @objc func stopAudio() {
        if let playerNode = self.audioNodes {
            playerNode.stop()
        }
        if let timer = self.timer {
            timer.invalidate()
        }
        if let audioEngine = self.audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        if let del = self.delegate {
            del.audioPlayerDidFinishPlaying()
        }
    }
    
    fileprivate func chnageRateAndPitch(engine: AVAudioEngine) {
        let chRatePitchNode = AVAudioUnitTimePitch()
        if self.pitchValue != 0 {
            chRatePitchNode.pitch = self.pitchValue * 1000
        }
        if self.speedValue != 1 {
            chRatePitchNode.rate = self.speedValue
        }
        if self.speedValue != 1 || self.pitchValue != 0 {
            self.nodes.append(chRatePitchNode)
        }
        engine.attach(chRatePitchNode)
    }

    fileprivate func connectNodes(_ nodes: [AVAudioNode]) {
        for n in 0..<nodes.count-1 {
            self.audioEngine.connect(nodes[n], to: nodes[n+1], format: audioFile.processingFormat)
        }
    }
    
    fileprivate func alert(message: String) {
        if let delegate = self.delegate {
            if let vc = delegate as? UIViewController {
                AlertView.show("Error", message: message, vc: vc)
            }
        }
    }

}
