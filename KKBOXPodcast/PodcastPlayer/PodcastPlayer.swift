//
//  PodcastPlayer.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/3/1.
//

import AVKit
import MediaPlayer
import UIKit


enum PodcastPlayerStatus {
    case play
    case pause
}


protocol PodcastPlayerDataSource: AnyObject {
    
    func podcastPlayerEpisode(_ podcastPlayer: PodcastPlayer) -> Episode
}


protocol PodcastPlayerDelegate: AnyObject {
    
    func podcastPlayerHandlePlaying(_ podcastPlayer: PodcastPlayer, episode: Episode)
    func podcastPlayerHandleInterruption(_ podcastPlayer: PodcastPlayer, status: PodcastPlayerStatus)
    func podcastPlayerHandleObserveDidFinishPlaying(_ podcastPlayer: PodcastPlayer, notification: Notification)
    func podcastPlayerHandleObserveEpisodeBoundaryTime(_ podcastPlayer: PodcastPlayer, times: [NSValue])
    func podcastPlayerHandleObservePeriodicTime(_ podcastPlayer: PodcastPlayer, timeInterval: CMTime)
}


class PodcastPlayer: AVPlayer {
    
    weak var dataSource: PodcastPlayerDataSource?
    weak var delegate: PodcastPlayerDelegate?
    
    var episode: Episode {
        guard let dataSource = dataSource else {
            fatalError("🚨 You have to set dataSource for PodcastPlayer!")
        }
        return dataSource.podcastPlayerEpisode(self)
    }
    
    init(dataSource: PodcastPlayerDataSource, delegate: PodcastPlayerDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init()
        setupPlayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}


// -MARK: internal moethods
extension PodcastPlayer {
    
    func playEpisode() {
        guard let downloadedEpisode = UserDefaults.standard.getEpisode(episode: episode) else {
            guard let url = URL(string: episode.streamUrl) else { return }
            let playerItem = AVPlayerItem(url: url)
            replaceCurrentItem(with: playerItem)
            play()
            APIService.shared.downloadEpisode(episode: episode)
            return
        }
        playEpisodeUsingFileUrl(downloadedEpisode: downloadedEpisode)
        delegate?.podcastPlayerHandlePlaying(self, episode: episode)
    }
    
    func seekEpisode(percentage: Float64) {
        guard let duration = currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1000)
        seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}


// -MARK: private moethods
extension PodcastPlayer {
    
    fileprivate func setupPlayer() {
        automaticallyWaitsToMinimizeStalling = false
        setupAudioSession()
        setInterruptionObserver()
        setDidFinishObserver()
        setBoundaryTimeObserver()
        setPeriodicTimeObserver()
    }
    
    fileprivate func setupAudioSession() {
        do {
            // .playback: 後台播放且獨佔
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
    fileprivate func setInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            pause()
            delegate?.podcastPlayerHandleInterruption(self, status: .pause)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options ==
                AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                play()
                delegate?.podcastPlayerHandleInterruption(self, status: .play)
            }
        }
    }
    
    // - MARK: play downloaded episode
    fileprivate func playEpisodeUsingFileUrl(downloadedEpisode: Episode) {
        guard
            let fileUrl = downloadedEpisode.fileUrl,
            let fileURL = URL(string: fileUrl)
        else { return }
        
        let fileName = fileURL.lastPathComponent
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        trueLocation.appendPathComponent(fileName)
        let playerItem = AVPlayerItem(url: trueLocation)
        replaceCurrentItem(with: playerItem)
        play()
    }
    
    fileprivate func setDidFinishObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc fileprivate func handlePlayerDidFinishPlaying(notification: Notification) {
        delegate?.podcastPlayerHandleObserveDidFinishPlaying(self, notification: notification)
    }
    
    fileprivate func setBoundaryTimeObserver() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        // observe episode's boundary time
        addBoundaryTimeObserver(forTimes: times, queue: .main) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.podcastPlayerHandleObserveEpisodeBoundaryTime(self, times: times)
        }
    }
    
    fileprivate func setPeriodicTimeObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 2)
        addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            self.delegate?.podcastPlayerHandleObservePeriodicTime(self, timeInterval: time)
        }
    }
}
