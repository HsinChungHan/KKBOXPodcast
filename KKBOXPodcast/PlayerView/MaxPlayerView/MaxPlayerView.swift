//
//  MaxPlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit

// - MARK: future work: modulize the player view
protocol MaxPlayerViewDataSource: AnyObject {
    func maxPlayerViewSuperview(_ maxPlayerView: MaxPlayerView) -> UIView
}

class MaxPlayerView: PlayerView {
    
    weak var maxPlayerViewDataSource: MaxPlayerViewDataSource?
    
    var superView: UIView {
        guard let dataSource = maxPlayerViewDataSource else {
            fatalError("🚨 You have to set dataSource for MaxPlayerViewDataSource!")
        }
        return dataSource.maxPlayerViewSuperview(self)
    }
    
    lazy var dismissButton = makeDismissButton()
    lazy var minPlayerView = makeMinPlayerView()
    lazy var episodeImageView = makeEpisodeImageView()
    lazy var slider = makeSlider()
    lazy var currentTimeLabel = makeCurrentTimeLabel()
    lazy var durationTimeLabel = makeDurationLabel()
    lazy var timeContainerView = makeTimeContainerView()
    lazy var titleLabel = makeTitleLabel()
    lazy var playButton = makePlayButton()
    lazy var overallStackView = makeOverallStackView()
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    var panGesture: UIPanGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MaxPlayerView: PlayerViewDataSource {
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}
