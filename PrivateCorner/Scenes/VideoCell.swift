//
//  VideoCell.swift
//  PrivateCorner
//
//  Created by a on 5/31/17.
//  Copyright © 2017 MrAChen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoCell: UICollectionViewCell {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var containerView: UIView!
    var imageView: UIImageView!
    var tapGR: UITapGestureRecognizer!
    var isEnd: Bool = false
    
    var topInset: CGFloat = 0 {
        didSet {
            centerIfNeeded()
        }
    }
    
    var bottomInset: CGFloat = 0 {
        didSet {
            centerIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if (playerLayer != nil) {
            playerLayer.removeFromSuperlayer()
        }
        
        containerView = UIView(frame: bounds)
        addSubview(containerView)
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(tap(gr:)))
        addGestureRecognizer(tapGR)
        
        
    }
    
    func configureVideo(url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.bounds
        containerView.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("playerDidFinishPlaying:")),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playVideo() {
        player.play()
    }
    
    func pauseVideo() {
        player.pause()
    }
    
    func tap(gr: UITapGestureRecognizer) {
        if player.isPlaying {
            player.pause()
        } else {
            if isEnd {
                self.player.seek(to: kCMTimeZero)
                isEnd = false
            }
            player.play()
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        isEnd = true
    }
    
    func centerIfNeeded() {
        containerView.frame.origin.y = topInset
        containerView.frame.size.height = bounds.size.height - topInset - bottomInset
        containerView.frame.size.width = bounds.size.width
        
        var rect = containerView.bounds
        rect.origin.y = 0
        playerLayer.frame = rect
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
