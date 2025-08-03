//
//  LoopingVideoPlayer.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 03.08.2025.
//

import SwiftUI
import AVKit

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        return QueuePlayerUIView(videoName: videoName)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class QueuePlayerUIView: UIView {
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?

    init(videoName: String) {
        super.init(frame: .zero)
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("❌ Video file '\(videoName).mp4' not found in bundle.")
            return
        }

        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        let player = AVQueuePlayer()
        self.player = player
        player.isMuted = true
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer = playerLayer

        layer.addSublayer(playerLayer)

        player.play()

        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
