//
//  PlayerView.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit


protocol PlayerViewDataSource: AnyObject {
    
    func playerViewEpisode(_ playerView: PlayerView) -> Episode
}


class PlayerView: UIView {
    
    weak var playerViewDataSource: PlayerViewDataSource?
    
    init(playerViewDataSource: PlayerViewDataSource) {
        self.playerViewDataSource = playerViewDataSource
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var episode: Episode {
        guard let dataSource = playerViewDataSource else {
            fatalError("🚨 You have to set dataSource for PlayerView!")
        }
        return dataSource.playerViewEpisode(self)
    }
}
