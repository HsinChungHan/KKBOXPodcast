//
//  EpisodeViewController.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit


protocol EpisodeViewControllerDataSource: AnyObject {
    func episodeViewControllerEpisode(_ episodeViewController: EpisodeViewController) -> Episode
    func episodeViewControllerEpisodeIndex(_ episodeViewController: EpisodeViewController) -> Int
}


protocol EpisodeViewControllerDelegate: AnyObject {
    func episodeViewControllerGoToLastEpisode(_ episodeViewController: EpisodeViewController, selectedEpisodeIndex: Int)
    func episodeViewControllerGoToNextEpisode(_ episodeViewController: EpisodeViewController, selectedEpisodeIndex: Int)
}

class EpisodeViewController: UIViewController {
    
    weak var dataSource: EpisodeViewControllerDataSource?
    weak var delegate: EpisodeViewControllerDelegate?
    
    fileprivate var episode: Episode {
        guard let dataSource = dataSource else {
            fatalError("🚨 You have to set dataSource for EpisodeViewController!")
        }
        return dataSource.episodeViewControllerEpisode(self)
    }
    
    fileprivate var currentEpisodeIndex: Int {
        guard let dataSource = dataSource else {
            fatalError("🚨 You have to set dataSource for EpisodeViewController!")
        }
        return dataSource.episodeViewControllerEpisodeIndex(self)
    }
    
    fileprivate lazy var channelLabel = makeChannelLabel()
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var summaryLabelLabel = makeSummaryLabel()
    fileprivate lazy var episodeImageView = makeEpisodeImageView()
    fileprivate lazy var popMaxPlayerViewButton = makePopMaxPlayerViewButton()
    fileprivate lazy var maxPlayerView = makeMaxPlayerView()
    
    init(dataSource: EpisodeViewControllerDataSource, delegate: EpisodeViewControllerDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        maxPlayerView.setupConstraintsForMaxPlayerView()
    }
}


// MARK: - Lazy initialzition
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
    
    fileprivate func makePopMaxPlayerViewButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(R.image.play(), for: .normal)
        button.addTarget(self, action: #selector(popMaxPlayerView(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func popMaxPlayerView(sender: UIButton) {
        sender.isHidden = true
        maxPlayerView.maxmizeMaxPlayerView()
        maxPlayerView.setupAudioSession()
        maxPlayerView.playEpisode()
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let avatarContainerView = UIView()
        [episodeImageView, channelLabel, titleLabel].forEach {
            avatarContainerView.addSubview($0)
        }
        
        episodeImageView.fillSuperView()
        channelLabel.constraint(top: avatarContainerView.snp.top, bottom: nil, leading: avatarContainerView.snp.leading, trailing: avatarContainerView.snp.trailing, padding: .init(top: 10, left: 10, bottom: 10, right: 0), size: .init(width: 0, height: 25))
        titleLabel.constraint(top: channelLabel.snp.bottom, bottom: nil, leading: channelLabel.snp.leading, trailing: channelLabel.snp.trailing, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 50))
        
        let stackView = UIStackView()
        [avatarContainerView, summaryLabelLabel, popMaxPlayerViewButton].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let height = UIScreen.main.bounds.height / 10
        
        avatarContainerView.snp.makeConstraints {
            $0.height.equalTo(height * 4)
        }
        
        summaryLabelLabel.snp.makeConstraints {
            $0.height.equalTo(height * 4)
        }
        
        popMaxPlayerViewButton.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        
        view.addSubview(stackView)
        stackView.fillSuperView(padding: .init(top: 44, left: 10, bottom: 0, right: 10), ratio: 1.0)
        view.addSubview(maxPlayerView)
    }
    
    fileprivate func makeMaxPlayerView() -> MaxPlayerView{
        let playerView = MaxPlayerView.init(playerViewDataSource: self, maxPlayerViewDataSource: self, maxPlayerViewDelegate: self)
        return playerView
    }
    
    func popMaxPlayerView() {
        popMaxPlayerView(sender: popMaxPlayerViewButton)
    }
}


// MARK: - PlayerView Protocol
extension EpisodeViewController: PlayerViewDataSource {
    
    func playerViewEpisode(_ playerView: PlayerView) -> Episode {
        return episode
    }
}


// MARK: - MaxPlayerView Protocol
extension EpisodeViewController: MaxPlayerViewDataSource {
    
    func maxPlayerViewSuperview(_ maxPlayerView: MaxPlayerView) -> UIView {
        return view
    }
}


extension EpisodeViewController: MaxPlayerViewDelegate {
    
    func maxPlayerViewGoToLastEpisode(_ maxPlayerView: MaxPlayerView) {
        delegate?.episodeViewControllerGoToLastEpisode(self, selectedEpisodeIndex: currentEpisodeIndex + 1)
    }
    
    func maxPlayerViewGoToNextEpisode(_ maxPlayerView: MaxPlayerView) {
        delegate?.episodeViewControllerGoToNextEpisode(self, selectedEpisodeIndex: currentEpisodeIndex - 1)
    }
}
