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
    }
}


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
}


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
        guard let episodes = vm.episodes.value else {
            return
        }
        let episodeVC = EpisodeViewController()
        vm.selectedEpisode = episodes[indexPath.item]
        episodeVC.dataSource = self
        self.present(episodeVC, animated: true, completion: nil)
    }
}


extension HomeViewController: EpisodeViewControllerDataSource {
    
    func episodeViewControllerEpisode(_ episodeViewController: EpisodeViewController) -> Episode {
        guard let selectedeEpisode = vm.selectedEpisode else {
            fatalError("🚨 You have to select an episode cell!")
        }
        return selectedeEpisode
    }
}
