//
//  PreviewVideoFADViewController.swift
//  DIGIPROSDKATO
//
//  Created by Desarrollo on 14/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


class PreviewVideoFADViewController: UIViewController{
    
    var pathPreview: String = ""
    public var isPlayingVideo: Bool = false
    var titleAnimation: String = ""
    public var isAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func customInit(){
        self.view.backgroundColor = UIColor.init(hue: 0/255, saturation: 0/255, brightness: 100/255, alpha: 0.8)
        var frameView = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 50, height: self.view.frame.height - 200)
        if isAnimation
        {   frameView = CGRect(x: 0, y: 30, width: self.view.frame.size.width - 50, height: self.view.frame.height - 230)   }
        let videoPreview = VideoView(frame: frameView)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapVideo))
        videoPreview.isUserInteractionEnabled = true
        videoPreview.addGestureRecognizer(tapRecognizer)
        videoPreview.backgroundColor = .black
        self.view.addSubview(videoPreview)
        if isAnimation
        {
            let label = UILabel(frame: CGRect(x: 0, y: -5, width: self.view.frame.size.width - 50, height: 40))
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.2
            label.numberOfLines = 0
            label.text = titleAnimation
            label.textColor = .white
            label.backgroundColor = .black
            self.view.addSubview(label)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onTapVideo() {
        var data : Data = Data()
        if isAnimation
        {   do {
                data = try Data(contentsOf: URL(fileURLWithPath: "\(self.pathPreview)"))
            }catch{ return }
        } else
        {   guard let dataDefault = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.pathPreview)") else{ return }
            data = dataDefault
        }
        
        FCFileManager.createFile(atPath: "video.mp4", withContent: data as NSObject, overwrite: true)
        guard let url = FCFileManager.urlForItem(atPath: "video.mp4") else{ return }
        (self.view.subviews.first as! VideoView).configure(videoUrl: url)
        if self.isPlayingVideo{
            self.isPlayingVideo = false
            (self.view.subviews.first as! VideoView).pause()
        } else{
            self.isPlayingVideo = true
            (self.view.subviews.first as! VideoView).play()
        }
    }
}
