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
    case DownloadError
}


extension Notification.Name {
    
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}


class APIService {
    
    static let podcastUrl = "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss"
    
    typealias EpisodeDownloadComplete = (fileUrl: String, episodeTitle: String)
    
    static let shared = APIService()
    
    func fetchEpisodes(completionHandler: @escaping ([Episode]) -> Void, errorHandler: @escaping (APIServiceError) -> Void) {
        guard let url = URL(string: APIService.podcastUrl) else {
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
    
    func downloadEpisode(episode: Episode, errorHandler: @escaping (APIServiceError) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(episode.title).mp3")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(episode.streamUrl, to: destination)
            .downloadProgress { (progress) in
                NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            }
            .response { (response) in
                if let error = response.error {
                    print("🚨response error! \(error)")
                    return
                }
                
                guard let filePath = response.fileURL?.absoluteString else {
                    print("🚨filePath is nil!")
                    return
                }
                
                let episodeDownloadComplete = EpisodeDownloadComplete(fileUrl: filePath, episodeTitle: episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                print("\(episode.title) is download successfully!")
                DownloadManager.saveEpisode(episode: episode)
                DownloadManager.updateDownloadedEpisodFilePath(episode: episode, filePath: filePath)
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
