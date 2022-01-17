import Foundation
import WebRTC

// class for managing RTCPeerConnection responsible for managing its media sources and
// handling various kinds of notifications
internal class ConnectionManager {

}

extension ConnectionManager {
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()

        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        
        return RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
    }
    
    internal static func createPeerConnection(_ configuration: RTCConfiguration, constraints: RTCMediaConstraints) -> RTCPeerConnection? {
        DispatchQueue.webRTC.sync {
            factory.peerConnection(with: configuration, constraints: constraints, delegate: nil)
        }
    }

    internal static func createAudioSource(_ constraints: RTCMediaConstraints?) -> RTCAudioSource {
        // TODO: get to know why livekit is using dispatch queues for such simple tasks
        DispatchQueue.webRTC.sync {
            factory.audioSource(with: constraints)
        }
    }

    internal static func createAudioTrack(source: RTCAudioSource) -> RTCAudioTrack {
        DispatchQueue.webRTC.sync {
            factory.audioTrack(with: source, trackId: UUID().uuidString)
        }
    }


    internal static func createVideoCapturer() -> RTCVideoCapturer {
        DispatchQueue.webRTC.sync { RTCVideoCapturer() }
    }
    
    internal static func createVideoSource() -> RTCVideoSource {
        DispatchQueue.webRTC.sync { factory.videoSource() }
    }

    internal static func createVideoTrack(source: RTCVideoSource) -> RTCVideoTrack {
        DispatchQueue.webRTC.sync {
            factory.videoTrack(with: source, trackId: UUID().uuidString)
        }
    }
}