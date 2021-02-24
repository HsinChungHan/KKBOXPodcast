//
//  EpisodeViewController.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit


protocol EpisodeViewControllerDataSource: AnyObject {
    func episodeViewControllerEpisode(_ episodeViewController: EpisodeViewController) -> Episode
}


class EpisodeViewController: UIViewController {
    
    weak var dataSource: EpisodeViewControllerDataSource?
    var episode: Episode {
        guard let dataSource = dataSource else {
            fatalError("🚨 You have to set dataSource for EpisodeViewController!")
        }
        return dataSource.episodeViewControllerEpisode(self)
    }
    
    lazy var channelLabel = makeChannelLabel()
    lazy var titleLabel = makeTitleLabel()
    lazy var summaryLabelLabel = makeSummaryLabel()
    lazy var episodeImageView = makeEpisodeImageView()
    lazy var pushPlayerButton = makePushPlayerButton()
    
    lazy var maxPlayerView = makeMaxPlayerView()
//    var maximizedTopAnchorConstraint: NSLayoutConstraint!
//    var minimizedTopAnchorConstraint: NSLayoutConstraint!
//    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        maxPlayerView.setupConstraintsForMaxPlayerView(superView: view)
    }
}


extension EpisodeViewController {
    
    fileprivate func makeChannelLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: episode.author, numberOfLines: 2, fontSize: 30)
        return label
    }
    
    fileprivate func makeTitleLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: episode.title, numberOfLines: 2, fontSize: 16)
        return label
    }
    
    fileprivate func makeEpisodeImageView() -> UIImageView {
        let imageView = UIImageView()
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        imageView.sd_setImage(with: url)
        return imageView
    }
    
    fileprivate func makeSummaryLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: episode.summary, numberOfLines: 0, fontSize: 16)
        return label
    }
    
    fileprivate func makePushPlayerButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.play(), for: .normal)
        button.addTarget(self, action: #selector(goToPlayerView(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func goToPlayerView(sender: UIButton) {
        // - MARK: pop up audio player view...
        maxPlayerView.maxmizeMaxPlayerView(superView: view)
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let avatarContainerView = UIView()
        [episodeImageView, channelLabel, titleLabel].forEach {
            avatarContainerView.addSubview($0)
        }
        
        let stackView = UIStackView()
        [avatarContainerView, summaryLabelLabel, pushPlayerButton].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        
        episodeImageView.fillSuperView()
        channelLabel.constraint(top: avatarContainerView.snp.top, bottom: nil, leading: avatarContainerView.snp.leading, trailing: avatarContainerView.snp.trailing, padding: .init(top: 10, left: 10, bottom: 10, right: 0), size: .init(width: 0, height: 25))
        titleLabel.constraint(top: channelLabel.snp.bottom, bottom: nil, leading: channelLabel.snp.leading, trailing: channelLabel.snp.trailing, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 50))
        
        let height = UIScreen.main.bounds.height / 3
        
        avatarContainerView.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        
        summaryLabelLabel.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        
        pushPlayerButton.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        
        view.addSubview(stackView)
        stackView.fillSuperView(padding: .init(top: 44, left: 10, bottom: 0, right: 10), ratio: 1.0)
        view.addSubview(maxPlayerView)
    }
    
    fileprivate func makeMaxPlayerView() -> MaxPlayerView{
        let playerView = MaxPlayerView()
        playerView.dataSource = self
        playerView.setupLayout()
        return playerView
    }
    
    
}


extension EpisodeViewController: PlayerViewDataSource {
    
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}
