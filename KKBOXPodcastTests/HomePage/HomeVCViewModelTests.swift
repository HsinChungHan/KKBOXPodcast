//
//  HomeVCViewModelTests.swift
//  KKBOXPodcastTests
//
//  Created by Chung Han Hsin on 2021/3/2.
//

import XCTest
@testable import KKBOXPodcast


class HomeVCViewModelTests: XCTestCase {
    var vm: HomeVCViewModel!
    
    override func setUp() {
        super.setUp()
        vm = HomeVCViewModel()
    }
    
    override func tearDown() {
        vm = nil
        super.tearDown()
    }
    
    func testSelectedEpisodeIndex() {
        vm.setSelectedEpisodeIndex(episdoesCount: 10, selectedIndex: 5)
        let result = vm.selectedEpisodeIndex.value
        XCTAssertEqual(result, 5, "selectedEpisodeIndex should be as same as selectedIndex, cause selectedIndex is in the range of episdoesCount")
        vm.setSelectedEpisodeIndex(episdoesCount: 10, selectedIndex: -1)
        XCTAssertEqual(vm.selectedEpisodeIndex.value, 5, "selectedEpisodeIndex shouldn't change, cause selectedIndex is out of the range of episdoesCount")
        vm.setSelectedEpisodeIndex(episdoesCount: 10, selectedIndex: 11)
        XCTAssertEqual(vm.selectedEpisodeIndex.value, 5, "selectedEpisodeIndex shouldn't change, cause selectedIndex is out of the range of episdoesCount")
    }
    
    func testFetchEpisodes() {
        let promise = expectation(description: "fetchEpisodes completion handler invoked")
        vm.fetchEpisodes { _ in
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        XCTAssert(vm.episodes.value != nil)
    }
}
