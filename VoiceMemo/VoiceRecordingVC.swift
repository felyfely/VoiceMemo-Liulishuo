//
//  VoiceRecordingVC.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/21/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import UIKit
typealias VM = VoiceManager
typealias DM = DataManager

extension UIViewController {
    var appD : AppDelegate  {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
}
class VoiceRecordingVC : UIViewController {
    
    @IBOutlet weak var recordButton: RecordButton!
    

    
    
    @IBAction func play(_ sender: Any) {
        VM.shared.doPlay()
    }
    
    @IBAction func stopPlaying(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        recordButton.delegate = self
    }
    
}

extension VoiceRecordingVC : RecordingStateDelegate {
    func didStartRecording() {
        VM.shared.startRecording()
    }
    func didCancellRecording() {
        // delete recording here
    }
    func didEndRecording() {
        VM.shared.finishRecording()
        
    }
    
}
