import Foundation
import MembraneRTC
import Starscream

internal class JellyfishClientInternal: JellyfishClientListener, JellyfishWebSocketDelegate, MembraneRTCDelegate {
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

    func websocketDidConnect() {
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

    func websocketDidDisconnect(error: Error?) {
        if let error = error as? WSError {
            onSocketClose(code: error.code, reason: error.message)
        }
    }

    func websocketDidReceiveData(data: Data) {
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

    private func sendEvent(peerMessage: Data) {
        self.webSocket?.write(data: peerMessage)
    }

    private func receiveEvent(event: SerializedMediaEvent) {
        webrtcClient?.receiveMediaEvent(mediaEvent: event)
    }

    func onJoinError(metadata: Any) {
        listener.onJoinError(metadata: metadata)
    }

    func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {
        listener.onJoinSuccess(peerID: peerID, peersInRoom: peersInRoom)
    }

    func onPeerJoined(peer: Peer) {
        listener.onPeerJoined(peer: peer)
    }

    func onPeerLeft(peer: Peer) {
        listener.onPeerLeft(peer: peer)
    }

    func onPeerUpdated(peer: Peer) {
        listener.onPeerUpdated(peer: peer)
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

    func onRemoved(reason: String) {
        listener.onRemoved(reason: reason)
    }

    func onBandwidthEstimationChanged(estimation: Int) {
        listener.onBandwidthEstimationChanged(estimation: estimation)
    }

    func onSocketClose(code: Int, reason: String) {
        listener.onSocketClose(code: code, reason: reason)
    }

    func onSocketError() {
        listener.onSocketError()
    }

    func onSocketOpen() {
        listener.onSocketOpen()
    }

    func onAuthSuccess() {
        listener.onAuthSuccess()
    }

    func onAuthError() {
        listener.onAuthError()
    }

    func onDisconnected() {
        listener.onDisconnected()
    }

    func onTrackEncodingChanged(peerId: String, trackId: String, encoding: String) {
    }
}
