//
//  PreviewVideoViewController.swift
//  DIGIPROSDKATO
//
//  Created by Alejandro López Arroyo on 11/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit

import AVKit
import AVFoundation

public class PreviewVideoViewController: UIViewController {

    @IBOutlet weak var previewVideo: VideoView!
    
    public var isPlayingVideo: Bool = false
    public var path: String = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(hue: 0/255, saturation: 0/255, brightness: 100/255, alpha: 0.8)
        guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.path)") else{ return }
        FCFileManager.createFile(atPath: "video.mp4", withContent: data as NSObject, overwrite: true)
        guard let url = FCFileManager.urlForItem(atPath: "video.mp4") else{ return }
        self.previewVideo?.configure(videoUrl: url)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapVideo))
        self.previewVideo?.isUserInteractionEnabled = true
        self.previewVideo?.addGestureRecognizer(tapRecognizer)
        self.previewVideo?.isHidden = false
        self.isPlayingVideo = true
        self.previewVideo?.play()
    }
    
    @objc func onTapVideo() {
        guard let data = ConfigurationManager.shared.utilities.read(asData: "\(Cnstnt.Tree.anexos)/\(self.path)") else{ return }
        FCFileManager.createFile(atPath: "video.mp4", withContent: data as NSObject, overwrite: true)
        guard let url = FCFileManager.urlForItem(atPath: "video.mp4") else{ return }
        self.previewVideo.configure(videoUrl: url)
        if self.isPlayingVideo{
            self.isPlayingVideo = false
            self.previewVideo.pause()
            self.previewVideo.player = nil
            self.previewVideo.layer.sublayers = nil
            ///btnPlay.setImage(UIImage(named: "ic_playVid", in: Cnstnt.Path.bnl, compatibleWith: nil), for: .normal)
        }else{
            self.isPlayingVideo = true
            self.previewVideo.play()
            ///btnPlay.setImage(UIImage(named: "ic_stopVid", in: Cnstnt.Path.bnl, compatibleWith: nil), for: .normal)
        }
    }

}
