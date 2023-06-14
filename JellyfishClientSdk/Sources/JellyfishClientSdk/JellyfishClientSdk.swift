import MembraneRTC
import WebRTC
import Starscream


public struct Config {
    var websocketUrl: String
    var token: String

    public init(websocketUrl: String, token: String) {
        self.websocketUrl = websocketUrl
        self.token = token
    }
}

public protocol JellyfishWebSocketDelegate {
    func websocketDidConnect()
    func websocketDidDisconnect(error: Error?)
    func websocketDidReceiveData(data: Data)
}


protocol JellyfishWebsocket: JellyfishWebSocketDelegate {
  var delegate: JellyfishWebSocketDelegate? {get set}
  func connect()
  func disconnect()
  func write(data: Data)
}


public class MockJellyfishClientListener: JellyfishClientListener {
  public func onSocketClose(code: Int, reason: String) {}

  public func onSocketError() {}

  public func onSocketOpen() {}

  public func onAuthSuccess() {}

  public func onAuthError() {}

  public func onDisconnected() {}

  public func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {}

  public func onJoinError(metadata: Any) {}

  public func onPeerJoined(peer: Peer) {}

  public func onPeerLeft(peer: Peer) {}

  public func onPeerUpdated(peer: Peer) {}

  public func onTrackReady(ctx: TrackContext) {}

  public func onTrackAdded(ctx: TrackContext) {}

  public func onTrackRemoved(ctx: TrackContext) {}

  public func onTrackUpdated(ctx: TrackContext) {}

  public func onSendMediaEvent(event: SerializedMediaEvent) {}

}


protocol JellyfishMembraneRtc {
  static func create(with options: MembraneRTC.CreateOptions, delegate: MembraneRTCDelegate) -> MembraneRTC
  func join(peerMetadata: Metadata)
  func disconnect()
  func receiveMediaEvent(mediaEvent: SerializedMediaEvent)
  func createVideoTrack(videoParameters: VideoParameters, metadata: Metadata, captureDeviceId: String?) -> LocalVideoTrack
  func createAudioTrack(metadata: Metadata) -> LocalAudioTrack
  func createScreencastTrack(
      appGroup: String, videoParameters: VideoParameters, metadata: Metadata,
      onStart: @escaping (_ track: LocalScreenBroadcastTrack) -> Void, onStop: @escaping () -> Void
  ) -> LocalScreenBroadcastTrack
  func setTargetTrackEncoding(trackId: String, encoding: TrackEncoding)
  func removeTrack(trackId: String) -> Bool
  func enableTrackEncoding(trackId: String, encoding: TrackEncoding)
  func disableTrackEncoding(trackId: String, encoding: TrackEncoding)
  func setTrackBandwidth(trackId: String, bandwidth: BandwidthLimit)
  func updatePeerMetadata(peerMetadata: Metadata)
  func updateTrackMetadata(trackId: String, trackMetadata: Metadata)
  func setEncodingBandwidth(trackId: String, encoding: String, bandwidth: BandwidthLimit)
  func getStats() -> [String: RTCStats]
  func changeWebRTCLoggingSeverity(severity: RTCLoggingSeverity)
}

class JellyfishMembraneRtcWrapper: JellyfishMembraneRtc {
  var membraneRTC: MembraneRTC?
  
  init() {
    self.membraneRTC = MembraneRTC.create(with: options, delegate: delegate)
  }

  func disconnect() {
    self.membraneRTC?.disconnect()
  }
  
  func receiveMediaEvent(mediaEvent: SerializedMediaEvent) {
    self.membraneRTC?.receiveMediaEvent(mediaEvent: mediaEvent)
  }
  
  func createVideoTrack(videoParameters: VideoParameters, metadata: Metadata, captureDeviceId: String?) -> LocalVideoTrack {
    return self.membraneRTC!.createVideoTrack(videoParameters: videoParameters, metadata: metadata)
  }
  
  func createAudioTrack(metadata: MembraneRTC.Metadata) -> MembraneRTC.LocalAudioTrack {
    <#code#>
  }
  
  func createScreencastTrack(appGroup: String, videoParameters: MembraneRTC.VideoParameters, metadata: MembraneRTC.Metadata, onStart: @escaping (MembraneRTC.LocalScreenBroadcastTrack) -> Void, onStop: @escaping () -> Void) -> MembraneRTC.LocalScreenBroadcastTrack {
    <#code#>
  }
  
  func setTargetTrackEncoding(trackId: String, encoding: MembraneRTC.TrackEncoding) {
    <#code#>
  }
  
  func removeTrack(trackId: String) -> Bool {
    <#code#>
  }
  
  func enableTrackEncoding(trackId: String, encoding: MembraneRTC.TrackEncoding) {
    <#code#>
  }
  
  func disableTrackEncoding(trackId: String, encoding: MembraneRTC.TrackEncoding) {
    <#code#>
  }
  
  func setTrackBandwidth(trackId: String, bandwidth: MembraneRTC.BandwidthLimit) {
    <#code#>
  }
  
  func updatePeerMetadata(peerMetadata: MembraneRTC.Metadata) {
    <#code#>
  }
  
  func updateTrackMetadata(trackId: String, trackMetadata: MembraneRTC.Metadata) {
    <#code#>
  }
  
  func setEncodingBandwidth(trackId: String, encoding: String, bandwidth: MembraneRTC.BandwidthLimit) {
    <#code#>
  }
  
  func getStats() -> [String : MembraneRTC.RTCStats] {
    <#code#>
  }
  
  func changeWebRTCLoggingSeverity(severity: RTCLoggingSeverity) {
    <#code#>
  }
  
