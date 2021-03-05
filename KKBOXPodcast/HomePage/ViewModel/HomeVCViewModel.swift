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
    
    func fetchEpisodes(completionHandler: @escaping ([Episode]) -> Void) {
        APIService.shared.fetchEpisodes { (episodes) in
            var myEpisodes = episodes
            let formatter = Formatter()
            for (index, _) in episodes.enumerated() {
                myEpisodes[index].pubDateFormattedStr = formatter.formattedDateString(date: myEpisodes[index].pubDate)
            }
            DispatchQueue.main.async {
                self.episodes.value = myEpisodes
                completionHandler(myEpisodes)
            }
        } errorHandler: { (error) in
            print("🚨 Failed to get episodes!")
        }
    }
     
    func setSelectedEpisodeIndexValue(selectedIndex: Int) {
        guard let episodes = episodes.value else {
            print("🚨Episodes is nil!")
            return
        }
        setSelectedEpisodeIndex(episdoesCount: episodes.count, selectedIndex: selectedIndex)
    }
    
    func setSelectedEpisodeIndex(episdoesCount: Int, selectedIndex: Int) {
        if selectedIndex >= 0 && selectedIndex < episdoesCount {
            self.selectedEpisodeIndex.value = selectedIndex
        }
    }
}
