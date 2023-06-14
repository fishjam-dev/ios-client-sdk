import Foundation
import MembraneRTC
import XCTest
import Mockingbird

@testable import Starscream
@testable import JellyfishClientSdk


final class JellyfishClientSdkTests: XCTestCase {
  let mockedWebSocket = mock(JellyfishWebsocket.self)
  let jellyfichClientListiner = mock(JellyfishClientListener.self)
  let testConfig = Config(websocketUrl: "ws:\\test.com", token: "testTOKEN")
  var jellyfishClient: JellyfishClientInternal?
  var webrtc: JellyfishMembraneRTC?
  
  func getMockWebsocket(url: String) -> JellyfishWebsocket {
    return self.mockedWebSocket;
  }
  
  static func generateDataFromMessage(_ message: Jellyfish_PeerMessage) -> Data {
    guard let serialzedData = try? message.serializedData() else {
      return Data()
    }
    
    return serialzedData
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
    self.jellyfishClient = JellyfishClientInternal(listiner: self.jellyfichClientListiner, websocketFactory: getMockWebsocket)
    self.jellyfishClient?.create(webrtcClient: webrtc)
    self.webrtc = webrtc
    
    givenSwift(self.mockedWebSocket.connect()).will {
      self.jellyfishClient?.websocketDidConnect()
    }
  }
  
  func connect() {
    jellyfishClient?.connect(config: self.testConfig)
    
    verifyClientSent(authRequest)
    
    sendToClient(authResponse)
  }
  
  func sendToClient(_ data: Data) {
    self.jellyfishClient?.websocketDidReceiveData(data: data)
  }
  
  func verifyClientSent(_ data: Data) {
    verify(self.mockedWebSocket.write(data: data)).wasCalled()
  }
  
  func testConnectAndAuthenticate() throws {
    connect()
    
    verify(self.jellyfichClientListiner.onAuthSuccess()).wasCalled()
  }
  
  func testCleansUp() throws {
    connect()
    
    jellyfishClient?.cleanUp()
    verify(self.mockedWebSocket.disconnect()).wasCalled()
    verify(self.jellyfichClientListiner.onDisconnected()).wasCalled()
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
    jellyfishClient?.websocketDidDisconnect(error: err)
    
    verify(self.jellyfichClientListiner.onSocketClose(code: 1009, reason: "Test reason")).wasCalled()
  }
}
