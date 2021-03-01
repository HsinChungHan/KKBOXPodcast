//
//  HomeVCViewModel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation


enum Action {
    case GoToEpisode
    case PlayEpisode
}


class HomeVCViewModel {
    
    let episodes = Bindable<[Episode]>.init(value: nil)
    let selectedEpisodeIndex = Bindable<Int>.init(value: nil)
    
    var action = Action.GoToEpisode
    
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
    
    func setSelectedEpisodeIndex(selectedIndex: Int) {
        guard let episodes = episodes.value else {
            print("🚨Episodes is nil!")
            return
        }
        if selectedIndex >= 0 && selectedIndex < episodes.count {
            self.selectedEpisodeIndex.setValue(value: selectedIndex)
        }else {
            print("This is the final episode!")
        }
    }
}
