//
//  MaxPlayerViewWithAVPlayer.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/25.
//

import AVKit
import MediaPlayer
import UIKit


extension MaxPlayerView {
    
    func makeAVPlayer() -> PodcastPlayer {
        let player = PodcastPlayer(dataSource: self, delegate: self)
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }
    
    func playEpisode() {
        podcastPlayer.playEpisode()
    }
}


// - MARK: PodcastPlayer Protocol
extension MaxPlayerView: PodcastPlayerDataSource {
    
    func podcastPlayerEpisode(_ podcastPlayer: PodcastPlayer) -> Episode {
        return episode
    }
}
    

extension MaxPlayerView: PodcastPlayerDelegate {
    
    func podcastPlayerHandleInterruption(_ podcastPlayer: PodcastPlayer, timeControlStatus: AVPlayer.TimeControlStatus) {
        vm.podcastPlayerStatus.value = timeControlStatus
    }
    
    func podcastPlayerTimeControlStatusDidCange(_ podcastPlayer: PodcastPlayer, timeControlStatus: AVPlayer.TimeControlStatus) {
        vm.podcastPlayerStatus.value = timeControlStatus
    }
    
    
    func podcastPlayerHandlePlaying(_ podcastPlayer: PodcastPlayer, episode: Episode) {}
    
    func podcastPlayerHandleObserveDidFinishPlaying(_ podcastPlayer: PodcastPlayer, notification: Notification) {
        vm.podcastPlayerStatus.value = .paused
        DownloadManager.deleteEpisode(episode: episode)
        pressNextButton(sender: nextButton)
    }
    
    func podcastPlayerHandleObserveEpisodeBoundaryTime(_ podcastPlayer: PodcastPlayer, times: [NSValue]) {
        vm.podcastPlayerStatus.value = .playing
        identityEpisodeImageView()
    }
    
    func podcastPlayerHandleObservePeriodicTime(_ podcastPlayer: PodcastPlayer, timeInterval: CMTime) {
        vm.currentTimeStr.value = timeInterval.toString()
        guard let durationTime = podcastPlayer.currentItem?.duration else { return }
        vm.durationTimeStr.value = durationTime.toString()
    }
}
