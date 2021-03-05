//
//  MaxPlayerViewWithUI.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit
import AVKit

extension MaxPlayerView {
    
    func makeDismissButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.addTarget(self, action: #selector(pressDismissButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressDismissButton(sender: UIButton) {
        minimizeMaxPlayerView()
    }
    
    func makeMinPlayerView() -> MinPlayerView {
        let minPlayerView = MinPlayerView(playerViewDataSource: self, minPlayerViewDelegate: self)
        return minPlayerView
    }
    
    func makeEpisodeImageView() -> UIImageView {
        let imageView = UIImageView()
        let url = URL(string: episode.imageUrl ?? "")
        imageView.sd_setImage(with: url)
        imageView.transform = shrinkTransform
        return imageView
    }
    
    func makeTimeSlider() -> UISlider {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(handleTimeSlider(sender:event:)), for: .valueChanged)
        return slider
    }
    
    @objc func handleTimeSlider(sender: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            podcastPlayer.timeSliderValueDidCahnge(percentage: Float64(sender.value), eventPhase: touchEvent.phase)
        }
    }
    
    func makeCurrentTimeLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "--:--:--", numberOfLines: 1, fontSize: 12)
        label.sizeToFit()
        return label
    }
    
    func makeDurationLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "--:--:--", numberOfLines: 1, fontSize: 12)
        label.sizeToFit()
        return label
    }
    
    func makeTimeContainerView() -> UIView {
        let view = UIView()
        [currentTimeLabel, durationTimeLabel].forEach {
            view.addSubview($0)
        }
        currentTimeLabel.constraint(top: view.snp.top, bottom: view.snp.bottom, leading: view.snp.leading, trailing: nil)
        durationTimeLabel.constraint(top: view.snp.top, bottom: view.snp.bottom, leading: nil, trailing: view.snp.trailing)
        return view
    }
    
    func makeTitleLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: episode.title, numberOfLines: 2, fontSize: 16)
        return label
    }
    
    func makePlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.play(), for: .normal)
        button.addTarget(self, action: #selector(pressPlayerButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressPlayerButton(sender: UIButton) {
        podcastPlayer.timeControlStatusDidChange()
    }
    
    func makeNextButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.next(), for: .normal)
        button.addTarget(self, action: #selector(pressNextButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressNextButton(sender: UIButton) {
        maxPlayerViewDelegate?.maxPlayerViewGoToNextEpisode(self)
    }
    
    func makeLastButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.last(), for: .normal)
        button.addTarget(self, action: #selector(pressLastButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func pressLastButton(sender: UIButton) {
        maxPlayerViewDelegate?.maxPlayerViewGoToLastEpisode(self)
    }
    
    func makeButtonsStackView() -> UIStackView {
        let padding: CGFloat = 10.0
        let stackView = UIStackView()
        [lastButton, playButton, nextButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.axis = .horizontal
        stackView.spacing = padding
        stackView.distribution = .fill
        
        lastButton.snp.makeConstraints {
            $0.width.equalTo(80)
        }
        nextButton.snp.makeConstraints {
            $0.width.equalTo(80)
        }
        
        return stackView
    }
    
    func makeOverallStackView() -> UIStackView {
        let buttonsStackView = makeButtonsStackView()
        let padding: CGFloat = 10.0
        let stackView = UIStackView()
        [dismissButton, episodeImageView, slider, timeContainerView, titleLabel, buttonsStackView].forEach {
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
        buttonsStackView.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        return stackView
    }
    
    func setupLayout() {
        backgroundColor = .white
        
        let padding: CGFloat = 10.0
        addSubview(overallStackView)
        overallStackView.fillSuperView(padding: .init(top: padding, left: padding, bottom: padding, right: padding), ratio: 1.0)
        addSubview(minPlayerView)
        minPlayerView.constraint(top: snp.top, bottom: nil, leading: snp.leading, trailing: snp.trailing, size: .init(width: 0, height: 80))
    }
}
