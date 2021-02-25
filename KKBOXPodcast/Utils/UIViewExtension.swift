//
//  UIViewExtension.swift
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/23.
//

import SnapKit

extension UIView {
    
    func fillSuperView(padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), ratio: CGFloat = 1) {
        self.snp.makeConstraints { (make) in
            make.top.equalTo(superview!.snp.top).offset(padding.top * ratio)
            make.bottom.equalTo(superview!.snp.bottom).offset(-padding.bottom * ratio)
            make.leading.equalTo(superview!.snp.leading).offset(padding.left * ratio)
            make.trailing.equalTo(superview!.snp.trailing).offset(-padding.right * ratio)
        }
    }
    
    func constraint(top: ConstraintRelatableTarget?, bottom: ConstraintRelatableTarget?, leading: ConstraintRelatableTarget?, trailing: ConstraintRelatableTarget?, padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), ratio: CGFloat = 1, size: CGSize = .zero) {
        self.snp.makeConstraints { (make) in
            if let top = top { make.top.equalTo(top).offset(padding.top * ratio) }
            if let bottom = bottom { make.bottom.equalTo(bottom).offset(-padding.bottom * ratio) }
            if let leading = leading { make.leading.equalTo(leading).offset(padding.left * ratio) }
            if let trailing = trailing { make.trailing.equalTo(trailing).offset(-padding.right * ratio) }
            if size.width != 0{ make.width.equalTo(size.width * ratio) }
            if size.height != 0{ make.height.equalTo(size.height * ratio) }
        }
    }
    
    func center(padding: (x: CGFloat, y: CGFloat) = (0,0), ratio: CGFloat = 1, size: CGSize) {
        self.snp.makeConstraints { (make) in
            make.centerX.equalTo(superview!.snp.centerX).offset(padding.x * ratio)
            make.centerY.equalTo(superview!.snp.centerY).offset(padding.y * ratio)
            if size.width != 0 { make.width.equalTo(size.width * ratio) }
            if size.height != 0 { make.height.equalTo(size.height * ratio) }
        }
    }
}

