//
//  JellyfishTrackContext.swift
//
//
//  Created by Karol Sygiet on 28/07/2023.
//

import MembraneRTC

public class JellyfishTrackContext {
    private var trackContext: TrackContext

    public var track: RemoteTrack? { return trackContext.track }

    public var peer: Peer { return trackContext.endpoint }

    public var trackId: String { return trackContext.trackId }

    public var metadata: Metadata { return trackContext.metadata }

    public var vadStatus: VadStatus { return trackContext.vadStatus }

    public var encoding: TrackEncoding? { return trackContext.encoding }

    public var encodingReason: EncodingReason? { return trackContext.encodingReason }

    init(trackContext: TrackContext) {
        self.trackContext = trackContext
    }

    public func setOnEncodingChangedListener(listener: ((_ trackContext: TrackContext) -> Void)?) {
        trackContext.setOnEncodingChangedListener(listener: listener)
    }

    public func setOnVoiceActivityChangedListener(listener: ((_ trackContext: TrackContext) -> Void)?) {
        trackContext.setOnVoiceActivityChangedListener(listener: listener)
    }
}
