import Foundation
import MembraneRTC

public typealias Peer = Endpoint

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
    func onJoined(peerID: String, peersInRoom: [Peer])

    /**
     * Called when endpoint was not accepted
     * @param metadata - Pass thru for client application to communicate further actions to frontend
     */
    func onJoinError(metadata: Any)


    /**
     * Called each time new endpoint joins the room.
     */
    func onPeerJoined(peer: Peer)

    /**
     * Called each time endpoint leaves the room.
     */
    func onPeerLeft(peer: Peer)

    /**
     * Called each time endpoint has its metadata updated.
     */
    func onPeerUpdated(peer: Peer)

    /**
     * Called when data in a new track arrives.
     *
     * This callback is always called after {@link JellyfishClientListener.onTrackAdded}.
     * It informs user that data related to the given track arrives and can be played or displayed.
     */
    func onTrackReady(ctx: TrackContext)

    /**
     * Called each time the endpoint which was already in the room, adds new track. Fields track and stream will be set to null.
     * These fields will be set to non-null value in {@link JellyfishClientListener.onTrackReady}
     */
    func onTrackAdded(ctx: TrackContext)
    /**
     * Called when some track will no longer be sent.
     *
     * It will also be called before {@link JellyfishClientListener.onEndpointRemoved} for each track of this endpoint.
     */
    func onTrackRemoved(ctx: TrackContext)

    /**
     * Called each time endpoint has its track metadata updated.
     */
    func onTrackUpdated(ctx: TrackContext)

    /**
     * Called every time the server estimates client's bandwidth.
     *
     * @param estimation - client's available incoming bitrate estimated
     * by the server. It's measured in bits per second.
     */
    func onBandwidthEstimationChanged(estimation: Int)
}
