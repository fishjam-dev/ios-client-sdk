import Foundation

public protocol JellyfishClientListener {
    /**
     * Emitted when the websocket connection is closed
     */
    func onSocketClose(code: Int, reason: String)

    /**
     * Emitted when occurs an error in the websocket connection
     */
    func onSocketError()
    /**
     * Emitted when the websocket connection is opened
     */
    func onSocketOpen()

    /**
     * Emitted when authentication is successful
     */
    func onAuthSuccess()

    /**
     * Emitted when authentication fails
     */
    func onAuthError()

    /**
     * Emitted when the connection is closed
     */
    func onDisconnected()

    /**
     * Called when peer was accepted.
     */
    func onJoined(peerID: String, peersInRoom: [Endpoint])

    /**
     * Called when peer was not accepted
     * @param metadata - Pass thru for client application to communicate further actions to frontend
     */
    func onJoinError(metadata: Any)

    /**
     * Called each time new peer joins the room.
     */
    func onPeerJoined(peer: Endpoint)

    /**
     * Called each time peer leaves the room.
     */
    func onPeerLeft(peer: Endpoint)

    /**
     * Called each time peer has its metadata updated.
     */
    func onPeerUpdated(peer: Endpoint)

    /**
     * Called when data in a new track arrives.
     *
     * This callback is always called after {@link JellyfishClientListener.onTrackAdded}.
     * It informs user that data related to the given track arrives and can be played or displayed.
     */
    func onTrackReady(ctx: JellyfishTrackContext)

    /**
     * Called each time the peer which was already in the room, adds new track. Fields track and stream will be set to null.
     * These fields will be set to non-null value in {@link JellyfishClientListener.onTrackReady}
     */
    func onTrackAdded(ctx: JellyfishTrackContext)
    /**
     * Called when some track will no longer be sent.
     *
     * It will also be called before {@link JellyfishClientListener.onPeerLeft} for each track of this peer.
     */
    func onTrackRemoved(ctx: JellyfishTrackContext)

    /**
     * Called each time peer has its track metadata updated.
     */
    func onTrackUpdated(ctx: JellyfishTrackContext)

    /**
     * Called every time the server estimates client's bandwidth.
     *
     * @param estimation - client's available incoming bitrate estimated
     * by the server. It's measured in bits per second.
     */
    func onBandwidthEstimationChanged(estimation: Int)
}
