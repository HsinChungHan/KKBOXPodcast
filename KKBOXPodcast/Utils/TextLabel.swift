//
//  TextLabel.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import UIKit


protocol BasicLabel {
    func setLabel(text: String, numberOfLines: Int, fontSize: CGFloat)
}

extension BasicLabel where Self: UILabel {
    func setLabel(text: String, numberOfLines: Int, fontSize: CGFloat) {
        self.text = text
        self.numberOfLines = numberOfLines
        self.font = .boldSystemFont(ofSize: fontSize)
    }
}

class BoldLabel: UILabel,  BasicLabel{
    
    init(textColor: UIColor = .black, fontSize: CGFloat = 12) {
        super.init(frame: .zero)
        self.textColor = textColor
        self.font = .boldSystemFont(ofSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
