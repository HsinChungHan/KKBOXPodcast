//
//  TextLabel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit

// - FIXME: 這邊違反了 OOD 中的 Lisko substitution principle
protocol BasicLabel {
    var txtColor: UIColor { get }
}

extension BasicLabel where Self: UILabel {
    func setLabel(text: String, numberOfLines: Int, fontSize: CGFloat) {
        self.text = text
        self.numberOfLines = numberOfLines
        self.font = .boldSystemFont(ofSize: fontSize)
        self.textColor = txtColor
    }
}

class BoldLabel: UILabel,  BasicLabel{
    var txtColor: UIColor = .black
}
