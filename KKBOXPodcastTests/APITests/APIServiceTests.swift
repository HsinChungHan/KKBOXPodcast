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
    
    override func setUp() {
        super.setUp()
        apiService = APIService.shared
    }
    
    override func tearDown() {
        super.tearDown()
        apiService = nil
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
        let promise = expectation(description: "download episode")
        
        var response: (String, String)?
        var responseError: APIServiceError?
        
        //when
        let url = "https://feeds.soundcloud.com/stream/994918048-daodutech-podcast-how-to-become-digital-arts-picasso-guest-daab-jo-chun-ko.mp3"
        let title = "Ep. 134 數位藝術的畢卡索｜特別來賓「寶博朋友說」 葛如鈞"
        apiService.downloadEpisode(url: url, episodeTitle: title) { (filePath, title) in
            response = (filePath, title)
            promise.fulfill()
        } errorHandler: { (error) in
            responseError = error
        }

        // cause download takes lots of time, so maybe you can set timeout to 60
        wait(for: [promise], timeout: 40)

        //then
        XCTAssertNotNil(response)
        XCTAssertNil(responseError)
    }
}
