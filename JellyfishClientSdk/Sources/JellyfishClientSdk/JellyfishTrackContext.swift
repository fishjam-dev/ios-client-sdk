import class MembraneRTC.TrackContext

public class JellyfishTrackContext {
    private var trackContext: MembraneRTC.TrackContext

    public var track: RemoteTrack? { return trackContext.track }

    public var peer: Peer { return trackContext.endpoint }

    public var trackId: String { return trackContext.trackId }

    public var metadata: Metadata { return trackContext.metadata }

    public var vadStatus: VadStatus { return trackContext.vadStatus }

    public var encoding: TrackEncoding? { return trackContext.encoding }

    public var encodingReason: EncodingReason? { return trackContext.encodingReason }

    init(trackContext: MembraneRTC.TrackContext) {
        self.trackContext = trackContext
    }

    public func setOnEncodingChangedListener(listener: ((_ trackContext: JellyfishTrackContext) -> Void)?) {
        trackContext.setOnEncodingChangedListener { trackContext in
            listener?(JellyfishTrackContext(trackContext: trackContext))
        }
    }

    public func setOnVoiceActivityChangedListener(listener: ((_ trackContext: JellyfishTrackContext) -> Void)?) {
        trackContext.setOnVoiceActivityChangedListener { trackContext in
            listener?(JellyfishTrackContext(trackContext: trackContext))
        }
    }
}
