//
//  Formatter.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/3/2.
//

import UIKit


class Formatter: DateFormatter {
    
    func formattedDateString(date: Date) -> String {
        dateFormat = "MMM dd, yyyy"
        return string(from: date)
    }
}
