import Foundation
import MembraneRTC
import Starscream

internal class JellyfishClientInternal: NSObject, JellyfishClientListener, MembraneRTCDelegate, WebSocketDelegate {
    private var config: Config?
    private var webSocket: WebSocket?
    var webrtcClient: MembraneRTC

    public init(delegate: MembraneRTCDelegate) {
        self.webrtcClient = MembraneRTC.create(delegate: delegate)
    }

    func connect(config: Config) {
        self.config = config
        let url = URL(string: config.websocketUrl)

        webSocket = WebSocket(url: url!)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    func leave() {
        webrtcClient.disconnect()
    }

    func cleanUp() {
        webrtcClient.disconnect()
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
        onSocketClose(code: 1000, reason: "TODO")
    }

    func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String) {
        // UNSUPPORTED
        onSocketError()
    }

    func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data) {
        do {
            let peerMessage = try Jellyfish_PeerMessage(serializedData: data)
            if peerMessage.authenticated.isInitialized {
                onAuthSuccess()
            } else if peerMessage.mediaEvent.isInitialized {
                receiveEvent(event: peerMessage.mediaEvent.data)
            } else {
                print("Received unexpected websocket message: $peerMessage")
            }
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    private func sendEvent(peerMessage: Data) {
        self.webSocket?.write(data: peerMessage)
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
        print("authed")
    }

    func onAuthError() {

    }

    func onDisconnected() {

    }

    func onTrackEncodingChanged(peerId: String, trackId: String, encoding: String) {

    }
}
