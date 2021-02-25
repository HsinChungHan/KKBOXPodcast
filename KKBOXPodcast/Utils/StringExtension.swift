//
//  StringExtension.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation


extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
