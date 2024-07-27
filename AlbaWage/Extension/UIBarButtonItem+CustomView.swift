//
//  UIBarButtonItem+CustomView.swift
//  AlbaWage
//
//  Created by 서동환 on 7/17/24.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    static func generate(with config: CustomBarItemConfiguration, width: CGFloat? = nil) -> UIBarButtonItem {
        let customView = CustomBarItem(config: config)
        
        if let width = width {
            NSLayoutConstraint.activate([
                customView.widthAnchor.constraint(equalToConstant: width)
            ])
        }
        
        let barButtonItem = UIBarButtonItem(customView: customView)
        return barButtonItem
    }
}
