//
//  MaxPlayerViewModel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import Foundation
import AVKit


class MaxPlayerViewModel {
    
    let podcastPlayerStatus = Bindable<AVPlayer.TimeControlStatus>.init(value: .paused)
    let currentTimeStr = Bindable<String>.init(value: nil)
    let durationTimeStr = Bindable<String>.init(value: nil)
}
