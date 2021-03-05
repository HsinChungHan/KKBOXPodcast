//
//  DownloadManagerTest.swift
//  KKBOXPodcastTests
//
//  Created by Chung Han Hsin on 2021/3/3.
//

import XCTest
@testable import KKBOXPodcast

class DownloadManagerTest: XCTestCase {
    var testEpisode: Episode!
    var title: String!
    var fileUrl: String!
    var author: String!
    
    override func setUp() {
        super.setUp()
        title = "testTitle"
        fileUrl = "testFileUrl"
        author = "testAuthor"
        testEpisode = Episode(title: title, pubDate: Date(), description: "", author: author, streamUrl: "", summary: "", imageUrl: nil, fileUrl: fileUrl)
    }
    
    override func tearDown() {
        title = nil
        fileUrl = nil
        author = nil
        testEpisode = nil
        super.tearDown()
    }
    
    func testSaveEpisode() {
        DownloadManager.saveEpisode(episode: testEpisode)
        var episodes: [Episode]?
        
        guard let episodesData = UserDefaults.standard.data(forKey: DownloadManager.downloadedEpisodesKey) else {
            XCTFail("UserDefaults should have download episodes")
            return
        }
        
        do {
            episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
        } catch _ {
            XCTFail("Failed to decode episodesData")
            return
        }
        
        guard let _ = episodes, let episodeIndex = episodes!.firstIndex(where: { $0.title == title && $0.author == author}) else {
            XCTFail("Failed to find episode")
            return
        }
        
        XCTAssertEqual(episodes![episodeIndex].title, title)
        XCTAssertEqual(episodes![episodeIndex].author, author)
        XCTAssertEqual(episodes![episodeIndex].fileUrl, fileUrl)
    }
    
    func testGetEpisode() {
        XCTAssertNotNil(DownloadManager.getEpisodes())
    }
    
    func testGetSpecificEpisode() {
        XCTAssertNotNil(DownloadManager.getSpecificEpisode(title: title, author: author))
    }
    
    func testDeleteEpisode() {
        XCTAssertEqual(DownloadManager.deleteEpisode(title: title), true)
    }
    
    func testUpdateDownloadedEpisodFilePath() {
        DownloadManager.updateDownloadedEpisodFilePath(episode: testEpisode, filePath: fileUrl)
        guard let episode = DownloadManager.getSpecificEpisode(title: title, author: author) else {
            XCTFail("Failed to find episode")
            return
        }
        XCTAssertEqual(episode.fileUrl, fileUrl)
    }
}
