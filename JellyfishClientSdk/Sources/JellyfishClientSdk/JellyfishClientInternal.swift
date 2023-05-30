internal class JellyfishClientInternal: JellyfishClientListener {
    private var webSocket: WebSocket? = null
    var webrtcClient = MembraneRTC.create()

    public init() {
    }

    func connect(config: Config) {
        var request = Request.Builder().url(config.websocketUrl).build()
        var webSocket = OkHttpClient().newWebSocket(
            request,
            object: WebSocketListener {
                override func onClosed(webSocket: WebSocket, code: Int, reason: String) {
                    listener.onSocketClose(code, reason)
                }

                override func onMessage(webSocket: WebSocket, bytes: ByteString) {
                    do {
                        var peerMessage = PeerMessage.parseFrom(bytes.toByteArray())
                        if peerMessage.hasAuthenticated() {
                            listener.onAuthSuccess()
                        } else if peerMessage.hasMediaEvent() {
                            receiveEvent(peerMessage.mediaEvent.data)
                        } else {
                            Timber.w("Received unexpected websocket message: $peerMessage")
                        }
                    } catch (e:Exception) {
                        Timber.e("Received invalid websocket message", e)
                    }
                }

                override func onOpen(webSocket: WebSocket, response: Response) {
                    listener.onSocketOpen()
                    var authRequest =
                        PeerMessage
                        .newBuilder()
                        .setAuthRequest(PeerMessage.AuthRequest.newBuilder().setToken(config.token))
                        .build()
                    sendEvent(authRequest)
                }

                override func onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                    listener.onSocketError(t, response)
                }
            }
        )

        this.webSocket = webSocket
    }

    func leave() {
        webrtcClient.disconnect()
    }

    func cleanUp() {
        webrtcClient.disconnect()
        webSocket?.close(1000, null)
        webSocket = null
        listener.onDisconnected()
    }

    private func sendEvent(peerMessage: PeerMessage) {
        webSocket?.send(peerMessage.toByteArray().toByteString())
    }

    private func receiveEvent(event: SerializedMediaEvent) {
        webrtcClient.receiveMediaEvent(event)
    }

    override func onJoinError(metadata: Any) {
        listener.onJoinError(metadata)
    }

    override func onJoinSuccess(peerID: String, peersInRoom: List<Peer>) {
        listener.onJoinSuccess(peerID, peersInRoom)
    }

    override func onPeerJoined(peer: Peer) {
        listener.onPeerJoined(peer)
    }

    override func onPeerLeft(peer: Peer) {
        listener.onPeerLeft(peer)
    }

    override func onPeerUpdated(peer: Peer) {
        listener.onPeerUpdated(peer)
    }

    override func onSendMediaEvent(event: SerializedMediaEvent) {
        var mediaEvent =
            PeerMessage
            .newBuilder()
            .setMediaEvent(MediaEvent.newBuilder().setData(event))
            .build()
        sendEvent(mediaEvent)
    }

    override func onTrackAdded(ctx: TrackContext) {
        listener.onTrackAdded(ctx)
    }

    override func onTrackReady(ctx: TrackContext) {
        listener.onTrackReady(ctx)
    }

    override func onTrackRemoved(ctx: TrackContext) {
        listener.onTrackRemoved(ctx)
    }

    override func onTrackUpdated(ctx: TrackContext) {
        listener.onTrackUpdated(ctx)
    }

    override func onRemoved(reason: String) {
        listener.onRemoved(reason)
    }

    override func onBandwidthEstimationChanged(estimation: Long) {
        listener.onBandwidthEstimationChanged(estimation)
    }
}
