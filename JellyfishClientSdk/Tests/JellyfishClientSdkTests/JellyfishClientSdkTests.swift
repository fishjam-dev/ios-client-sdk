import MembraneRTC
import XCTest

@testable import JellyfishClientSdk

final class JellyfishClientSdkTests: XCTestCase, JellyfishClientListener {
    func onSocketClose(code: Int, reason: String) {

    }

    func onSocketError() {

    }

    func onSocketOpen() {

    }

    func onAuthSuccess() {

    }

    func onAuthError() {

    }

    func onDisconnected() {

    }

    func onJoinSuccess(peerID: String, peersInRoom: [MembraneRTC.Peer]) {

    }

    func onJoinError(metadata: Any) {

    }

    func onRemoved(reason: String) {

    }

    func onPeerJoined(peer: MembraneRTC.Peer) {

    }

    func onPeerLeft(peer: MembraneRTC.Peer) {

    }

    func onPeerUpdated(peer: MembraneRTC.Peer) {

    }

    func onTrackReady(ctx: MembraneRTC.TrackContext) {

    }

    func onTrackAdded(ctx: MembraneRTC.TrackContext) {

    }

    func onTrackRemoved(ctx: MembraneRTC.TrackContext) {

    }

    func onTrackUpdated(ctx: MembraneRTC.TrackContext) {

    }

    func onBandwidthEstimationChanged(estimation: Int) {

    }

    func testExample() throws {
        let x = JellyfishClientSdk(listiner: self)
        XCTAssertEqual("xd", "xd")
    }
}
