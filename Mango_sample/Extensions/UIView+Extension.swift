//
//  File.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/03.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
}

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        let size = (self as NSString).size(withAttributes: [.font: font])
        let buffer = 0.2 // 이게 없으면 UILabel이 잘려보이는 현상이 존재
        return CGSize(width: size.width + buffer, height: size.height)
    }
}
