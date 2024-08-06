//
//  AudioPlayerManager.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import Foundation
import AVFoundation

/*
// MARK: - 동작 버전
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var players: [AVAudioPlayer] = []
    private var currentPlayerIndex = 0
    private var timer: Timer?
    private var accumulatedTime: TimeInterval = 0
    
    func loadPlaylist(_ urls: [URL]) {
        print("Loading playlist with URLs: \(urls)")
        players = urls.compactMap { url in
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                print("Successfully loaded audio player for URL: \(url)")
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
        guard !players.isEmpty else { return }
        players[safe: currentPlayerIndex]?.pause()
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
*/

import AVFoundation
import Combine

class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var accumulatedTime: TimeInterval = 0
    
    private var player: AVQueuePlayer?
    private var playerItems: [AVPlayerItem] = []
    private var timeObserver: Any?
    private var currentItemObserver: NSKeyValueObservation?
    
    func loadPlaylist(_ urls: [URL]) {
        print("Loading playlist with URLs: \(urls)")
        playerItems = urls.map { AVPlayerItem(url: $0) }
        player = AVQueuePlayer(items: playerItems)
        setupTimeObserver()
        setupCurrentItemObserver()
        updateDuration()
        print("Loaded \(playerItems.count) audio files")
    }
    
    func scrubbing(_ isScrubbing: Bool) {
        if isScrubbing {
            pausePlayback()
        } else if isPlaying {
            startPlayback()
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
        seekTo(time: max(currentTime - 10, 0))
    }
    
    func skipForward() {
        seekTo(time: min(currentTime + 10, duration))
    }
    
    func seekTo(time: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: targetTime)
        updateCurrentTime()
    }
    
    private func pausePlayback() {
        player?.pause()
        isPlaying = false
    }
    
    private func startPlayback() {
        player?.play()
        isPlaying = true
    }
    
//    private func setupTimeObserver() {
//        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//            self?.updateCurrentTime()
//        }
//    }
//    
//    private func setupCurrentItemObserver() {
//        currentItemObserver = player?.observe(\.currentItem) { [weak self] player, _ in
//            if player.currentItem == nil {
//                self?.isPlaying = false
//                self?.currentTime = 0
//            }
//        }
//    }
//    
//    private func updateCurrentTime() {
//        guard let player = player else { return }
//        let playerCurrentTime = player.currentTime().seconds
//        currentTime = playerCurrentTime.isNaN ? 0 : playerCurrentTime
//    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateCurrentTime()
        }
    }
    
    private func updateCurrentTime() {
        guard let player = player, let currentItem = player.currentItem else { return }
        let playerCurrentTime = player.currentTime().seconds
        let itemDuration = currentItem.duration.seconds
        
        if let currentIndex = playerItems.firstIndex(of: currentItem) {
            accumulatedTime = playerItems[0..<currentIndex].reduce(0) { $0 + $1.duration.seconds }
        }
        
        currentTime = accumulatedTime + (playerCurrentTime.isNaN ? 0 : playerCurrentTime)
    }
    
    private func setupCurrentItemObserver() {
        currentItemObserver = player?.observe(\.currentItem) { [weak self] player, _ in
            if player.currentItem == nil {
                self?.isPlaying = false
                self?.currentTime = 0
                self?.accumulatedTime = 0
            }
        }
    }
    
    private func updateDuration() {
        duration = playerItems.reduce(0) { $0 + ($1.asset.duration.seconds.isFinite ? $1.asset.duration.seconds : 0) }
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        currentItemObserver?.invalidate()
    }
}
