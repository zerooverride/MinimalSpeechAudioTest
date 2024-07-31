//
//  ContentView.swift
//  MinimalSpeechAudioTest
//
//  Created by Tyler Eckstein on 7/13/24.
//

import SwiftUI
import AVFoundation

@Observable
class Rotator {
    var rotation = 0.0
    private var timer = Timer()
    
    func start() -> Void {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){ timer in
            self.rotation += 45.0
        }
    }
}

struct ContentView: View {
    let workingSynthesizer = UnduckingSpeechSynthesizer()
    let brokenSynthesizer = BrokenSpeechSynthesizer()
    let customAudioPlayer = CustomAudioPlayer()
    let rotator = Rotator()

    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
        } catch {
            print("Setup error info: \(error)")
        }
        rotator.start()
    }
    
    var body: some View {
        VStack {
            Button("Un-ducks Correctly. But throws exception. First synthesizer usage after app launch pauses UI."){
                workingSynthesizer.speak(text: "Hello planet")
            }
            Text("-------")
            Button("Does not un-duck other audio. First synthesizer usage after app launch pauses UI."){
                brokenSynthesizer.speak(text: "Hello planet")
            }
            Text("-------")
            Button("Pre-made Audio File."){
                customAudioPlayer.play(soundfile: "Hello_planet_1")
            }
            Text("-------")
            Label("Arrow", systemImage: "arrow.up").rotationEffect(.degrees(rotator.rotation)).labelStyle(.iconOnly)
        }
        .padding()
    }
}

class UnduckingSpeechSynthesizer: NSObject {
    var synth = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    override init(){
        super.init()
        synth.delegate = self
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synth.speak(utterance)
    }
}

extension UnduckingSpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // putting to any higher qos makes UI pause during audio session deactivation
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
            catch {
                // always throws an error
                // Error Domain=NSOSStatusErrorDomain Code=560030580 "Session deactivation failed" UserInfo={NSLocalizedDescription=Session deactivation failed}
                // Also pauses UI updates
                print("Deactivate error info: \(error)")
            }
        }
    }
}

class BrokenSpeechSynthesizer {
    var synth = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        self.synth.speak(utterance)
    }
}

class CustomAudioPlayer {
    var audioPlayer: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()

    func play(soundfile: String) {
        // putting to any higher qos makes UI pause during audio session deactivation
        DispatchQueue.global(qos: .utility).async {
            if let path = Bundle.main.path(forResource: soundfile, ofType: "wav"){
                do {
                    // doesn't seem necesssary but seems to be best practice
                    try self.audioSession.setActive(true)
                }
                catch {
                    print("Activate error info: \(error)")
                }
                do{
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.play()
                } catch {
                    print("Error")
                }
                
                while(self.audioPlayer!.isPlaying){
                    // wait so audio isn't stopped pre-maturely
                }
                do {
                    try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                }
                catch {
                    print("Deactivate error info: \(error)")
                }
            } else {
                print("No file")
            }
        }
    }
}

#Preview {
    ContentView()
}
