import Foundation
import MembraneRTC
import Starscream

internal class JellyfishClientInternal: JellyfishClientListener, WebSocketDelegate {
    private var config: Config?
    private var webSocket: WebSocket?
    private var listiner: JellyfishClientListener
    var webrtcClient: MembraneRTC?

    public init(listiner: JellyfishClientListener) {
        self.listiner = listiner
    }

    func connect(config: Config) {
        self.webrtcClient = MembraneRTC.create(delegate: self)
        self.config = config
        let url = URL(string: config.websocketUrl)

        webSocket = WebSocket(url: url!)
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
        print("disconnect")
        onSocketClose(code: 1000, reason: "TODO")
    }

    func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String) {
        // UNSUPPORTED
        print("xd")
        onSocketError()
    }

    func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data) {
        do {
            let peerMessage = try Jellyfish_PeerMessage(serializedData: data)
            print("GOT FROM SERVER: \(peerMessage)")
            if case .authenticated(_) = peerMessage.content {
                print("AUTH SUCCESS")
                onAuthSuccess()
            } else if peerMessage.mediaEvent.isInitialized {
                print("MEDIA EVENT")
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
        print("recieved", event)
        webrtcClient?.receiveMediaEvent(mediaEvent: event)
    }

    func onJoinError(metadata: Any) {
        print("join error", metadata)
        listiner.onJoinError(metadata: metadata)
    }

    func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {
        print("join success")
        listiner.onJoinSuccess(peerID: peerID, peersInRoom: peersInRoom)
    }

    func onPeerJoined(peer: Peer) {
        print("peer")
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
        print(mediaEvent)

        guard let serialzedData = try? mediaEvent.serializedData() else {
            return
        }
        sendEvent(peerMessage: serialzedData)
    }

    func onTrackAdded(ctx: TrackContext) {
        print("Added")
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
        print("onRemoved")
        listiner.onRemoved(reason: reason)
    }

    func onBandwidthEstimationChanged(estimation: Int) {
        listiner.onBandwidthEstimationChanged(estimation: estimation)
    }

    func onSocketClose(code: Int, reason: String) {
        print("socket closed")
        listiner.onSocketClose(code: code, reason: reason)
    }

    func onSocketError() {
        print("soket error")
        listiner.onSocketError()
    }

    func onSocketOpen() {
        print("socket open")
        listiner.onSocketOpen()
    }

    func onAuthSuccess() {
        print("auth success")
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
