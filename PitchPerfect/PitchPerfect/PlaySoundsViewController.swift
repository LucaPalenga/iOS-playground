//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by LUCA PALENGA on 23/02/23.
//

import UIKit
import AVFAudio

class PlaySoundsViewController: UIViewController {

    var recorderAudioURL: URL?

    @IBOutlet weak var slowBtn: UIButton!
    @IBOutlet weak var fastBtn: UIButton!
    @IBOutlet weak var reverbBtn: UIButton!
    @IBOutlet weak var echoBtn: UIButton!
    @IBOutlet weak var highPitchBtn: UIButton!
    @IBOutlet weak var lowPitchBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var timer: Timer?
    
    enum ButtonType: Int {
        case slow = 0
        case fast = 1
        case reverb = 2
        case echo = 3
        case highPitch = 4
        case lowPitch = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
    
    // MARK: Buttons actions
    @IBAction func playSound(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)) {
        case .slow:
            playAudio(rate: 0.5)
        case .fast:
            playAudio(rate: 1.5)
        case .reverb:
            playAudio(reverb: true)
        case .echo:
            playAudio(echo: true)
        case .highPitch:
            playAudio(pitch: 1000)
        case .lowPitch:
            playAudio(pitch: -1000)
        case .none: break
            // do nothing
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopSound(_ sender: AnyObject) {
       stopAudio()
    }

}
