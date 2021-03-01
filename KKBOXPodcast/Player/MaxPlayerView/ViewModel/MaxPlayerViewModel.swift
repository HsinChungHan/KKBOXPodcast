//
//  MaxPlayerViewModel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import Foundation


class MaxPlayerViewModel {
    
    let podcastPlayerStatus = Bindable<PodcastPlayerStatus>.init(value: .pause)
    let currentTimeStr = Bindable<String>.init(value: nil)
    let durationTimeStr = Bindable<String>.init(value: nil)
}
