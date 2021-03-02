//
//  APITest.swift
//  KKBOXPodcastTests
//
//  Created by Chung Han Hsin on 2021/3/2.
//

import XCTest
@testable import KKBOXPodcast


class APITest: XCTestCase {
    
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        urlSession = URLSession(configuration: .default)
    }
    
    override func tearDown() {
        super.tearDown()
        urlSession = nil
    }
    
    func request(url: String, timeout: TimeInterval) {
        let url = URL(string: url)
            let promise = expectation(description: "Completion handler invoked")
            var statusCode: Int?
            var responseError: Error?

            // when
            let dataTask = urlSession.dataTask(with: url!) { (data, response, error) in
                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseError = error
                promise.fulfill()
            }
            dataTask.resume()
            wait(for: [promise], timeout: timeout)

            // then
            XCTAssertNil(responseError)
            XCTAssertEqual(statusCode, 200)
    }
    
    // test whether url is alive or not
    func testPodcastUrl() {
        request(url: APIService.podcastUrl, timeout: 5)
    }
    
    func testSteamingUrl() {
        let url = "https://feeds.soundcloud.com/stream/994918048-daodutech-podcast-how-to-become-digital-arts-picasso-guest-daab-jo-chun-ko.mp3"
        request(url: url, timeout: 40)
    }
}
