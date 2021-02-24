//
//  MaxPlayerViewWithAnimation.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/24.
//

import UIKit


// - MARK: Minimize and maxmize the player view
extension MaxPlayerView {
    
    func setupConstraintsForMaxPlayerView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = topAnchor.constraint(equalTo: superView.topAnchor, constant: superView.frame.height)
        
        bottomAnchorConstraint = bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: superView.frame.height)
        
        // minPlayerView's height is 80
        minimizedTopAnchorConstraint = topAnchor.constraint(equalTo: superView.bottomAnchor, constant: -80)
        
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true
    }
    
    func maxmizeMaxPlayerView() {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.superView.layoutIfNeeded()
            self.overallStackView.alpha = 1
            self.minPlayerView.alpha = 0.0
        }
    }
    
    func minimizeMaxPlayerView() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = superView.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.superView.layoutIfNeeded()
            self.overallStackView.alpha = 0.0
            self.minPlayerView.alpha = 1.0
        }
    }
}


// - MARK: Minimize and maxmize the player view with gesture
extension MaxPlayerView {
    
    func setupGestureRecognizer() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize(gesture:))))
//        overallStackView.
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanDismiss(gesture:))))
        minPlayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:))))
    }
    
    @objc func handleTapMaximize(gesture: UIPanGestureRecognizer) {
        self.maxmizeMaxPlayerView()
    }
    
    @objc func handlePanDismiss(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superView)
            transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.transform = .identity
                if translation.y > 80 {
                    self.minimizeMaxPlayerView()
                }
            })
        }
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }

    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superView)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        minPlayerView.alpha = 1 + translation.y / 200
        overallStackView.alpha = -translation.y / 200
    }

    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superView)
        let velocity = gesture.velocity(in: superView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < 400 {
                self.maxmizeMaxPlayerView()
            } else {
                self.minPlayerView.alpha = 1
                self.overallStackView.alpha = 0
            }
        })
    }
}

