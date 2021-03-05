//
//  APIServiceTests.swift
//  KKBOXPodcastTests
//
//  Created by Chung Han Hsin on 2021/3/2.
//

import XCTest
@testable import KKBOXPodcast


class APIServiceTests: XCTestCase {
    
    var apiService: APIService!
    var testEpisode: Episode!
    var title: String!
    var streamUrl: String!
    
    override func setUp() {
        super.setUp()
        apiService = APIService.shared
        title = "Ep. 134 數位藝術的畢卡索｜特別來賓「寶博朋友說」 葛如鈞"
        streamUrl = "https://feeds.soundcloud.com/stream/994918048-daodutech-podcast-how-to-become-digital-arts-picasso-guest-daab-jo-chun-ko.mp3"
        testEpisode = Episode(title: title, pubDate: Date(), description: "", author: "", streamUrl: streamUrl, summary: "", imageUrl: nil, fileUrl: nil)
    }
    
    override func tearDown() {
        apiService = nil
        title = nil
        streamUrl = nil
        title = nil
        testEpisode = nil
        super.tearDown()
    }
    
    func testFetchEpisodes() {
        //given
        let promise = expectation(description: "fetch episodes")
        
        var responseEpisodes: [Episode]?
        var responseError: APIServiceError?
        
        //when
        apiService.fetchEpisodes { (episodes) in
            responseEpisodes = episodes
            promise.fulfill()
        } errorHandler: { (apiSevriceError) in
            responseError = apiSevriceError
        }
        wait(for: [promise], timeout: 5)
        
        //then
        XCTAssertNotNil(responseEpisodes)
        XCTAssertNil(responseError)
    }
    
    func testDownloadEpisode() {
        //given
        var responseError: APIServiceError?
        
        //when
        apiService.downloadEpisode(episode: testEpisode) { (error) in
            responseError = error
        }

        //then
        XCTAssertNil(responseError)
    }
}
