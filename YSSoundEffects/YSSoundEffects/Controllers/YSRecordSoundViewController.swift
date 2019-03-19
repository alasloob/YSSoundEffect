//
//  YSRecordSoundViewController.swift
//  YSSoundEffects
//
//  Created by Youssef Eid on 03/07/1440 AH.
//  Copyright © 1440 Youssef Eid. All rights reserved.
//

import UIKit
import AVFoundation

class YSRecordSoundViewController: UIViewController {

    // MARK: Outlet all buttons
    @IBOutlet weak var btnRecordAndStop: UIButton!
    
    // MARK: Outlet all Label
    @IBOutlet weak var lbTxtStuts: UILabel!
    @IBOutlet weak var lbTimer: UILabel!

    // MARK: property AVFoundations Record ...
    var recordAudio: AVAudioRecorder!
    
    var isRecording: Bool = false
    var beginRecorderTime: TimeInterval = 0
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func recordAndStop(_ sender: UIButton) {
        if !isRecording {
            self.recordPermission()
        } else {
            self.stopRecorder()
        }
    }
    
    fileprivate func recordPermission() {
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (flag) in
            DispatchQueue.main.async {
                if flag {
                    self.audioRecorder()
                } else {
                    self.alert(message: "Please Go to your device settings and enable mic in privacy")
                }
            }
        }
    }
    
    fileprivate func audioRecorder() {
    
        // Path Save Recoder
        let temPath = FileManager.default.temporaryDirectory.absoluteString
        let recordName = "tmpRecorder.wav"
        guard let fullPath = URL(string: temPath + recordName) else { return }
        
        // Active Mic & Speaker
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        // Init audio recorder
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            self.recordAudio = try AVAudioRecorder(url: fullPath, settings: [:])
        } catch {
            self.alert(message: error.localizedDescription)
        }
        
        self.recordAudio.isMeteringEnabled = true
        self.recordAudio.delegate = self
        self.recordAudio.prepareToRecord()
        self.recordAudio.record()
        
        // update text .. time .. and statu recorder
        self.lbTxtStuts.text = "Recording in progress"
        self.isRecording = !self.isRecording
        self.btnRecordAndStop.setImage(#imageLiteral(resourceName: "Stop"), for: .normal)
        self.beginRecorderTime = Date().timeIntervalSince1970
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
        { (timer) in
            self.updateRecroderTimer()
        }
        self.timer.fire()
    }
    
    fileprivate func stopRecorder() {
        guard let ra = self.recordAudio else { return }
        ra.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            alert(message: error.localizedDescription)
        }
        self.isRecording = !self.isRecording
        self.lbTxtStuts.text = "Tap to Record"
        self.lbTimer.text = "00:00"
        self.timer.invalidate() // stop timer when user click button stop
        self.btnRecordAndStop.setImage(#imageLiteral(resourceName: "Record"), for: .normal)
    }
    
    fileprivate func updateRecroderTimer() {
        let current = Date().timeIntervalSince1970
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let calDate = Date(timeIntervalSince1970: TimeInterval(current - self.beginRecorderTime))
        let formattedString = formatter.string(from: calDate)
        self.lbTimer.text = formattedString
    }
    
    fileprivate func alert(message: String) {
        AlertView.show("Error", message: message, vc: self)
    }
    
}

extension YSRecordSoundViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag /* recorder is successfully go to the vc audio play */ {
            self.performSegue(withIdentifier: "VCPlayAudio", sender: self.recordAudio.url)
        } else {
            print("Opps!, Recording is fail, try again later")
            self.alert(message: "Opps!, Recording was not successful.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VCPlayAudio" {
            if let url = sender as? URL {
                if let vc = segue.destination as? YSAudioPlayerViewController {
                    vc.audioUrl = url
                }
            }
        }
    }
    
}
