import MembraneRTC
import Starscream
import WebRTC

internal class JellyfishWebsocketWrapper: JellyfishWebsocket {
    var delegate: WebSocketDelegate?
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

internal protocol JellyfishMembraneRTC {
    func disconnect()
    func receiveMediaEvent(mediaEvent: SerializedMediaEvent)
}

extension MembraneRTC: JellyfishMembraneRTC {}

internal func mockWebsocketFactory(url: String) -> JellyfishWebsocket {
    let url = URL(string: url)
    return JellyfishWebsocketWrapper(socket: WebSocket(url: url!))
}
