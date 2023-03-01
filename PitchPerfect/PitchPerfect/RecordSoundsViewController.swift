//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by LUCA PALENGA on 21/02/23.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    let SEGUE_ID = "stopRecording"
    
    var audioRecorder: AVAudioRecorder?
    
    // IBOutlet reppresenta un elemento di ui nel controller
    // controller -> ui
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var startRecordingBtn: UIButton!
    @IBOutlet weak var stopRecordingBtn: UIButton!
    
    
    // IBAction gestisce un'azione ui -> controller
    // esegue questa funzione al click del bottone
    @IBAction func recordAudio(_ sender: Any) {
        print("start recording")
        recordingLabel.text = "Recording in progress..."
        toggleButtonsUI(start: false, stop: true)
        
        startRecord()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        print("stop recording")
        recordingLabel.text = "Tap to record"
        toggleButtonsUI(start: true, stop: false)
        
        stopRecord()
    }
    
    private func toggleButtonsUI(start: Bool, stop: Bool){
        startRecordingBtn.isEnabled = start
        startRecordingBtn.alpha = start ? 1 : 0.5
        stopRecordingBtn.isEnabled = stop
        stopRecordingBtn.alpha = stop ? 1 : 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleButtonsUI(start: true, stop: false)
    }
    
    
    private func startRecord(){
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordFileName = "recorderVoice.wav"
        let pathArray = [dirPath, recordFileName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        if let path = filePath {
            print(path.description)
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
        } catch {
            showAlert("Error", message: "audio session error")
        }
        
        do {
            if let file = filePath {
                try audioRecorder = AVAudioRecorder(url: file, settings: [:])
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.prepareToRecord()
                audioRecorder?.record()
            }
        } catch {
            showAlert("Error", message: "audio recording error")
        }
    }
    
    private func stopRecord(){
        audioRecorder?.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            showAlert("Erroe", message: "audio session disactive error")
        }
    }
    
    // Audio recorder delegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            showAlert("Error", message: "audio recording error")
            return
        }
        
        if let recorder = audioRecorder {
            performSegue(withIdentifier: SEGUE_ID, sender: recorder.url)
        }
    }
    
    // opening next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_ID {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recorderAudioURL = recordedAudioURL
        }
    }

}


// MARK: Extension for alerts
extension UIViewController {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You're disable this app from recording your microphone. Check settings"
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording"
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default))
        self.present(alert, animated: true)
    }
}
