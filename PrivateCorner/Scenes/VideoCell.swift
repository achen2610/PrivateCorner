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

public protocol VideoCellDelegate: class {
    func tapOverVideoView()
}

class VideoCell: UICollectionViewCell {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var containerView: UIView!
    var playButton: UIButton!
    var tapGR: UITapGestureRecognizer!
    var isEnd: Bool = false
    
    weak var delegate: VideoCellDelegate?

    //MARK: - Getter/Setter
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
        playButton = UIButton(frame: bounds)
        playButton.setImage(UIImage(named: "playvideo.png"), for: .normal)
        playButton.addTarget(self, action: #selector(clickPlayButton(sender:)), for: .touchUpInside)
        playButton.isHidden = true
        addSubview(containerView)
        addSubview(playButton)
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(tap(gr:)))
        addGestureRecognizer(tapGR)
    }
    
    //MARK: - Public Methods
    func configureVideo(url: URL, isEndTransition: Bool) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.bounds
        containerView.layer.addSublayer(playerLayer)
        centerIfNeeded()
        
        if isEndTransition {
            playButton.isHidden = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playVideo() {
        player.play()
        
        setHiddenForPlayButton(isHidden: true)
    }
    
    func pauseVideo() {
        player.pause()
        
        setHiddenForPlayButton(isHidden: false)
    }
    
    func setHiddenForPlayButton(isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.playButton.alpha = 0
            }, completion: { (finished) in
                if finished {
                    self.playButton.isHidden = isHidden
                }
            })
        } else {
            self.playButton.isHidden = isHidden
            UIView.animate(withDuration: 0.3, animations: {
                self.playButton.alpha = 1
            })
        }
    }
    
    //MARK: - Selector Event
    func tap(gr: UITapGestureRecognizer) {
        delegate?.tapOverVideoView()
    }
    
    func clickPlayButton(sender: UIButton) {
        playVideo()
    }
    
    //MARK: - Private Methods
    func centerIfNeeded() {
        var rect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        containerView.frame = videoRect(containerRect: rect)

        rect = playButton.frame
        rect.size = CGSize(width: 64, height: 64)
        playButton.frame = rect
        playButton.center = containerView.center
        
        rect = containerView.bounds
        rect.origin.y = 0
        playerLayer.frame = rect
    }
    
    func videoRect(containerRect: CGRect) -> CGRect {

        guard let track = player.currentItem?.asset.tracks(withMediaType: AVMediaTypeVideo)[0] else {
            return CGRect.zero
        }
        
        let t = track.preferredTransform
        let isPortrait: Bool = (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) || (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)
        var trackSize: CGSize = track.naturalSize
        if isPortrait {
            trackSize = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
        }
        let videoViewSize: CGSize = containerRect.size
        
        let trackRatio: CGFloat = trackSize.width / trackSize.height
        let videoViewRatio: CGFloat = videoViewSize.width / videoViewSize.height
        
        let newSize: CGSize
        
        if (videoViewRatio > trackRatio) {
            newSize = CGSize(width: trackSize.width * videoViewSize.height / trackSize.height, height: videoViewSize.height)
        } else {
            newSize = CGSize(width: videoViewSize.width, height: trackSize.height * videoViewSize.width / trackSize.width);
        }
        
        let newX: CGFloat = (videoViewSize.width - newSize.width) / 2;
        let newY: CGFloat = (videoViewSize.height - newSize.height) / 2 + containerRect.origin.y;
        
        return CGRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
    }
    
    //MARK: - Notification
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        isEnd = true
    }
    
    //MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

