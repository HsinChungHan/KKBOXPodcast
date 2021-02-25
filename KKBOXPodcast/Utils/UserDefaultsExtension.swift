//
//  UserDefaultsExtension.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/25.
//

import Foundation


extension UserDefaults {
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    func saveEpisode(episode: Episode) {
        do {
            var episodes = getEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            print("Successfully save episode: \(episode.title)")
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func getEpisodes() -> [Episode] {
        var episodes = [Episode]()
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return episodes }
        do {
            episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return episodes
    }
    
    func getEpisode(episode: Episode) -> Episode? {
        let downloadedEpisodes = self.getEpisodes()
        guard let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author}) else {
            return nil
        }
        return downloadedEpisodes[episodeIndex]
    }
    
    func deleteEpisode(episode: Episode) {
        let downloadedEpisodes = self.getEpisodes()
        let filteredEpisodes = downloadedEpisodes.filter { (episode) -> Bool in
            return episode.title != episode.title
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            print("Successfully delete episode: \(episode.title)")
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
}
