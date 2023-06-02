//
//  ContentViewController.swift
//  JellyfishClientDemo
//
//  Created by Karol Sygiet on 02/06/2023.
//

import Foundation
import JellyfishClientSdk
import MembraneRTC
import UIKit

class ContentViewController {
    private var jellyfishClient: JellyfishClientSdk?
    public private(set) var client: MembraneRTC?

    public init() {

    }

    public func connect() {
        self.jellyfishClient = JellyfishClientSdk(delegate: self)

        let conf = Config(
            websocketUrl: "ws://192.168.83.89:4000/socket/peer/websocket",
            token:
                "SFMyNTY.g2gDdAAAAAJkAAdwZWVyX2lkbQAAACRiMmFlZjRhMy03NmJhLTQ0NzEtYmFhOC01NjkwNzc1ZTY5ZmNkAAdyb29tX2lkbQAAACQwZGQ0NmFlYi03ODhhLTRiZjUtODk4NS0wYjBiNzQxYmQyNjluBgDXYe57iAFiAAFRgA.VughwqE7mzewsEJ5gMV4VSK-O6RaheQUEaODKL_ZpCU"
        )

        self.client = MembraneRTC.create(delegate: self)

        jellyfishClient?.connect(config: conf)
        jellyfishClient?.join(peerMetadata: .init(["displayName": "iphoneUser"]))
    }
}

extension ContentViewController: MembraneRTCDelegate {
    func onSendMediaEvent(event: SerializedMediaEvent) {
    }

    func onJoinSuccess(peerID _: String, peersInRoom _: [Peer]) {}

    func onJoinError(metadata _: Any) {}

    func onTrackReady(ctx _: TrackContext) {}

    func onTrackAdded(ctx _: TrackContext) {}

    func onTrackRemoved(ctx _: TrackContext) {}

    func onTrackUpdated(ctx _: TrackContext) {}

    func onPeerJoined(peer _: Peer) {}

    func onPeerLeft(peer _: Peer) {}

    func onPeerUpdated(peer _: Peer) {}
}
