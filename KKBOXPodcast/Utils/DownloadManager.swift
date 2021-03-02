//
//  DownloadManager.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/3/2.
//

import Foundation


class DownloadManager {
    
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    static func saveEpisode(episode: Episode) {
        do {
            var episodes = getEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: DownloadManager.downloadedEpisodesKey)
            print("Successfully save episode: \(episode.title)")
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
   static func getEpisodes() -> [Episode] {
        var episodes = [Episode]()
        guard let episodesData = UserDefaults.standard.data(forKey: DownloadManager.downloadedEpisodesKey) else { return episodes }
        do {
            episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return episodes
    }
    
   static func getSpecificEpisode(episode: Episode) -> Episode? {
        let downloadedEpisodes = getEpisodes()
        guard let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author}) else {
            return nil
        }
        return downloadedEpisodes[episodeIndex]
    }
    
   static func deleteEpisode(episode: Episode) {
        let downloadedEpisodes = getEpisodes()
        let filteredEpisodes = downloadedEpisodes.filter { (downloadedEpisode) -> Bool in
            return episode.title != downloadedEpisode.title
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: DownloadManager.downloadedEpisodesKey)
            print("Successfully delete episode: \(episode.title)")
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    static func updateDownloadedEpisodFilePath(episode: Episode, filePath: String) {
        // find download episode and update it's file path
        saveEpisode(episode: episode)
        var downloadedEpisodes = getEpisodes()
        guard let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author}) else {
            // - MARK: failed to find downloaded episode in user default
            print("🚨Failed to find downloaded episode in user default!")
            return
        }
        downloadedEpisodes[episodeIndex].fileUrl = filePath
        
        // save new downloadedEpisodes into user default
        do {
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.setValue(data, forKey: DownloadManager.downloadedEpisodesKey)
        } catch let error {
            // - MARK: failed to write into user default
            print("🚨Failed to write into user default! \(error)")
        }
    }
}
