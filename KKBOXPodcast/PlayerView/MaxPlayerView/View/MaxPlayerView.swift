//
//  MaxPlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import AVKit
import MediaPlayer
import UIKit


// MARK: future work: modulize the player view

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


// MARK: - Bindable
extension MaxPlayerView {
    
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
    
    func updateSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(avPlayer.currentTime())
        let durationSeconds = CMTimeGetSeconds(avPlayer.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.slider.value = Float(percentage)
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


// MARK: - PlayerView Protocol
extension MaxPlayerView: PlayerViewDataSource {
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}


// MARK: - MinPlayerView Protocol
extension MaxPlayerView: MinPlayerViewDelegate {
    func minPlayerViewPressPlayerButton(_ minPlayerView: MinPlayerView) {
        pressPlayerButton(sender: playButton)
    }
}
