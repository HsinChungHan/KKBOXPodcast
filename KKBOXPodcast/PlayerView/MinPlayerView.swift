//
//  MinPlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit


class MinPlayerView: PlayerView {
    
    fileprivate lazy var episodeImageView = makeEpisodeImageView()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var playButton = makePlayButton()
}


extension MinPlayerView {
    
    fileprivate func makeEpisodeImageView() -> UIImageView {
        let imageView = UIImageView()
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        imageView.sd_setImage(with: url)
        return imageView
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
    
    func setupLayout() {
        let stackView = UIStackView()
        [episodeImageView, titleLabel, playButton].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fill
        
        addSubview(stackView)
        stackView.fillSuperView(padding: .init(top: 10, left: 10, bottom: 10, right: 10), ratio: 1.0)
        let screenWidth = UIScreen.main.bounds.width
        let iconWidth: CGFloat = 60.0
        let titleWidth = screenWidth - iconWidth * 2
        episodeImageView.snp.makeConstraints {
            $0.width.equalTo(iconWidth)
        }
        playButton.snp.makeConstraints {
            $0.width.equalTo(iconWidth)
        }
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(titleWidth)
        }
    }
}
