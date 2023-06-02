import MembraneRTC
import Foundation

internal class JellyfishClientInternal: JellyfishClientListener, MembraneRTCDelegate {
    private var webSocket : URLSessionWebSocketTask?
    var webrtcClient: MembraneRTC

    public init(delegate: MembraneRTCDelegate) {
      self.webrtcClient = MembraneRTC.create(delegate: delegate)
    }

    func connect(config: Config) {
    }

    func leave() {
        webrtcClient.disconnect()
    }

    func cleanUp() {
        webrtcClient.disconnect()
      webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        onDisconnected()
    }

  private func afterSent(error: Error?) -> Void {}
  
    private func sendEvent(peerMessage: Data) {
        self.webSocket?.send(.data(peerMessage), completionHandler: afterSent)
    }

    private func receiveEvent(event: SerializedMediaEvent) {
      webrtcClient.receiveMediaEvent(mediaEvent: event)
    }

     func onJoinError(metadata: Any) {
      print("xd")
    }

     func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {
    }

     func onPeerJoined(peer: Peer) {
    }

     func onPeerLeft(peer: Peer) {
    }

     func onPeerUpdated(peer: Peer) {
    }

     func onSendMediaEvent(event: SerializedMediaEvent) {
       let mediaEvent =
         Jellyfish_PeerMessage.with({
           $0.mediaEvent = Jellyfish_PeerMessage.MediaEvent.with({
             $0.data = event
           })
         })
       
       guard let serialzedData = try? mediaEvent.serializedData() else {
         return
       }
        sendEvent(peerMessage: serialzedData)
    }

     func onTrackAdded(ctx: TrackContext) {
    }

     func onTrackReady(ctx: TrackContext) {
    }

     func onTrackRemoved(ctx: TrackContext) {
    }

     func onTrackUpdated(ctx: TrackContext) {
    }

     func onRemoved(reason: String) {
    }

     func onBandwidthEstimationChanged(estimation: Int) {
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
  
    func onTrackEncodingChanged(peerId: String, trackId: String, encoding: String) {
      
    }
}
