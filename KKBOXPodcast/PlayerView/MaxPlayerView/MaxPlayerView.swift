//
//  MaxPlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import AVKit
import MediaPlayer
import UIKit


// - MARK: future work: modulize the player view

protocol MaxPlayerViewDataSource: AnyObject {
    func maxPlayerViewSuperview(_ maxPlayerView: MaxPlayerView) -> UIView
}

protocol MaxPlayerViewDelegate: AnyObject {
    func maxPlayerViewGoToLastEpisode(_ maxPlayerView: MaxPlayerView)
    func maxPlayerViewGoToNextEpisode(_ maxPlayerView: MaxPlayerView)
}

class MaxPlayerView: PlayerView {
    
    weak var maxPlayerViewDataSource: MaxPlayerViewDataSource?
    weak var delegate: MaxPlayerViewDelegate?
    
    var superView: UIView {
        guard let dataSource = maxPlayerViewDataSource else {
            fatalError("🚨 You have to set dataSource for MaxPlayerViewDataSource!")
        }
        return dataSource.maxPlayerViewSuperview(self)
    }
    
    lazy var dismissButton = makeDismissButton()
    lazy var minPlayerView = makeMinPlayerView()
    lazy var episodeImageView = makeEpisodeImageView()
    lazy var slider = makeTimeSlider()
    lazy var currentTimeLabel = makeCurrentTimeLabel()
    lazy var durationTimeLabel = makeDurationLabel()
    lazy var timeContainerView = makeTimeContainerView()
    lazy var titleLabel = makeTitleLabel()
    lazy var lastButton = makeLastButton()
    lazy var playButton = makePlayButton()
    lazy var nextButton = makeNextButton()
    lazy var overallStackView = makeOverallStackView()
    
    lazy var avPlayer = makeAVPlayer()
    
    let vm = MaxPlayerViewModel()
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    let shrinkTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    
    
    var panGesture: UIPanGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        
        addBoundaryTimeObserver()
        addPlayerDidFinishObserver()
        addAVPlayerCurrentTimeObserver()
        
        bindUIComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}


extension MaxPlayerView: PlayerViewDataSource {
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}


extension MaxPlayerView: MinPlayerViewDelegate {
    func minPlayerViewPressPlayerButton(_ minPlayerView: MinPlayerView) {
        pressPlayerButton(sender: playButton)
    }
}


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
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
    }
    
    // - MARK: download episode
    fileprivate func playEpisodeUsingFileUrl() {
        
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
    
    func identityEpisodeImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrinkTransform
        })
    }
    
    func addAVPlayerCurrentTimeObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 2)
        avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            self?.vm.setCurrentTimeStr(currentTimeStr: time.toString())
            guard let durationTime = self?.avPlayer.currentItem?.duration else { return }
            self?.vm.setDurationTimeStr(durationTimeStr: durationTime.toString())
        }
    }
    
    func updateSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(avPlayer.currentTime())
        let durationSeconds = CMTimeGetSeconds(avPlayer.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.slider.value = Float(percentage)
    }
    
    func bindPlayButton() {
        vm.isPlaying.bind {[weak self] (isPlaying) in
            guard let isPlaying = isPlaying else { return }
            var buttonImage: UIImage
            if isPlaying {
                guard let _ = R.image.pause() else { return }
                buttonImage = R.image.pause()!
                self?.identityEpisodeImageView()
            }else {
                guard let _ = R.image.play() else { return }
                buttonImage = R.image.play()!
                self?.shrinkEpisodeImageView()
            }
            self?.playButton.setImage(buttonImage, for: .normal)
            self?.minPlayerView.setImageForPlayButton(image: buttonImage)
        }
    }
    
    func bindCurrentTimeLabel() {
        vm.currentTimeStr.bind {[weak self] (timeStr) in
            guard let timeStr = timeStr else { return }
            self?.currentTimeLabel.text = timeStr
            self?.updateSlider()
        }
    }
    
    func bindDurationTimeLabel() {
        vm.durationTimeStr.bind {[weak self] (timeStr) in
            guard let timeStr = timeStr else { return }
            self?.durationTimeLabel.text = timeStr
        }
    }
    
    func bindUIComponent() {
        bindPlayButton()
        bindCurrentTimeLabel()
        bindDurationTimeLabel()
    }
}
