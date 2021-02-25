//
//  DateExtension.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import Foundation


extension Date {
    func dateFormate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}
