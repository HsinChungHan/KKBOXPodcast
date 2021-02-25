//
//  MaxPlayerViewWithAVPlayer.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/25.
//

import AVKit
import MediaPlayer
import UIKit


extension MaxPlayerView {
    
    func makeAVPlayer() -> AVPlayer {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }
    
    func setupAudioSession() {
        do {
            // .playback: 後台播放且獨佔
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
    func playEpisode() {
        guard let downloadedEpisode = UserDefaults.standard.getEpisode(episode: episode) else {
            guard let url = URL(string: episode.streamUrl) else { return }
            let playerItem = AVPlayerItem(url: url)
            avPlayer.replaceCurrentItem(with: playerItem)
            avPlayer.play()
            APIService.shared.downloadEpisode(episode: episode)
            return
        }
        playEpisodeUsingFileUrl(downloadedEpisode: downloadedEpisode)
    }
    
    // - MARK: play downloaded episode
    func playEpisodeUsingFileUrl(downloadedEpisode: Episode) {
        guard let fileURL = URL(string: downloadedEpisode.fileUrl ?? "") else { return }
        vm.setIsUsingDownloadedEpisode(isUsingDownloadedEpisode: true)
        let fileName = fileURL.lastPathComponent
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        trueLocation.appendPathComponent(fileName)
        let playerItem = AVPlayerItem(url: trueLocation)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
    }
    
    func addInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            vm.setIsPlaying(isPlaying: true)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                vm.setIsPlaying(isPlaying: false)
                avPlayer.play()
            }
        }
    }
    
    func addPlayerDidFinishObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc fileprivate func handlePlayerDidFinishPlaying(notification: Notification) {
        vm.setIsPlaying(isPlaying: false)
        UserDefaults.standard.deleteEpisode(episode: episode)
        pressNextButton(sender: nextButton)
    }
    
    func addBoundaryTimeObserver() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        // observe episode's time boundary
        avPlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.vm.setIsPlaying(isPlaying: true)
            self?.identityEpisodeImageView()
        }
    }
    
    func addAVPlayerCurrentTimeObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 2)
        avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            self?.vm.setCurrentTimeStr(currentTimeStr: time.toString())
            guard let durationTime = self?.avPlayer.currentItem?.duration else { return }
            self?.vm.setDurationTimeStr(durationTimeStr: durationTime.toString())
        }
    }
}
