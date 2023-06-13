import Foundation
import MembraneRTC
import XCTest
import Mockingbird
import Starscream

@testable import JellyfishClientSdk

final class JellyfishClientSdkTests: XCTestCase, JellyfishClientListener {
    let mockedWebSocket = mock(WebSocket.self)
  
    func onSendMediaEvent(event: SerializedMediaEvent) {
      
    }
  
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

    func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {

    }

    func onJoinError(metadata: Any) {

    }

    func onRemoved(reason: String) {

    }

    func onPeerJoined(peer: Peer) {

    }

    func onPeerLeft(peer: Peer) {

    }

    func onPeerUpdated(peer: Peer) {

    }

    func onTrackReady(ctx: TrackContext) {

    }

    func onTrackAdded(ctx: TrackContext) {

    }

    func onTrackRemoved(ctx: TrackContext) {

    }

    func onTrackUpdated(ctx: TrackContext) {

    }

    func onBandwidthEstimationChanged(estimation: Int) {

    }

  
    func getMockWebsocket(url: String) -> WebSocket {
      return self.mockedWebSocket;
    }
  
    func testExample() throws {
        let x = JellyfishClientInternal(listiner: self, websocketFactory: getMockWebsocket)
      
      
      let testConfig = Config(websocketUrl: "ws:\\test.com", token: "testTOKEN")
      x.connect(config: testConfig)
      
      verify(self.mockedWebSocket.connect()).wasCalled()
      
    }
}
