import enum MembraneRTC.EncodingReason
import struct MembraneRTC.Metadata
import protocol MembraneRTC.RemoteTrack
import class MembraneRTC.TrackContext
import enum MembraneRTC.TrackEncoding
import enum MembraneRTC.VadStatus

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

    public func setOnEncodingChangedListener(listener: ((_ trackContext: MembraneRTC.TrackContext) -> Void)?) {
        trackContext.setOnEncodingChangedListener(listener: listener)
    }

    public func setOnVoiceActivityChangedListener(listener: ((_ trackContext: MembraneRTC.TrackContext) -> Void)?) {
        trackContext.setOnVoiceActivityChangedListener(listener: listener)
    }
}
