//
//  AudioPlayerView.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//


import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @State private var isScrubbing = false
    @State private var scrubbingValue: Double = 0
    
    var body: some View {
        VStack {
            Slider(value: $scrubbingValue, in: 0...audioPlayer.duration, onEditingChanged: { editing in
                if editing {
                    isScrubbing = true
                    audioPlayer.scrubbing(true)
                } else {
                    isScrubbing = false
                    audioPlayer.seekTo(time: scrubbingValue)
                    audioPlayer.scrubbing(false)
                }
            })
            .accentColor(.mainGreen)
            .onAppear {
                scrubbingValue = audioPlayer.currentTime
            }
            .onChange(of: audioPlayer.currentTime) { newValue in
                if !isScrubbing {
                    scrubbingValue = newValue
                }
            }
            
            HStack {
                Text(timeString(isScrubbing ? scrubbingValue : audioPlayer.currentTime))
                Spacer()
                Button(action: { audioPlayer.skipBackward() }) {
                    Image(systemName: "gobackward.10")
                        .foregroundColor(.mainGreen)
                }
                Button(action: { audioPlayer.playPause() }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                        .font(.largeTitle)
                        .foregroundColor(.mainGreen)
                }
                Button(action: { audioPlayer.skipForward() }) {
                    Image(systemName: "goforward.10")
                        .foregroundColor(.mainGreen)
                }
                Spacer()
                Text(timeString(audioPlayer.duration))
            }
        }
        .padding()
    }
    
    func timeString(_ time: TimeInterval) -> String {
        guard time.isFinite else { return "00:00" }
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

