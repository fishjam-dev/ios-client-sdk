import Foundation
import Starscream

internal class FishjamClientInternal: MembraneRTCDelegate, WebSocketDelegate {
    private var config: Config?
    private var webSocket: FishjamWebsocket?
    private var listener: FishjamClientListener
    private var websocketFactory: (String) -> FishjamWebsocket
    var webrtcClient: FishjamMembraneRTC?
    private var isAuthenticated = false

    public init(listener: FishjamClientListener, websocketFactory: @escaping (String) -> FishjamWebsocket) {
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
        isAuthenticated = false
    }

    func cleanUp() {
        webrtcClient?.disconnect()
        isAuthenticated = false
        webSocket?.disconnect()
        webSocket = nil
        onDisconnected()
    }

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            websocketDidConnect()
        case .disconnected(let reason, let code):
            onSocketClose(code: code, reason: reason)
        case .text(let message):
            websocketDidReceiveMessage(text: message)
        case .binary(let data):
            websocketDidReceiveData(data: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            onDisconnected()
        case .error(_):
            onSocketError()
        default:
            break
        }
    }

    func websocketDidConnect() {
        onSocketOpen()
        let authRequest = Fishjam_PeerMessage.with({
            $0.authRequest = Fishjam_PeerMessage.AuthRequest.with({
                $0.token = self.config?.token ?? ""
            })
        })

        guard let serializedData = try? authRequest.serializedData() else {
            return
        }
        sendEvent(peerMessage: serializedData)
    }

    func websocketDidReceiveData(data: Data) {
        do {
            let peerMessage = try Fishjam_PeerMessage(serializedData: data)
            if case .authenticated(_) = peerMessage.content {
                isAuthenticated = true
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

    func websocketDidReceiveMessage(text: String) {
        print("Unsupported socket callback 'websocketDidReceiveMessage' was called.")
        onSocketError()
    }

    private func sendEvent(peerMessage: Data) {
        self.webSocket?.write(data: peerMessage)
    }

    private func receiveEvent(event: SerializedMediaEvent) {
        webrtcClient?.receiveMediaEvent(mediaEvent: event)
    }

    func onEndpointAdded(endpoint: Endpoint) {
        listener.onPeerJoined(endpoint: endpoint)
    }

    func onEndpointRemoved(endpoint: Endpoint) {
        listener.onPeerLeft(endpoint: endpoint)
    }

    func onEndpointUpdated(endpoint: Endpoint) {
        listener.onPeerUpdated(endpoint: endpoint)
    }

    func onSendMediaEvent(event: SerializedMediaEvent) {
        if (!isAuthenticated) {
          print("Tried to send media event: \(event) before authentication")
          return
        }
        let mediaEvent =
            Fishjam_PeerMessage.with({
                $0.mediaEvent = Fishjam_PeerMessage.MediaEvent.with({
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

    func onSocketClose(code: UInt16, reason: String) {
        listener.onSocketClose(code: code, reason: reason)
    }

    func onSocketError() {
        isAuthenticated = false
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
        isAuthenticated = false
        listener.onDisconnected()
    }

    func onConnected(endpointId: String, otherEndpoints: [Endpoint]) {
        listener.onJoined(peerID: endpointId, peersInRoom: otherEndpoints)
    }

    func onConnectionError(metadata: Any) {
        listener.onJoinError(metadata: metadata)
    }

    func onTrackEncodingChanged(endpointId: String, trackId: String, encoding: String) {
    }
}
