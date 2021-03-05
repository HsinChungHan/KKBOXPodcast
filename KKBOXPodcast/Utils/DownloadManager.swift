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
            guard var episodes = getEpisodes() else {
                return
            }
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: DownloadManager.downloadedEpisodesKey)
            print("Successfully save episode: \(episode.title)")
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
   static func getEpisodes() -> [Episode]? {
        var episodes: [Episode]?
        guard let episodesData = UserDefaults.standard.data(forKey: DownloadManager.downloadedEpisodesKey) else { return episodes }
        do {
            episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }
        return episodes
    }
    
    static func getSpecificEpisode(title: String, author: String) -> Episode? {
        guard let downloadedEpisodes = getEpisodes(), let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == title && $0.author == author}) else {
            return nil
        }
        return downloadedEpisodes[episodeIndex]
    }
    
    @discardableResult
    static func deleteEpisode(title: String) -> Bool {
        guard let downloadedEpisodes = getEpisodes() else {
            return false
        }
        let filteredEpisodes = downloadedEpisodes.filter { (downloadedEpisode) -> Bool in
            return title != downloadedEpisode.title
        }
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: DownloadManager.downloadedEpisodesKey)
            print("Successfully delete episode: \(title)")
            return true
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
            return false
        }
    }
    
    static func updateDownloadedEpisodFilePath(episode: Episode, filePath: String) {
        // find download episode and update it's file path
        saveEpisode(episode: episode)
        
        guard var downloadedEpisodes = getEpisodes(), let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author}) else {
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
