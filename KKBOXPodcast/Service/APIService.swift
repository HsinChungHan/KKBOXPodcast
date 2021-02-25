//
//  APIService.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation
import Alamofire
import FeedKit


enum APIServiceError {
    case URLError
    case ParseError
    case FeedError
}


extension Notification.Name {
    
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}


class APIService {
    
    typealias EpisodeDownloadComplete = (fileUrl: String, episodeTitle: String)
    let podcastUrl = "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss"
    static let shared = APIService()
    
    func fetchEpisodes(completionHandler: @escaping ([Episode]) -> (), errorHandler: @escaping (APIServiceError) -> ()) {
        guard let url = URL(string: podcastUrl) else {
            errorHandler(.URLError)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            
            parser.parseAsync { (result) in
                
                switch result {
                case .success(let feed):
                    guard let rssfeed = feed.rssFeed else {
                        errorHandler(.FeedError)
                        return
                    }
                    completionHandler(rssfeed.toEpisodes())
                    
                case .failure(let error):
                    print("🚨 Failed to parse feed: \(error)")
                    errorHandler(.ParseError)
                }
            }
        }
    }
    
    func downloadEpisode(episode: Episode) {
        let url = episode.streamUrl
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(episode.title).mp3")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination)
            .downloadProgress { (progress) in
                NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            }
            .response { (response) in
                print("\(episode.title) is download successfully!")
                
                if let error = response.error {
                    print("🚨response error! \(error)")
                    return
                }
                
                guard let filePath = response.fileURL?.absoluteString else {
                    print("🚨filePath is nil!")
                    return
                }
                
                let episodeDownloadComplete = EpisodeDownloadComplete(fileUrl: filePath, episodeTitle: episode.title)
                NotificationCenter.default.post(name: .downloadProgress, object: episodeDownloadComplete, userInfo: nil)
                
                self.updateDownloadedEpisodFilePath(episode: episode, filePath: filePath)
            }
    }
    
    fileprivate func updateDownloadedEpisodFilePath(episode: Episode, filePath: String) {
        // find download episode and update it's file path
        UserDefaults.standard.saveEpisode(episode: episode)
        var downloadedEpisodes = UserDefaults.standard.getEpisodes()
        guard let episodeIndex = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author}) else {
            // - MARK: failed to find downloaded episode in user default
            print("🚨Failed to find downloaded episode in user default!")
            return
        }
        downloadedEpisodes[episodeIndex].fileUrl = filePath
        
        // save new downloadedEpisodes into user default
        do {
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.setValue(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let error {
            // - MARK: failed to write into user default
            print("🚨Failed to write into user default! \(error)")
        }
    }
}


extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]() // blank Episode array
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            
            episodes.append(episode)
        })
        return episodes
    }
}
