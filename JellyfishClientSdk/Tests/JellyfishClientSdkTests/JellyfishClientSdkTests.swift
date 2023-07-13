import Foundation
import MembraneRTC
import Mockingbird
import XCTest

@testable import JellyfishClientSdk
@testable import Starscream

final class JellyfishClientSdkTests: XCTestCase {
    let mockedWebSocket = mock(JellyfishWebsocket.self)
    let jellyfishClientListener = mock(JellyfishClientListener.self)
    let testConfig = Config(websocketUrl: "ws:\\test.com", token: "testTOKEN")
    let socket = WebSocket(url: URL(string: "ws:\\test.com")!)
    var jellyfishClient: JellyfishClientInternal?
    var webrtc: JellyfishMembraneRTC?

    func getMockWebsocket(url: String) -> JellyfishWebsocket {
        return self.mockedWebSocket
    }

    static func generateDataFromMessage(_ message: Jellyfish_PeerMessage) -> Data {
        guard let serializedData = try? message.serializedData() else {
            return Data()
        }

        return serializedData
    }

    let authRequest = generateDataFromMessage(
        Jellyfish_PeerMessage.with({
            $0.authRequest = Jellyfish_PeerMessage.AuthRequest.with({
                $0.token = "testTOKEN"
            })
        }))

    let authResponse = generateDataFromMessage(
        Jellyfish_PeerMessage.with({
            $0.authenticated = Jellyfish_PeerMessage.Authenticated()
        }))

    let joinEvent = generateDataFromMessage(
        Jellyfish_PeerMessage.with({
            $0.mediaEvent = Jellyfish_PeerMessage.MediaEvent.with({
                $0.data = "join"
            })
        })
    )

    let sdpOfferEvent = generateDataFromMessage(
        Jellyfish_PeerMessage.with({
            $0.mediaEvent = Jellyfish_PeerMessage.MediaEvent.with({
                $0.data = "sdpOffer"
            })
        })
    )

    override func setUp() {
        let webrtc = mock(JellyfishMembraneRTC.self)
        let jellyfishClient = JellyfishClientInternal(
            listener: self.jellyfishClientListener, websocketFactory: getMockWebsocket)
        jellyfishClient.webrtcClient = webrtc
        self.jellyfishClient = jellyfishClient
        self.webrtc = webrtc

        givenSwift(self.mockedWebSocket.connect()).will {
            self.jellyfishClient?.websocketDidConnect(socket: socket)
        }
    }

    func connect() {
        jellyfishClient?.connect(config: self.testConfig)
        verifyClientSent(authRequest)
        sendToClient(authResponse)
    }

    func sendToClient(_ data: Data) {
        self.jellyfishClient?.websocketDidReceiveData(socket: socket, data: data)
    }

    func verifyClientSent(_ data: Data) {
        verify(self.mockedWebSocket.write(data: data)).wasCalled()
    }

    func testConnectAndAuthenticate() throws {
        connect()
        verify(self.jellyfishClientListener.onAuthSuccess()).wasCalled()
    }

    func testCleansUp() throws {
        connect()
        jellyfishClient?.cleanUp()
        verify(self.mockedWebSocket.disconnect()).wasCalled()
        verify(self.jellyfishClientListener.onDisconnected()).wasCalled()
        verify(self.webrtc?.disconnect()).wasCalled()
    }

    func testReceivesMediaEvents() throws {
        connect()
        sendToClient(sdpOfferEvent)
        verify(self.webrtc?.receiveMediaEvent(mediaEvent: "sdpOffer")).wasCalled()
    }

    func testSendsMediaEvents() throws {
        connect()
        jellyfishClient?.onSendMediaEvent(event: "join")
        verifyClientSent(joinEvent)
    }

    func testCloseWithError() throws {
        let err = WSError(type: ErrorType.closeError, message: "Test reason", code: 1009)

        connect()
        jellyfishClient?.websocketDidDisconnect(socket: socket, error: err)

        verify(self.jellyfishClientListener.onSocketClose(code: 1009, reason: "Test reason")).wasCalled()
    }
}
