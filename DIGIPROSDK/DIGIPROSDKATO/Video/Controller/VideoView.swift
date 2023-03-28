import UIKit
import AVKit
import AVFoundation


class VideoView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func configure(videoUrl: URL) {
        do { try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch { print("Sound Video = AVAudioSessionCategoryPlayback failed.") }
        player = AVPlayer(url: videoUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer?.frame = self.bounds
        if let playerLayer = self.playerLayer {
            if layer.sublayers?.count == 2{
                layer.addSublayer(playerLayer)
            }else{
                layer.sublayers?.removeLast()
                layer.addSublayer(playerLayer)
            }
        }
    }
    
    func play() {
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
}
