import MembraneRTC

public class JellyfishClientSdk {
   private var listiner: JellyfishClientListener
   
   public init(listener: JellyfishClientListener) {
     listiner = listener;
   }
   
   private var client = JellyfishClientInternal(self.listener)

   /**
    * Connects to the server using the WebSocket connection
    *
    * @param config - Configuration object for the client
    */
   public func connect(config: Config) {
       client.connect(config)
   }

   /**
    * Leaves the room. This function should be called when user leaves the room in a clean way e.g. by clicking a
    * dedicated, custom button `disconnect`. As a result there will be generated one more media event that should be sent
    * to the RTC Engine. Thanks to it each other peer will be notified that peer left in onPeerLeft,
    */
   public func leave() {
       client.leave()
   }

   /**
    * Disconnect from the room, and close the websocket connection. Tries to leave the room gracefully, but if it fails,
    * it will close the websocket anyway.
    */
   public func cleanUp() {
       client.cleanUp()
   }

   /**
    * Tries to join the room. If user is accepted then {@link JellyfishClient.onJoinSuccess} will be called.
    * In other case {@link JellyfishClient.onJoinError} is invoked.
    *
    * @param peerMetadata - Any information that other peers will receive in onPeerJoined
    * after accepting this peer
    */
   public func join(peerMetadata: Metadata = emptyMap()) {
       client.webrtcClient.join(peerMetadata)
   }

   /**
    * Creates a video track utilizing device's camera.
    *
    * The client assumes that the user has already granted camera permissions.
    *
    * @param videoParameters a set of target parameters such as camera resolution, frame rate or simulcast configuration
    * @param metadata the metadata that will be sent to the <strong>Membrane RTC Engine</strong> for media negotiation
    * @param captureDeviceName the name of the device to start video capture with, you can get device name by using
    * `LocalVideoTrack.getCaptureDevices` method
    * @return an instance of the video track
    */
   public func createVideoTrack(
       videoParameters: VideoParameters,
       metadata: Metadata,
       captureDeviceName: String? = null,
   ) -> LocalVideoTrack {
       return client.webrtcClient.createVideoTrack(videoParameters, metadata, captureDeviceName)
   }

   /**
    * Creates an audio track utilizing device's microphone.
    *
    * The client assumes that the user has already granted microphone recording permissions.
    *
    * @param metadata the metadata that will be sent to the <strong>Membrane RTC Engine</strong> for media negotiation
    * @return an instance of the audio track
    */
   public func createAudioTrack(metadata: Metadata) -> LocalAudioTrack {
       return client.webrtcClient.createAudioTrack(metadata)
   }

   /**
    * Creates a screen track recording the entire device's screen.
    *
    * The method requires a media projection permission to be able to start the recording. The client assumes that the intent is valid.
    *
    * @param mediaProjectionPermission a valid media projection permission intent that can be used to starting a screen capture
    * @param videoParameters a set of target parameters of the screen capture such as resolution, frame rate or simulcast configuration
    * @param metadata the metadata that will be sent to the <strong>Membrane RTC Engine</strong> for media negotiation
    * @param onEnd callback that will be invoked once the screen capture ends
    * @return an instance of the screencast track
    */
   public func createScreencastTrack(
       mediaProjectionPermission: Intent,
       videoParameters: VideoParameters,
       metadata: Metadata,
       onEnd: (() -> Unit)? = null,
   ) -> LocalScreencastTrack {
       return client.webrtcClient.createScreencastTrack(
           mediaProjectionPermission,
           videoParameters,
           metadata,
           onEnd,
       )
   }

   /**
    * Removes an instance of local track from the client.
    *
    * @param trackId an id of a valid local track that has been created using the current client
    * @return a boolean whether the track has been successfully removed or not
    */
   public func removeTrack(trackId: String) -> Boolean {
       return client.webrtcClient.removeTrack(trackId)
   }

   /**
    * Sets track encoding that server should send to the client library.
    *
    * The encoding will be sent whenever it is available.
    * If chosen encoding is temporarily unavailable, some other encoding
    * will be sent until chosen encoding becomes active again.
    *
    * @param trackId an id of a remote track
    * @param encoding an encoding to receive
    */
   public func setTargetTrackEncoding(trackId: String, encoding: TrackEncoding) {
       client.webrtcClient.setTargetTrackEncoding(trackId, encoding)
   }

   /**
    * Enables track encoding so that it will be sent to the server.
    *
    * @param trackId an id of a local track
    * @param encoding an encoding that will be enabled
    */
   public func enableTrackEncoding(trackId: String, encoding: TrackEncoding) {
       client.webrtcClient.enableTrackEncoding(trackId, encoding)
   }

   /**
    * Disables track encoding so that it will be no longer sent to the server.
    *
    * @param trackId and id of a local track
    * @param encoding an encoding that will be disabled
    */
   public func disableTrackEncoding(trackId: String, encoding: TrackEncoding) {
       client.webrtcClient.disableTrackEncoding(trackId, encoding)
   }

   /**
    * Updates the metadata for the current peer.
    * @param peerMetadata Data about this peer that other peers will receive upon joining.
    *
    * If the metadata is different from what is already tracked in the room, the optional
    * callback `onPeerUpdated` will be triggered for other peers in the room.
    */
   public func updatePeerMetadata(peerMetadata: Metadata) {
       client.webrtcClient.updatePeerMetadata(peerMetadata)
   }

   /**
    * Updates the metadata for a specific track.
    * @param trackId local track id of audio or video track.
    * @param trackMetadata Data about this track that other peers will receive upon joining.
    *
    * If the metadata is different from what is already tracked in the room, the optional
    * callback `onTrackUpdated` will be triggered for other peers in the room.
    */
   public func updateTrackMetadata(trackId: String, trackMetadata: Metadata) {
       client.webrtcClient.updateTrackMetadata(trackId, trackMetadata)
   }

   /**
    * Updates maximum bandwidth for the track identified by trackId.
    * This value directly translates to quality of the stream and, in case of video, to the amount of RTP packets being sent.
    * In case trackId points at the simulcast track bandwidth is split between all of the variant streams proportionally to their resolution.
    * @param trackId track id of a video track
    * @param bandwidthLimit bandwidth in kbps
    */
   public func setTrackBandwidth(trackId: String, bandwidthLimit: TrackBandwidthLimit.BandwidthLimit) {
       client.webrtcClient.setTrackBandwidth(trackId, bandwidthLimit)
   }

   /**
    * Updates maximum bandwidth for the given simulcast encoding of the given track.
    * @param trackId track id of a video track
    * @param encoding rid of the encoding
    * @param bandwidthLimit bandwidth in kbps
    */
   public func setEncodingBandwidth(
       trackId: String,
       encoding: String,
       bandwidthLimit: TrackBandwidthLimit.BandwidthLimit
   ) {
       client.webrtcClient.setEncodingBandwidth(trackId, encoding, bandwidthLimit)
   }

   /**
    * Changes severity level of debug logs
    * @param severity enum value representing the logging severity
    */
   public func changeWebRTCLoggingSeverity(severity: Logging.Severity) {
       client.webrtcClient.changeWebRTCLoggingSeverity(severity)
   }

   /**
    * Returns current connection stats
    * @return a map containing statistics
    */
   public func getStats() -> [String, RTCStats] {
       return client.webrtcClient.getStats()
   }
}
