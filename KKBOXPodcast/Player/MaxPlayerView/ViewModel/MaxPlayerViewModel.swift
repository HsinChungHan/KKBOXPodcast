//
//  MaxPlayerViewModel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import Foundation


class MaxPlayerViewModel {
    
    let isPlaying = Bindable<Bool>.init(value: false)
    let currentTimeStr = Bindable<String>.init(value: nil)
    let durationTimeStr = Bindable<String>.init(value: nil)
    
    private(set) var isUsingDownloadedEpisode = false
    
    func setIsPlaying(isPlaying: Bool) {
        self.isPlaying.setValue(value: isPlaying)
    }
    
    func setCurrentTimeStr(currentTimeStr: String) {
        self.currentTimeStr.setValue(value: currentTimeStr)
    }
    
    func setDurationTimeStr(durationTimeStr: String) {
        self.durationTimeStr.setValue(value: durationTimeStr)
    }
    
    func setIsUsingDownloadedEpisode(isUsingDownloadedEpisode: Bool) {
        self.isUsingDownloadedEpisode = isUsingDownloadedEpisode
    }
}
