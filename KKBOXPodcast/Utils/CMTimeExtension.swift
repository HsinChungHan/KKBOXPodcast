//
//  CMTimeExtension.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import AVKit


extension CMTime {
    
    func toString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds % (60 * 60) / 60
        let hours = totalSeconds / 60 / 60
        let timeFormatString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeFormatString
    }
}

