//
//  TutorialExpandController.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 29/12/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit
import Lottie

open class TutorialExpandController: UIViewController {

    private lazy var lottie: AnimationView = {
        let animation = Animation.named("expander",
            bundle: Bundle.init(for: TutorialExpandController.self),
            subdirectory: nil,
            animationCache: nil)
        let lottie = AnimationView.init(animation: animation)
        lottie.contentMode = .scaleAspectFit
        lottie.backgroundBehavior = .pauseAndRestore
        lottie.loopMode = .autoReverse
        lottie.play()
        lottie.translatesAutoresizingMaskIntoConstraints = false
        
        return lottie
    }()
    
    lazy var tutorialMessage: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Puedes realizar zoom al pdf por medio de tus dedos."
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(lottie)
        view.addSubview(tutorialMessage)
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissAction(_:))))
        NSLayoutConstraint.activate([
            lottie.widthAnchor.constraint(equalToConstant: 200),
            lottie.heightAnchor.constraint(equalToConstant: 200),
            lottie.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lottie.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            tutorialMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorialMessage.topAnchor.constraint(equalTo: lottie.bottomAnchor, constant: 20),
            tutorialMessage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    @objc func dismissAction(_ sender: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
}
