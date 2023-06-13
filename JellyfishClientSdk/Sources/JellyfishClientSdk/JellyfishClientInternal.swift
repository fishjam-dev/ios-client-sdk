import Foundation
import MembraneRTC
import Starscream

internal class JellyfishClientInternal: JellyfishClientListener, WebSocketDelegate {
    private var config: Config?
    private var webSocket: WebSocket?
    private var listiner: JellyfishClientListener
    private var websocketFactory: (String)->WebSocket
    var webrtcClient: MembraneRTC?

  public init(listiner: JellyfishClientListener, websocketFactory: @escaping (String)->WebSocket) {
        self.listiner = listiner
        self.websocketFactory = websocketFactory
    }

    func connect(config: Config) {
        self.webrtcClient = MembraneRTC.create(delegate: self)
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

    func websocketDidConnect(socket: Starscream.WebSocketClient) {
        onSocketOpen()
        let authRequest = Jellyfish_PeerMessage.with({
            $0.authRequest = Jellyfish_PeerMessage.AuthRequest.with({
                $0.token = self.config?.token ?? ""
            })
        })

        guard let serialzedData = try? authRequest.serializedData() else {
            return
        }
        sendEvent(peerMessage: serialzedData)
    }

    func websocketDidDisconnect(socket: Starscream.WebSocketClient, error: Error?) {
        if let error = error as? WSError {
            onSocketClose(code: error.code, reason: error.message)
        }
    }

    func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String) {
        // UNSUPPORTED
        onSocketError()
    }

    func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data) {
        do {
            let peerMessage = try Jellyfish_PeerMessage(serializedData: data)
            if case .authenticated(_) = peerMessage.content {
                onAuthSuccess()
            } else if peerMessage.mediaEvent.isInitialized {
                receiveEvent(event: peerMessage.mediaEvent.data)
            } else {
                print("Received unexpected websocket message: \(peerMessage)")
            }
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    private func sendEvent(peerMessage: Data) {
        self.webSocket?.write(data: peerMessage)
    }

    private func receiveEvent(event: SerializedMediaEvent) {
        webrtcClient?.receiveMediaEvent(mediaEvent: event)
    }

    func onJoinError(metadata: Any) {
        listiner.onJoinError(metadata: metadata)
    }

    func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {
        listiner.onJoinSuccess(peerID: peerID, peersInRoom: peersInRoom)
    }

    func onPeerJoined(peer: Peer) {
        listiner.onPeerJoined(peer: peer)
    }

    func onPeerLeft(peer: Peer) {
        listiner.onPeerLeft(peer: peer)
    }

    func onPeerUpdated(peer: Peer) {
        listiner.onPeerUpdated(peer: peer)
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
        listiner.onTrackAdded(ctx: ctx)
    }

    func onTrackReady(ctx: TrackContext) {
        listiner.onTrackReady(ctx: ctx)
    }

    func onTrackRemoved(ctx: TrackContext) {
        listiner.onTrackRemoved(ctx: ctx)
    }

    func onTrackUpdated(ctx: TrackContext) {
        listiner.onTrackUpdated(ctx: ctx)
    }

    func onRemoved(reason: String) {
        listiner.onRemoved(reason: reason)
    }

    func onBandwidthEstimationChanged(estimation: Int) {
        listiner.onBandwidthEstimationChanged(estimation: estimation)
    }

    func onSocketClose(code: Int, reason: String) {
        listiner.onSocketClose(code: code, reason: reason)
    }

    func onSocketError() {
        listiner.onSocketError()
    }

    func onSocketOpen() {
        listiner.onSocketOpen()
    }

    func onAuthSuccess() {
        listiner.onAuthSuccess()
    }

    func onAuthError() {
        listiner.onAuthError()
    }

    func onDisconnected() {
        listiner.onDisconnected()
    }

    func onTrackEncodingChanged(peerId: String, trackId: String, encoding: String) {
    }
}


protocol JellyfishWebsocket {
  var delegate: WebSocketDelegate? { get set }
  func connect()
  func disconnect()
  func write(data: Data, completion: (() -> ())?)
}

extension WebSocket: JellyfishWebsocket {}
