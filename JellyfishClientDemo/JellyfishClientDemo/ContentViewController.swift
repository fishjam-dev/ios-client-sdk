//
//  ContentViewController.swift
//  JellyfishClientDemo
//
//  Created by Karol Sygiet on 02/06/2023.
//

import Foundation
import JellyfishClientSdk
import MembraneRTC
import UIKit

struct Participant {
    let id: String
    let displayName: String
    var isAudioTrackActive: Bool
}

class ParticipantVideo: Identifiable, ObservableObject {
    let id: String
    let isScreensharing: Bool

    @Published var participant: Participant
    @Published var isActive: Bool
    @Published var videoTrack: VideoTrack?
    @Published var mirror: Bool
    @Published var vadStatus: VadStatus

    init(
        id: String, participant: Participant, videoTrack: VideoTrack? = nil, isScreensharing: Bool = false,
        isActive: Bool = false,
        mirror: Bool = false
    ) {
        self.id = id
        self.participant = participant
        self.videoTrack = videoTrack
        self.isScreensharing = isScreensharing
        self.isActive = isActive
        self.mirror = mirror
        self.vadStatus = VadStatus.silence
    }
}

class ContentViewController: ObservableObject {
    private var jellyfishClient: JellyfishClientSdk?
    public private(set) var client: MembraneRTC?

    @Published var participants: [String: Participant]
    @Published var participantVideos: [ParticipantVideo]

    var localParticipantId: String
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?

    @Published var errorMessage: String?

    public init() {
        self.participants = [:]
        self.participantVideos = []
        self.localParticipantId = "local"

        self.jellyfishClient = JellyfishClientSdk(listiner: self)

    }

    public func connect() {
        let conf = Config(
            websocketUrl: "ws://192.168.0.164:4000/socket/peer/websocket",
            token:
                "SFMyNTY.g2gDdAAAAAJkAAdwZWVyX2lkbQAAACQ5MTEzZmRkYy02M2I0LTRhNjItYTZjOC0xOTMxODQ4M2M3MDJkAAdyb29tX2lkbQAAACQwMTM3NGE0OC0yOGRjLTQ0YzgtOWFhNC0yZDY2ZWQ0YjRkNTJuBgDizoiPiAFiAAFRgA.wKMlKH3klK_L_c1CHvVKJOwhISSNeDJaGdxociu-wDE"
        )

        let isMicEnabled = true
        let isCameraEnabled = true
        let isScreensharingEnabled = false

        let videoTrackMetadata =
            [
                "user_id": "UNKNOWN", "active": true, "type": "camera",
            ] as [String: Any]
        let audioTrackMetadata =
            [
                "user_id": "UNKNOWN", "active": true, "type": "audio",
            ] as [String: Any]

        let preset = VideoParameters.presetHD43
        let videoParameters = VideoParameters(
            dimensions: preset.dimensions.flip(),
            maxBandwidth: .SimulcastBandwidthLimit(["l": 150, "m": 500, "h": 1500]),
            simulcastConfig: SimulcastConfig(enabled: false)
        )

        jellyfishClient?.connect(config: conf)

        self.localVideoTrack = jellyfishClient?.createVideoTrack(
            videoParameters: videoParameters, metadata: .init(videoTrackMetadata))
        self.localAudioTrack = jellyfishClient?.createAudioTrack(metadata: .init(audioTrackMetadata))

    }

    public func disconnect() {
        jellyfishClient?.cleanUp()
    }
}

extension ContentViewController: JellyfishClientListener {
    func findParticipantVideo(id: String) -> ParticipantVideo? {
        return participantVideos.first(where: { $0.id == id })
    }

    func add(video: ParticipantVideo) {
        DispatchQueue.main.async {
            guard self.findParticipantVideo(id: video.id) == nil else {
                print("RoomController tried to add already existing ParticipantVideo")
                return
            }

            self.participantVideos.append(video)
        }
    }

    func remove(video: ParticipantVideo) {
        DispatchQueue.main.async {
            guard let idx = self.participantVideos.firstIndex(where: { $0.id == video.id }) else {
                return
            }

            self.participantVideos.remove(at: idx)
        }
    }

    func findParticipantVideoByOwner(participantId: String, isScreencast: Bool = false) -> ParticipantVideo? {
        return self.participantVideos.first(where: {
            $0.participant.id == participantId && $0.isScreensharing == isScreencast
        })
    }

    func onSendMediaEvent(event: SerializedMediaEvent) {
        print("sed", event)
    }

