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
    case playing
    case stop
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}


extension PodcastPlayer {
    
    fileprivate func setupPlayer() {
        automaticallyWaitsToMinimizeStalling = false
        setupAudioSession()
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
    
    func addInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            // 看 pause() 能不能交由外部去控制
            pause()
            delegate?.podcastPlayerHandleInterruption(self, status: .stop)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options ==
                AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                // 看 play() 能不能交由外部去控制
                play()
                delegate?.podcastPlayerHandleInterruption(self, status: .playing)
            }
        }
    }
    
    func playEpisode() {
        guard let url = URL(string: episode.streamUrl) else {
            print("🚨 The episode's stream url is nil!")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        replaceCurrentItem(with: playerItem)
        play()
        delegate?.podcastPlayerHandlePlaying(self, episode: episode)
    }
    
    func setDidFinishObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc fileprivate func handlePlayerDidFinishPlaying(notification: Notification) {
        delegate?.podcastPlayerHandleObserveDidFinishPlaying(self, notification: notification)
    }
    
    func setBoundaryTimeObserver() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        // observe episode's time boundary
        addBoundaryTimeObserver(forTimes: times, queue: .main) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.podcastPlayerHandleObserveEpisodeBoundaryTime(self, times: times)
        }
    }
    
    func setPeriodicTimeObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 2)
        addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            self.delegate?.podcastPlayerHandleObservePeriodicTime(self, timeInterval: time)
        }
    }
}
