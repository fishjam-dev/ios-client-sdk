import Foundation
import MembraneRTC
import Starscream

internal class JellyfishClientInternal: MembraneRTCDelegate, WebSocketDelegate {
    private var config: Config?
    private var webSocket: JellyfishWebsocket?
    private var listener: JellyfishClientListener
    private var websocketFactory: (String) -> JellyfishWebsocket
    var webrtcClient: JellyfishMembraneRTC?

    public init(listener: JellyfishClientListener, websocketFactory: @escaping (String) -> JellyfishWebsocket) {
        self.listener = listener
        self.websocketFactory = websocketFactory
    }

    func connect(config: Config) {
        self.config = config

        webSocket = websocketFactory(config.websocketUrl)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    func leave() {
        webrtcClient?.disconnect()
    }

    func cleanUp() {
        webrtcClient?.disconnect()
        webSocket?.disconnect()
        webSocket = nil
        onDisconnected()
    }
  
    func websocketDidConnect(socket: WebSocketClient) {
      print("did conecnt")
      onSocketOpen()
      let authRequest = Jellyfish_PeerMessage.with({
          $0.authRequest = Jellyfish_PeerMessage.AuthRequest.with({
              $0.token = self.config?.token ?? ""
          })
      })

      guard let serializedData = try? authRequest.serializedData() else {
          return
      }
      sendEvent(peerMessage: serializedData)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
      print("disconnect", error)
        if let error = error as? WSError {
            onSocketClose(code: error.code, reason: error.message)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        do {
            let peerMessage = try Jellyfish_PeerMessage(serializedData: data)
            if case .authenticated(_) = peerMessage.content {
                onAuthSuccess()
            } else if case .mediaEvent(_) = peerMessage.content {
                receiveEvent(event: peerMessage.mediaEvent.data)
            } else {
                print("Received unexpected websocket message: \(peerMessage)")
            }
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
      print("TODO")
    }

    private func sendEvent(peerMessage: Data) {
      print("send event", peerMessage)

        self.webSocket?.write(data: peerMessage)
    }

    private func receiveEvent(event: SerializedMediaEvent) {
      print("recieve event")

        webrtcClient?.receiveMediaEvent(mediaEvent: event)
    }
    
    func onEndpointAdded(endpoint: Endpoint) {
      print("onEndpointAdded event")

      listener.onPeerJoined(peer: endpoint)
    }
    
    func onEndpointRemoved(endpoint: Endpoint) {
      print("onEndpointRemoved event")

      listener.onPeerLeft(peer: endpoint)
    }
    
    func onEndpointUpdated(endpoint: Endpoint) {
      print("onEndpointUpdated event")

      listener.onPeerUpdated(peer: endpoint)
    }

    func onSendMediaEvent(event: SerializedMediaEvent) {
      print("on send ", event)

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
        listener.onTrackAdded(ctx: ctx)
    }

    func onTrackReady(ctx: TrackContext) {
        listener.onTrackReady(ctx: ctx)
    }

    func onTrackRemoved(ctx: TrackContext) {
        listener.onTrackRemoved(ctx: ctx)
    }

    func onTrackUpdated(ctx: TrackContext) {
        listener.onTrackUpdated(ctx: ctx)
    }

    func onBandwidthEstimationChanged(estimation: Int) {
        listener.onBandwidthEstimationChanged(estimation: estimation)
    }

    func onSocketClose(code: Int, reason: String) {
      print("onSocketClose event")

        listener.onSocketClose(code: code, reason: reason)
    }

    func onSocketError() {
      print("onSocketError event")

        listener.onSocketError()
    }

    func onSocketOpen() {
      print("onSocketOpen event")

        listener.onSocketOpen()
    }

    func onAuthSuccess() {
      print("onAuthSuccess event")

        listener.onAuthSuccess()
    }

    func onAuthError() {
      print("onAuthError event")

        listener.onAuthError()
    }

    func onDisconnected() {
      print("onDisconnected event")

        listener.onDisconnected()
    }
  
    func onConnected(endpointId: String, otherEndpoints: [Peer]) {
      print("onConnected event")

      listener.onJoined(peerID: endpointId, peersInRoom: otherEndpoints)
    }
    
    func onConnectionError(metadata: Any) {
      print("onConnectionError event")

      listener.onJoinError(metadata: metadata)
    }

    func onTrackEncodingChanged(endpointId: String, trackId: String, encoding: String) {
    }
}
