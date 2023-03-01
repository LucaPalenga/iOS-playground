//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by LUCA PALENGA on 23/02/23.
//

import UIKit
import AVFAudio

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: PlayngState
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    func setupAudio() {
        do {
            if let recorder = recorderAudioURL {
                audioFile = try AVAudioFile(forReading: recorder as URL)
            }
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    
    func playAudio(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        if let audioPlayerNode = audioPlayerNode {
            audioEngine?.attach(audioPlayerNode)
        }
        
        // rate/pitch adjusting
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine?.attach(changeRatePitchNode)
        
        // echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine?.attach(echoNode)
        
        // reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine?.attach(reverbNode)
        
        if let audioPlayerNode = audioPlayerNode, let audioEng = audioEngine {
            if echo && reverb {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode)
            } else if echo {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEng.outputNode)
            } else if reverb {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEng.outputNode)
            } else {
                connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEng.outputNode)
            }
        }
        
        audioPlayerNode?.stop()
        if let audioFile = audioFile {
            audioPlayerNode?.scheduleFile(audioFile, at: nil) {
                var delayInSeconds: Double = 0
                
                if let lastRenderTime = self.audioPlayerNode?.lastRenderTime, let playerTime = self.audioPlayerNode?.playerTime(forNodeTime: lastRenderTime) {
                    
                    if let rate = rate {
                        delayInSeconds = Double(audioFile.length - playerTime.sampleTime) / Double(audioFile.processingFormat.sampleRate) / Double(rate)
                    } else {
                        delayInSeconds = Double(audioFile.length - playerTime.sampleTime) / Double(audioFile.processingFormat.sampleRate)
                    }
                }
                
                self.timer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
                RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
            }
        }
        
        do {
            try audioEngine?.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
        }
        
        audioPlayerNode?.play()
    }
    
    // MARK: stop audio
    @objc func stopAudio() {
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let timer = timer {
            timer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    
    // MARK: connect nodes
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for i in 0..<nodes.count-1 {
            audioEngine?.connect(nodes[i], to: nodes[i+1], format: audioFile?.processingFormat)
        }
    }
  
    func configureUI(_ playState: PlayingState) {
        switch(playState){
        case .playing:
            setPlayButtonsEnabled(false)
            stopBtn.isEnabled = true
            stopBtn.alpha = 1
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopBtn.isEnabled = false
            stopBtn.alpha = 0.5
        }
    }
    
    func setPlayButtonsEnabled(_ value: Bool){
        slowBtn.isEnabled = value
        fastBtn.isEnabled = value
        echoBtn.isEnabled = value
        reverbBtn.isEnabled = value
        highPitchBtn.isEnabled = value
        lowPitchBtn.isEnabled = value
        
        slowBtn.alpha = value ? 1 : 0.5
        fastBtn.alpha = value ? 1 : 0.5
        echoBtn.alpha = value ? 1 : 0.5
        reverbBtn.alpha = value ? 1 : 0.5
        highPitchBtn.alpha = value ? 1 : 0.5
        lowPitchBtn.alpha = value ? 1 : 0.5
    }
}

