//
//  HomeVCViewModel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation


class HomeVCViewModel {
    
    private(set) lazy var episodes = Bindable<[Episode]>.init(value: nil)
    
    var selectedEpisode: Episode?
    
    func fetchEpisodes() {
        APIService.shared.fetchEpisodes { (episodes) in
            DispatchQueue.main.async {
                self.episodes.setValue(value: episodes)
                print(episodes.count)
            }
        } errorHandler: { (error) in
            print("🚨 Failed to get episodes!")
        }
    }
}
