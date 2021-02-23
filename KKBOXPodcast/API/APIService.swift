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

class APIService {
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
