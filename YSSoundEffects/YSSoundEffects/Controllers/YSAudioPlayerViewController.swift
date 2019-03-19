//
//  YSAudioPlayerViewController.swift
//  YSSoundEffects
//
//  Created by Youssef Eid on 04/07/1440 AH.
//  Copyright © 1440 Youssef Eid. All rights reserved.
//

import UIKit
import AVFoundation

class YSAudioPlayerViewController: UIViewController {

    // MARK: Properties
    var audioUrl:URL!
    var audioEngie: YSAudioEngie!
    
    // MARK: Outlet Buttons
    @IBOutlet weak var btnPlayAndStop: UIButton!
    
    // MARK: Outlet Switches
    @IBOutlet weak var swEech: UISwitch!
    @IBOutlet weak var swReverb: UISwitch!
    
    // MARK: Outlet Silders
    @IBOutlet weak var siSpeed: UISlider!
    @IBOutlet weak var siPitch: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // rest to defualt value
        self.resetToDefaultValue()
        self.setAudioPlayer()
       
    }
    
    // MARK: Setting and Reset functions
    fileprivate func setAudioPlayer() {
        self.audioEngie = YSAudioEngie(urlFileOfAudio: self.audioUrl)
        self.audioEngie.delegate = self 
    }
    
    fileprivate func resetToDefaultValue() {
        self.swEech.isOn = false
        self.swReverb.isOn = false
        self.siPitch.value = 0.0
        self.siSpeed.value = 1.0
    }
    
    // MARK: IBAction buttons
    @IBAction func playAndStop(_ sender: UIButton) {
        if !self.audioEngie.isPlaying() {
            self.audioEngie.playAudio()
            if let btnPlayer = self.btnPlayAndStop {
                btnPlayer.setImage(#imageLiteral(resourceName: "Stop"), for: .normal)
            }
        } else {
            self.audioEngie.stopAudio()
        }
    }
    
    // MARK: IBAction Switches
    @IBAction func changeSwitchesValus(_ sender: UISwitch) {
        if sender == self.swEech {
           self.audioEngie.isEcho = sender.isOn
        }
        if sender == self.swReverb {
            self.audioEngie.isReverb = self.swReverb.isOn
        }
    }
    
    // MARK: IBAction Slider
    @IBAction func changeSlidersValue(_ sender: UISlider) {
        let step: Float = 0.5
        sender.value = round(sender.value / step) * step
        if sender == self.siSpeed {
            self.audioEngie.speedValue = sender.value
        }
        if sender == self.siPitch {
            self.audioEngie.pitchValue = sender.value
        }
    }
    
}

extension YSAudioPlayerViewController: YSAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying() {
        if let btnPlayer = self.btnPlayAndStop {
            btnPlayer.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
    }
    
}
