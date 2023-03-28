//
//  WebPDFViewControllerRow.swift
//  DIGIPROSDKATO
//
//  Created by Carlos Mendez Flores on 11/12/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import UIKit
import PDFKit
import DIGIPROSDK


open class WebPDFViewControllerMain{
    
    static func create(pdfString: String?, nameOfFile: String)->UIViewController{
        let viewcontroller : WebPDFViewControllerRow? = WebPDFViewControllerRow()
        if let view = viewcontroller{
            view.pdfString = pdfString
            view.nameOfFile = nameOfFile
            return view
        }
        return UIViewController()
    }
}

internal class WebPDFViewControllerRow: UIViewController {
    
    private lazy var titleFile: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var navigationBar: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let image =  UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let button = UIButton(frame: .zero)
        button.setImage( image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeViewControllerAction(_:)), for: .touchUpInside)
        button.tintColor = .black
        
        let imageQ =  UIImage(named: "ic_question", in: Cnstnt.Path.framework, compatibleWith: nil)
        let buttonQ = UIButton(frame: .zero)
        buttonQ.setImage( imageQ, for: .normal)
        buttonQ.translatesAutoresizingMaskIntoConstraints = false
        buttonQ.addTarget(self, action: #selector(tutorialAction(_:)), for: .touchUpInside)
        buttonQ.tintColor = .black
        
        let imageT =  UIImage(named: "ic_toggle", in: Cnstnt.Path.framework, compatibleWith: nil)
        let buttonT = UIButton(frame: .zero)
        buttonT.setImage( imageT, for: .normal)
        buttonT.translatesAutoresizingMaskIntoConstraints = false
        buttonT.addTarget(self, action: #selector(toggleSidebar(_:)), for: .touchUpInside)
        buttonT.tintColor = .black
        
        
        view.addSubview(button)
        view.addSubview(buttonQ)
        view.addSubview(buttonT)
        view.addSubview(titleFile)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            buttonQ.heightAnchor.constraint(equalToConstant: 44),
            buttonQ.widthAnchor.constraint(equalToConstant: 44),
            buttonQ.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonQ.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            
            buttonT.heightAnchor.constraint(equalToConstant: 44),
            buttonT.widthAnchor.constraint(equalToConstant: 44),
            buttonT.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonT.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
            titleFile.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleFile.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleFile.leadingAnchor.constraint(equalTo: buttonT.trailingAnchor, constant: 15),
            titleFile.trailingAnchor.constraint(equalTo: buttonQ.leadingAnchor, constant: -5)
        ])
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let closeIcon = UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil)
        button.setImage(closeIcon, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var webView : PDFView = {
        let web = PDFView(frame: .zero)
        web.autoScales = true
        web.translatesAutoresizingMaskIntoConstraints = false
        return web
    }()
    private lazy var pdfThumbnailView : PDFThumbnailView = {
        let web = PDFThumbnailView(frame: .zero)
       // web.alpha = 0
        web.translatesAutoresizingMaskIntoConstraints = false
        return web
    }()
    private var constraintWidthToggle: NSLayoutConstraint?
    public var pdfString : String?
    public var nameOfFile: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        onbuildUI()
        onBuildConstraints()
        if let data = Data(base64Encoded: pdfString ?? "", options: .ignoreUnknownCharacters) {
            webView.document = PDFDocument(data: data)
            pdfThumbnailView.pdfView = webView
            pdfThumbnailView.thumbnailSize = CGSize(width: 50, height: 50)
            pdfThumbnailView.backgroundColor = UIColor(hexString: "F5F7F8")
            titleFile.text = nameOfFile
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.scalePDFViewToFit()
        }, completion: nil)
    }
    
    fileprivate func onbuildUI(){
        view.backgroundColor = .white
        view.addSubview(navigationBar)
        view.addSubview(webView)
        view.addSubview(pdfThumbnailView)
    }
    
    fileprivate func onBuildConstraints(){
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfThumbnailView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            pdfThumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pdfThumbnailView.widthAnchor.constraint(equalToConstant: 70),
            webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: pdfThumbnailView.trailingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        constraintWidthToggle = NSLayoutConstraint.init(item: pdfThumbnailView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: -70)
        constraintWidthToggle!.isActive = true
    }
    
    @objc private func closeViewControllerAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func toggleSidebar(_ sender: UIButton) {
        let thumbnailViewWidth = 70.0
        let screenWidth = UIScreen.main.bounds.width
        let multiplier = thumbnailViewWidth / (screenWidth - thumbnailViewWidth) + 1.0
        let isShowing = constraintWidthToggle?.constant == 0
        let scaleFactor = webView.scaleFactor
        UIView.animate(withDuration: 0.25) {
            self.constraintWidthToggle!.constant = isShowing ? -thumbnailViewWidth : 0
            self.webView.scaleFactor = isShowing ? scaleFactor * multiplier : scaleFactor / multiplier
            self.view.layoutIfNeeded()
        }
    }
    @objc private func tutorialAction(_ sender: UIButton){
        let tutorial = TutorialExpandController()
        tutorial.modalPresentationStyle = .overFullScreen
        present(tutorial, animated: true)
    }
    
    private func scalePDFViewToFit() {
        UIView.animate(withDuration: 0.25) {
                self.webView.scaleFactor = self.webView.scaleFactorForSizeToFit
                self.view.layoutIfNeeded()
            }
        }
}