  func join(peerMetadata: Metadata) {
    
  }
  
  
}

class JellyfishWebsocketWrapper: JellyfishWebsocket {
  var delegate: JellyfishWebSocketDelegate?
  var socket: WebSocket
  
  func websocketDidConnect() {}
  
  func websocketDidDisconnect(error: Error?) {}
    
  func websocketDidReceiveData(data: Data) {}
  
  public init(socket: WebSocket) {
    self.delegate = nil
    self.socket = socket
  }

  func connect() {
    socket.connect()
  }

  func disconnect() {
    socket.disconnect()
  }

  func write(data: Data) {
    socket.write(data: data)
  }
}

func websocketFactory(url: String) -> JellyfishWebsocket {
  let url = URL(string: url)
  return JellyfishWebsocketWrapper(socket: WebSocket(url: url!))
}



public class JellyfishClientSdk {
    private var client: JellyfishClientInternal
    private var webrtc: MembraneRTC

    public init(listiner: JellyfishClientListener) {
      webrtc = MembraneRTC.create(delegate: )
      self.client = JellyfishClientInternal(listiner: listiner, websocketFactory: websocketFactory, JellyfishMembraneRtcWrapper(webrtc))
    }

    /**
    * Connects to the server using the WebSocket connection
    *
    * @param config - Configuration object for the client
    */
    public func connect(config: Config) {
        client.connect(config: config)
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
    public func join(peerMetadata: Metadata) {
        client.webrtcClient?.join(peerMetadata: peerMetadata)
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
        captureDeviceName: String? = nil
    ) -> LocalVideoTrack? {
        return client.webrtcClient?.createVideoTrack(
            videoParameters: videoParameters, metadata: metadata, captureDeviceId: captureDeviceName)
    }

    /**
    * Creates an audio track utilizing device's microphone.
    *
    * The client assumes that the user has already granted microphone recording permissions.
    *
    * @param metadata the metadata that will be sent to the <strong>Membrane RTC Engine</strong> for media negotiation
    * @return an instance of the audio track
    */
    public func createAudioTrack(metadata: Metadata) -> LocalAudioTrack? {
        return client.webrtcClient?.createAudioTrack(metadata: metadata)
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
        appGroup: String,
        videoParameters: VideoParameters,
        metadata: Metadata,
        onStart: @escaping (_ track: LocalScreenBroadcastTrack) -> Void,
        onStop: @escaping () -> Void
    ) -> LocalScreenBroadcastTrack? {
        return client.webrtcClient?.createScreencastTrack(
            appGroup: appGroup,
            videoParameters: videoParameters,
            metadata: metadata,
            onStart: onStart,
            onStop: onStop
        )
    }

    /**
    * Removes an instance of local track from the client.
    *
    * @param trackId an id of a valid local track that has been created using the current client
    * @return a boolean whether the track has been successfully removed or not
    */
    public func removeTrack(trackId: String) -> Bool {
        return client.webrtcClient?.removeTrack(trackId: trackId) ?? false
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
        client.webrtcClient?.setTargetTrackEncoding(trackId: trackId, encoding: encoding)
    }

    /**
    * Enables track encoding so that it will be sent to the server.
    *
    * @param trackId an id of a local track
    * @param encoding an encoding that will be enabled
    */
    public func enableTrackEncoding(trackId: String, encoding: TrackEncoding) {
        client.webrtcClient?.enableTrackEncoding(trackId: trackId, encoding: encoding)
    }

    /**
    * Disables track encoding so that it will be no longer sent to the server.
    *
    * @param trackId and id of a local track
    * @param encoding an encoding that will be disabled
    */
    public func disableTrackEncoding(trackId: String, encoding: TrackEncoding) {
        client.webrtcClient?.disableTrackEncoding(trackId: trackId, encoding: encoding)
    }

    /**
    * Updates the metadata for the current peer.
    * @param peerMetadata Data about this peer that other peers will receive upon joining.
    *
    * If the metadata is different from what is already tracked in the room, the optional
    * callback `onPeerUpdated` will be triggered for other peers in the room.
    */
    public func updatePeerMetadata(peerMetadata: Metadata) {
        client.webrtcClient?.updatePeerMetadata(peerMetadata: peerMetadata)
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
        client.webrtcClient?.updateTrackMetadata(trackId: trackId, trackMetadata: trackMetadata)
    }

    /**
    * Updates maximum bandwidth for the track identified by trackId.
    * This value directly translates to quality of the stream and, in case of video, to the amount of RTP packets being sent.
    * In case trackId points at the simulcast track bandwidth is split between all of the variant streams proportionally to their resolution.
    * @param trackId track id of a video track
    * @param bandwidthLimit bandwidth in kbps
    */
    public func setTrackBandwidth(trackId: String, bandwidthLimit: BandwidthLimit) {
        client.webrtcClient?.setTrackBandwidth(trackId: trackId, bandwidth: bandwidthLimit)
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
        bandwidthLimit: BandwidthLimit
    ) {
        client.webrtcClient?.setEncodingBandwidth(trackId: trackId, encoding: encoding, bandwidth: bandwidthLimit)
    }

    /**
    * Changes severity level of debug logs
    * @param severity enum value representing the logging severity
    */
    public func changeWebRTCLoggingSeverity(severity: RTCLoggingSeverity) {
        client.webrtcClient?.changeWebRTCLoggingSeverity(severity: severity)
    }

    /**
    * Returns current connection stats
    * @return a map containing statistics
    */
    public func getStats() -> [String: RTCStats] {
        return client.webrtcClient?.getStats() ?? [:]
    }
}
