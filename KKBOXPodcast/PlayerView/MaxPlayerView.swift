//
//  MaxPlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit


class MaxPlayerView: PlayerView {
    
    fileprivate lazy var dismissButton = makeDismissButton()
    fileprivate lazy var minPlayerView = makeMinPlayerView()
    fileprivate lazy var episodeImageView = makeEpisodeImageView()
    fileprivate lazy var slider = makeSlider()
    fileprivate lazy var currentTimeLabel = makeCurrentTimeLabel()
    fileprivate lazy var durationTimeLabel = makeDurationLabel()
    fileprivate lazy var timeContainerView = makeTimeContainerView()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var playButton = makePlayButton()
    fileprivate lazy var overallStackView = makeOverallStackView()
    
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MaxPlayerView {
    
    fileprivate func makeDismissButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.addTarget(self, action: #selector(pressDismissButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressDismissButton(sender: UIButton) {
        // - MARK: dismiss audio player view...
        guard let superView = superview else {
            return
        }
        minimizeMaxPlayerView(superView: superView)
    }
    
    fileprivate func makeMinPlayerView() -> MinPlayerView {
        let minPlayerView = MinPlayerView()
        minPlayerView.alpha = 0.0
        minPlayerView.dataSource = self
        minPlayerView.setupLayout()
        return minPlayerView
    }
    
    fileprivate func makeEpisodeImageView() -> UIImageView {
        let imageView = UIImageView()
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        imageView.sd_setImage(with: url)
        return imageView
    }
    
    fileprivate func makeSlider() -> UISlider {
        let slider = UISlider()
        return slider
    }
    
    fileprivate func makeCurrentTimeLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "00:00:00", numberOfLines: 1, fontSize: 12)
        label.sizeToFit()
        return label
    }
    
    fileprivate func makeDurationLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "00:00:00", numberOfLines: 1, fontSize: 12)
        label.sizeToFit()
        return label
    }
    
    fileprivate func makeTimeContainerView() -> UIView {
        let view = UIView()
        [currentTimeLabel, durationTimeLabel].forEach {
            view.addSubview($0)
        }
        currentTimeLabel.constraint(top: view.snp.top, bottom: view.snp.bottom, leading: view.snp.leading, trailing: nil)
        durationTimeLabel.constraint(top: view.snp.top, bottom: view.snp.bottom, leading: nil, trailing: view.snp.trailing)
        return view
    }
    
    fileprivate func makeTitleLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: episode.title, numberOfLines: 2, fontSize: 16)
        return label
    }
    
    fileprivate func makePlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.play(), for: .normal)
        button.addTarget(self, action: #selector(pressPlayerButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressPlayerButton(sender: UIButton) {
        // - MARK: play or pause audio player view
    }
    
    fileprivate func makeOverallStackView() -> UIStackView {
        let padding: CGFloat = 10.0
        let stackView = UIStackView()
        [dismissButton, episodeImageView, slider, timeContainerView, titleLabel, playButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.axis = .vertical
        stackView.spacing = padding
        stackView.distribution = .fill
        
        let screenHeight = UIScreen.main.bounds.height
        let episodeImageViewHeight = UIScreen.main.bounds.width - padding * 2
        let timeContainerViewHeight: CGFloat = 20.0
        let sliderHeight: CGFloat = 20.0
        let height = (screenHeight - episodeImageViewHeight - timeContainerViewHeight - sliderHeight) / 3
        
        dismissButton.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        episodeImageView.snp.makeConstraints {
            $0.height.equalTo(episodeImageViewHeight)
        }
        slider.snp.makeConstraints {
            $0.height.equalTo(sliderHeight)
        }
        timeContainerView.snp.makeConstraints {
            $0.height.equalTo(timeContainerViewHeight)
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        playButton.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        return stackView
    }
    
    func setupLayout() {
        let padding: CGFloat = 10.0
        addSubview(overallStackView)
        overallStackView.fillSuperView(padding: .init(top: padding, left: padding, bottom: padding, right: padding), ratio: 1.0)
        addSubview(minPlayerView)
        minPlayerView.constraint(top: snp.top, bottom: nil, leading: snp.leading, trailing: snp.trailing, size: .init(width: 0, height: 80))
    }
}


// - MARK: Minimize and maxmize the player view
extension MaxPlayerView {
    
    func setupConstraintsForMaxPlayerView(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = topAnchor.constraint(equalTo: superView.topAnchor, constant: superView.frame.height)
        
        bottomAnchorConstraint = bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: superView.frame.height)
        
        // minPlayerView's height is 80
        minimizedTopAnchorConstraint = topAnchor.constraint(equalTo: superView.bottomAnchor, constant: -80)
        
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true
    }
    
    func maxmizeMaxPlayerView(superView: UIView) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            superView.layoutIfNeeded()
            self.overallStackView.alpha = 1
            self.minPlayerView.alpha = 0.0
        }
        
    }
    
    func minimizeMaxPlayerView(superView: UIView) {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = superView.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            superView.layoutIfNeeded()
            self.overallStackView.alpha = 0.0
            self.minPlayerView.alpha = 1.0
        }
    }
}


extension MaxPlayerView: PlayerViewDataSource {
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}
