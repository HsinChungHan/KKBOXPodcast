//
//  HomeViewController.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit
import SnapKit


class HomeViewController: UIViewController {
    
    fileprivate lazy var tableView = makeTableView()
    fileprivate let episodeCellId = "EpisodeCellID"
    fileprivate let vm = HomeVCViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell()
        setupLayout()
        vm.fetchEpisodes()
        bindEpisodes()
        bindSelectedIndex()
    }
}


// MARK: - Lazy Initialization
extension HomeViewController {
    
    fileprivate func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }
    
    fileprivate func registerTableViewCell() {
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: episodeCellId)
    }
    
    fileprivate func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.bottom.equalTo(view.snp.bottom)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
        }
    }
    
    fileprivate func bindEpisodes() {
        vm.episodes.bind {[weak self] (episodes) in
            guard let _ = episodes else {
                print("🚨Episodes is nil!")
                return
            }
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func bindSelectedIndex() {
        vm.selectedEpisodeIndex.bind {[weak self] (selectedIndex) in
            guard let selectedIndex = selectedIndex else {
                print("🚨SelectedIndex is nil!")
                return
            }
            self?.dismiss(animated: true)
            self?.goToEpisode(selectedIndex: selectedIndex)
        }
    }
    
    // - FIXME: move to coordinator
    fileprivate func goToEpisode(selectedIndex: Int) {
        let episodeVC = EpisodeViewController()
        episodeVC.dataSource = self
        episodeVC.delegate = self
        present(episodeVC, animated: true) {
            if self.vm.action == .PlayEpisode {
                episodeVC.popMaxPlayerView()
            }
        }
    }
}


// MARK: - UITableView Protocol
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodes = vm.episodes.value else {
            return 0
        }
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: episodeCellId, for: indexPath) as! EpisodeCell
        guard let episodes = vm.episodes.value else {
            return cell
        }
        cell.setupLayout()
        cell.setEpisode(episode: episodes[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // imageView height = 100
        // up padding and bottom padding = 16
        return 100 + 16 * 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.setSelectedEpisodeIndex(selectedIndex: indexPath.item)
        vm.setAction(action: .GoToEpisode)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .normal, title: nil) { [weak self] (contextualAction, view, boolValue) in
            guard let self = self else {
                return
            }
            print("Download and save episode into UserDefaults")
            self.downloadEpisode(selectedIndex: indexPath.row)
        }
        item.image = R.image.download()
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
    
    fileprivate func downloadEpisode(selectedIndex: Int) {
        guard let episodes = self.vm.episodes.value else {
            print("🚨 You have to set episodes!")
            return
        }
        APIService.shared.downloadEpisode(episode: episodes[selectedIndex])
    }
}


// MARK: - EpisodeViewController Protocol
extension HomeViewController: EpisodeViewControllerDataSource {
    
    func episodeViewControllerEpisodeIndex(_ episodeViewController: EpisodeViewController) -> Int {
        guard let selectedIndex = vm.selectedEpisodeIndex.value else {
            fatalError("🚨 You have to set selectedIndex!")
        }
        return selectedIndex
    }
    
    func episodeViewControllerEpisode(_ episodeViewController: EpisodeViewController) -> Episode {
        guard let episodes = vm.episodes.value, let selectedIndex = vm.selectedEpisodeIndex.value else {
            fatalError("🚨 You have to set episodes and selectedIndex!")
        }
        return episodes[selectedIndex]
    }
}


extension HomeViewController: EpisodeViewControllerDelegate {
    
    func episodeViewControllerGoToLastEpisode(_ episodeViewController: EpisodeViewController, selectedEpisodeIndex: Int) {
        vm.setAction(action: .PlayEpisode)
        vm.setSelectedEpisodeIndex(selectedIndex: selectedEpisodeIndex)
    }
    
    func episodeViewControllerGoToNextEpisode(_ episodeViewController: EpisodeViewController, selectedEpisodeIndex: Int) {
        vm.setAction(action: .PlayEpisode)
        vm.setSelectedEpisodeIndex(selectedIndex: selectedEpisodeIndex)
    }
}
