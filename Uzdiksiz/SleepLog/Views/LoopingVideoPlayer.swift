//
//  LoopingVideoPlayer.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 03.08.2025.
//
import SwiftUI
import AVKit

struct LoopingVideoPlayer: View {
    let videoURLString: String
    let placeholderImageName: String

    var body: some View {
        LoopingPlayerUIView(urlString: videoURLString)
            .aspectRatio(contentMode: .fill)
            .background(
                Image(placeholderImageName)
                    .resizable()
                    .scaledToFill()
            )
    }
}

struct LoopingPlayerUIView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerView(urlString: urlString)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerView: UIView {
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    init(urlString: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        playLoopingVideo(from: urlString)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func playLoopingVideo(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid video URL.")
            return
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer()
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        self.queuePlayer = queuePlayer
        self.playerLooper = looper

        queuePlayer.play()

        // Resize layer on bounds change
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            playerLayer.frame = self?.bounds ?? .zero
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
    }
}
