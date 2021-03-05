//
//  Episode.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation
import FeedKit


// - FIXME: cauz of KKBOX assigment, this model layer should be implemented by Objc
struct Episode: Codable {
    let title: String
    let pubDate: Date
    let description: String
    let author: String
    let streamUrl: String
    let summary: String
    var imageUrl: String?
    
    var fileUrl: String?
    var pubDateFormattedStr: String = ""
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.summary = feedItem.iTunes?.iTunesSummary ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
    
    init(title: String, pubDate: Date, description: String, author: String, streamUrl: String, summary: String, imageUrl: String?, fileUrl: String?) {
        self.title = title
        self.pubDate = pubDate
        self.description = description
        self.author = author
        self.streamUrl = streamUrl
        self.summary = summary
        self.imageUrl = imageUrl
        self.fileUrl = fileUrl
    }
}
