import MembraneRTC
import Starscream
import WebRTC

internal protocol JellyfishMembraneRTC {
    func disconnect()
    func receiveMediaEvent(mediaEvent: SerializedMediaEvent)
}

extension MembraneRTC: JellyfishMembraneRTC {}
