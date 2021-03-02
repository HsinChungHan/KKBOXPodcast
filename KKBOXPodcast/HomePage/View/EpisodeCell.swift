//
//  EpisodeCell.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit
import SDWebImage
import SnapKit

class EpisodeCell: UITableViewCell {
    static let cellId = "EpisodeCellID"
    
    private(set) var episode: Episode? {
        didSet {
            guard let episode = episode else {
                print("🚨 You have to set episode for EpisodeCell!")
                return
            }
            setTitleLabel(episode: episode)
            setPublishedDateLabel(episode: episode)
            setEpisodeImageView(episode: episode)
        }
    }
    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var publishedDateLabel = makePublishedDateLabel()
    fileprivate lazy var episodeImageView = makeEpisodeImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: EpisodeCell.cellId)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension EpisodeCell {
    
    func setEpisode(episode: Episode) {
        self.episode = episode
    }
    
    func setupLayout() {
        [titleLabel, publishedDateLabel, episodeImageView].forEach {
            addSubview($0)
        }
        
        episodeImageView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.width.equalTo(100)
            $0.leading.equalTo(snp.leading).offset(16)
            $0.centerY.equalTo(snp.centerY)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.top.equalTo(episodeImageView.snp.top)
            $0.leading.equalTo(episodeImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(snp.trailing).offset(-16)
        }
        
        publishedDateLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.bottom.equalTo(episodeImageView.snp.bottom)
            $0.leading.equalTo(episodeImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(snp.trailing).offset(-16)
        }
    }
    
    fileprivate func makeTitleLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "", numberOfLines: 2, fontSize: 20)
        return label
    }
    
    fileprivate func makePublishedDateLabel() -> BoldLabel {
        let label = BoldLabel()
        label.setLabel(text: "", numberOfLines: 1, fontSize: 12)
        return label
    }
    
    fileprivate func makeEpisodeImageView() -> UIImageView {
        let imageView = UIImageView()
        return imageView
    }
    
    fileprivate func setTitleLabel(episode: Episode) {
        titleLabel.text = episode.title
    }
    
    fileprivate func setPublishedDateLabel(episode: Episode) {
        publishedDateLabel.text = episode.pubDateFormattedStr
    }
    
    fileprivate func setEpisodeImageView(episode: Episode) {
        // - MARK: add activity indicator
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        episodeImageView.sd_setImage(with: url)
    }
}
