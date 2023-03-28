//
//  ViewScrollable.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 10/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

protocol ViewScrollable: AnyObject {
    var contentView: UIView { get set }
    var mainScrollView: UIScrollView { get set }
}

extension ViewScrollable where Self: UIView {
    func configScroll() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        configConstraints()
    }
    
    private func configConstraints() {
        addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor), // Scroll se adapta a la altura del content, y este se va haciendo mas grande.b
            
            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
            
        ])
    }
}
