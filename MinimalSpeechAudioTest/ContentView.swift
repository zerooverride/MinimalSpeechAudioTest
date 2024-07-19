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
            Button("Un-ducks Correctly. But throws exception and pauses UI."){
                workingSynthesizer.speak(text: "Hello planet")
            }
            Text("-------")
            Button("Does not un-duck other audio."){
                brokenSynthesizer.speak(text: "Hello planet")
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
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            // always throws an error
            // Error Domain=NSOSStatusErrorDomain Code=560030580 "Session deactivation failed" UserInfo={NSLocalizedDescription=Session deactivation failed}
            // Also pauses UI updates
            print("Deactivate error info: \(error)")
        }
    }
}

class BrokenSpeechSynthesizer {
    var synth = AVSpeechSynthesizer()
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synth.speak(utterance)
    }
}

#Preview {
    ContentView()
}
