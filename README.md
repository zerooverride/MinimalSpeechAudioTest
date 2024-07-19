# MinimalSpeechAudioTest
A minimal iOS app example showing that AVSpeechSynthesizer does not fully handle AVAudioSession

Related post on the Apple developer forum: https://developer.apple.com/forums/thread/759553

# Description of Problem
When using AVSpeechSynthesizer to play text to speech, there is some problem with deactivating the apps AVAudioSession. It is unclear if AVSpeechSynthesizer attempts to do so on its own, or if the developer is supposed to do so. Without attempting to deactivate the session as the developer, the AVAudioSession is not deactivated as I would expect (other App's ducked or interrupted audio are not resumed correctly). When attempting to deactivate the session as the developer, an exception is thrown, and updates in the UI are temporarily paused, but other App's audio are resumed as expected.

# Steps to Reproduce
Create an app and set its AVAudioSession category as .playback, mode as .voicePrompt, and options to include .duckOthers. Include a button which will use AVSpeechSynthesizer.speak("some text")

Play music/audio from another app on your device (ex: Music app).

Open the test app and press the button to trigger the AVSpeechSynthesizer to speak. You will observe the other apps audio duck, but not unduck.

If you instead implement a custom AVSpeechSynthesizerDelegate which calls audioSession.setActive(false, options: .notifyOthersOnDeactivation), you will see an exception thrown, but if caught, you will notice the other apps audio unducks as expected due to the .notifyOthersOnDeactivation

If you include some UI element which is constantly updated based on a Timer, you will notice a pause in updates when that exception is thrown/caught.

These issues do not seem to affect the Xcode preview or simulator, but happen on a real device. (iPhone 12 Pro, iOS Version 17.5.1)

# Video Demonstration (make sure you turn on the audio!)

https://github.com/user-attachments/assets/dcb21a4a-3de2-4cab-b4b1-4fa35002656b
