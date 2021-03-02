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
            var myEpisodes = episodes
            for (index, _) in episodes.enumerated() {
                self.episodesPubDateToStr(episode: &myEpisodes[index])
            }
            DispatchQueue.main.async {
                self.episodes.value = myEpisodes
            }
        } errorHandler: { (error) in
            print("🚨 Failed to get episodes!")
        }
    }
    
    fileprivate func episodesPubDateToStr(episode: inout Episode) {
        let formatter = Formatter()
        episode.pubDateFormattedStr = formatter.formattedDateString(date: episode.pubDate)
    }
    
    func setSelectedEpisodeIndex(selectedIndex: Int) {
        guard let episodes = episodes.value else {
            print("🚨Episodes is nil!")
            return
        }
        if selectedIndex >= 0 && selectedIndex < episodes.count {
            self.selectedEpisodeIndex.value = selectedIndex
        }else {
            print("This is the final episode!")
        }
    }
}
