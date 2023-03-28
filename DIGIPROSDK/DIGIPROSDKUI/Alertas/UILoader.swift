//
//  UILoader.swift
//  Registro
//
//  Created by Branchbit on 16/03/22.
//

import UIKit
import Lottie

open class UILoader {
    
    private static let tagView = -123456789
    
    public static func show(parent: UIView) {
        if parent.viewWithTag(tagView) != nil {
            return
        }
        parent.isUserInteractionEnabled = false
        let mainView = UIView(frame: (parent.frame))
        mainView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.tag = tagView
        let lottie = Animation.self.named("loader_digipro",
            subdirectory: nil,
            animationCache: nil)
        
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = ""
        titleLabel.font = .systemFont(ofSize: 25)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        let activityIndicator = AnimationView(animation: lottie)
        activityIndicator.contentMode = .scaleAspectFit
        activityIndicator.backgroundBehavior = .pauseAndRestore
        activityIndicator.loopMode = .loop
        activityIndicator.play()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(view)
        view.addSubview(activityIndicator)
        view.addSubview(titleLabel)
        parent.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: 230),
            view.widthAnchor.constraint(equalToConstant: 230),
            
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -20),
            activityIndicator.heightAnchor.constraint(equalToConstant: 300),
            activityIndicator.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    public static func remove(parent: UIView) {
        parent.isUserInteractionEnabled = true
        if let loaderView = parent.viewWithTag(tagView) {
            loaderView.removeFromSuperview()
        }
    }
    
}

open class UILoaderIndicator {
    
    private static let tagView = -123456789
    
    public static func show(parent: UIView) {
        if parent.viewWithTag(tagView) != nil {
            return
        }
        parent.isUserInteractionEnabled = false
        let mainView = UIView(frame: (parent.frame))
        mainView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.tag = tagView
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = parent.center
        activityIndicator.startAnimating()
        mainView.addSubview(activityIndicator)
        parent.addSubview(mainView)
    }
    
    public static func remove(parent: UIView) {
        parent.isUserInteractionEnabled = true
        if let loaderView = parent.viewWithTag(tagView) {
            loaderView.removeFromSuperview()
        }
    }
    
}
