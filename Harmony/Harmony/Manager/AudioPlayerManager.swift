//
//  AudioPlayerManager.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var players: [AVAudioPlayer] = []
    private var currentPlayerIndex = 0
    private var timer: Timer?
    private var accumulatedTime: TimeInterval = 0
    
    func loadPlaylist(_ urls: [URL]) {
        players = urls.compactMap { url in
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                return player
            } catch {
                print("Failed to load audio file: \(error)")
                return nil
            }
        }
        updateDuration()
        print("Loaded \(players.count) audio files")
    }
    
    func scrubbing(_ isScrubbing: Bool) {
        if isScrubbing {
            pausePlayback()
        } else {
            if isPlaying {
                startPlayback()
            }
        }
    }
    
    func playPause() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 10, 0)
        seekTo(time: newTime)
    }
    
    func skipForward() {
        let newTime = min(currentTime + 10, duration)
        seekTo(time: newTime)
    }

    
    func seekTo(time: TimeInterval) {
        accumulatedTime = 0
        var remainingTime = time
        for (index, player) in players.enumerated() {
            if remainingTime < player.duration {
                currentPlayerIndex = index
                player.currentTime = remainingTime
                break
            }
            remainingTime -= player.duration
            accumulatedTime += player.duration
        }
        updateCurrentTime()
        if isPlaying {
            startPlayback()
        }
    }
    
    private func pausePlayback() {
        players[currentPlayerIndex].pause()
        stopTimer()
        isPlaying = false
    }
    
    private func startPlayback() {
        guard !players.isEmpty, currentPlayerIndex < players.count else {
            print("No audio files to play or invalid player index")
            isPlaying = false
            return
        }
        players[currentPlayerIndex].play()
        startTimer()
        isPlaying = true
    }
    
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentTime() {
        var totalTime: TimeInterval = 0
        for (index, player) in players.enumerated() {
            if index < currentPlayerIndex {
                totalTime += player.duration
            } else if index == currentPlayerIndex {
                totalTime += player.currentTime
                break
            }
        }
        currentTime = totalTime
    }
    
    private func updateDuration() {
        duration = players.reduce(0) { $0 + $1.duration }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentPlayerIndex += 1
        if currentPlayerIndex < players.count {
            startPlayback()
        } else {
            isPlaying = false
            stopTimer()
            currentPlayerIndex = 0
            updateCurrentTime()
        }
    }
}

