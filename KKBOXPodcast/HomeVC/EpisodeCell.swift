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
    
    fileprivate func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 2
        return label
    }
    
    fileprivate func makePublishedDateLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = UIColor.purple
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
        publishedDateLabel.text = episode.pubDate.dateFormate()
    }
    
    fileprivate func setEpisodeImageView(episode: Episode) {
        // - MARK: add activity indicator
        let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
        episodeImageView.sd_setImage(with: url)
    }
}