    func onJoinSuccess(peerID: String, peersInRoom: [Peer]) {
        print("join success")
        self.localParticipantId = peerID

        let localParticipant = Participant(id: peerID, displayName: "Me", isAudioTrackActive: true)

        let participants = peersInRoom.map { peer in
            Participant(
                id: peer.id, displayName: peer.metadata["displayName"] as? String ?? "", isAudioTrackActive: false)
        }

        DispatchQueue.main.async {
            self.participantVideos = participants.map { p in
                ParticipantVideo(id: p.id, participant: p, videoTrack: nil, isActive: false)
            }

            guard let videoTrack = self.localVideoTrack else {
                fatalError("failed to setup local video")
            }

            self.participants[localParticipant.id] = localParticipant
            self.participantVideos.append(
                ParticipantVideo(
                    id: self.localParticipantId, participant: localParticipant, videoTrack: videoTrack, isActive: true))
            participants.forEach { participant in self.participants[participant.id] = participant }
        }
    }

    func onJoinError(metadata _: Any) {
        errorMessage = "Failed to join a room"
    }

    func onTrackReady(ctx: TrackContext) {
        ctx.setOnVoiceActivityChangedListener { trackContext in
            if let participantVideo = self.participantVideos.first(where: { $0.participant.id == trackContext.peer.id })
            {
                DispatchQueue.main.async {
                    participantVideo.vadStatus = trackContext.vadStatus
                }
            }
        }

        guard var participant = participants[ctx.peer.id] else {
            return
        }

        guard let videoTrack = ctx.track as? VideoTrack else {
            DispatchQueue.main.async {
                participant.isAudioTrackActive = ctx.metadata["active"] as? Bool == true
                self.participants[ctx.peer.id] = participant
                let pv = self.findParticipantVideoByOwner(participantId: ctx.peer.id)
                pv?.participant = participant
            }

            return
        }

        // there can be a situation where we simply need to replace `videoTrack` for
        // already existing video, happens when dynamically adding new local track
        if let participantVideo = participantVideos.first(where: { $0.id == ctx.trackId }) {
            DispatchQueue.main.async {
                participantVideo.videoTrack = videoTrack
            }

            return
        }

        // track is seen for the first time so initialize the participant's video
        let isScreensharing = ctx.metadata["type"] as? String == "screensharing"
        let video = ParticipantVideo(
            id: ctx.trackId, participant: participant, videoTrack: videoTrack,
            isScreensharing: isScreensharing, isActive: ctx.metadata["active"] as? Bool == true || isScreensharing)

        guard let existingVideo = self.findParticipantVideoByOwner(participantId: ctx.peer.id) else {
            add(video: video)
            return
        }

        if isScreensharing {
            add(video: video)
            return
        }

        guard let idx = self.participantVideos.firstIndex(where: { $0.id == existingVideo.id }) else {
            return
        }
        DispatchQueue.main.async {
            self.participantVideos[idx] = video
        }
    }

    func onTrackAdded(ctx _: TrackContext) {}

    func onTrackRemoved(ctx: TrackContext) {
        if let video = participantVideos.first(where: { $0.id == ctx.trackId }) {
            remove(video: video)
        }
    }

    func onTrackUpdated(ctx: TrackContext) {
        let isActive = ctx.metadata["active"] as? Bool ?? false

        if ctx.metadata["type"] as? String == "camera" {
            DispatchQueue.main.async {
                self.participantVideos.first(where: { $0.participant.id == ctx.peer.id })?.isActive =
                    isActive
            }
        } else {
            DispatchQueue.main.async {
                guard var p = self.participants[ctx.peer.id] else {
                    return
                }
                p.isAudioTrackActive = isActive
                self.participants[ctx.peer.id] = p
                self.participantVideos.first(where: { $0.participant.id == ctx.peer.id })?.participant = p
            }

        }
    }

    func onPeerJoined(peer: Peer) {
        self.participants[peer.id] = Participant(
            id: peer.id, displayName: peer.metadata["displayName"] as? String ?? "", isAudioTrackActive: false)
        let pv =
            ParticipantVideo(id: peer.id, participant: participants[peer.id]!, videoTrack: nil, isActive: false)
        add(video: pv)
    }

    func onPeerLeft(peer: Peer) {
        DispatchQueue.main.async {
            self.participants.removeValue(forKey: peer.id)
            self.participantVideos = self.participantVideos.filter({ $0.participant.id != peer.id })
        }
    }

    func onPeerUpdated(peer _: Peer) {}

    func onSocketClose(code: Int, reason: String) {}

    func onSocketError() {}

    func onSocketOpen() {}

    func onAuthSuccess() {
        jellyfishClient?.join(peerMetadata: .init(["displayName": "iphoneUser"]))
    }

    func onAuthError() {}

    func onDisconnected() {}
}
