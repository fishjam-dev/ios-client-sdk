import Foundation
import MembraneRTC
import XCTest
import Mockingbird

@testable import Starscream
@testable import JellyfishClientSdk


final class JellyfishClientSdkTests: XCTestCase {
    let mockedWebSocket = mock(JellyfishWebsocket.self)
    let jellyfichClientListiner = mock(MockJellyfishClientListener.self)
    let testConfig = Config(websocketUrl: "ws:\\test.com", token: "testTOKEN")
    var jellyfishClient: JellyfishClientInternal?

  
  
    func getMockWebsocket(url: String) -> JellyfishWebsocket {
      return self.mockedWebSocket;
    }
  
    func getExpectedAuthRequest() -> Data {
      let authRequest = Jellyfish_PeerMessage.with({
          $0.authRequest = Jellyfish_PeerMessage.AuthRequest.with({
              $0.token = "testTOKEN"
          })
      })

      guard let serialzedData = try? authRequest.serializedData() else {
          return Data()
      }
      
      return serialzedData
    }
  
    func getExpectedAuthResponse() -> Data {
      let authenticated = Jellyfish_PeerMessage.with({
          $0.authenticated = Jellyfish_PeerMessage.Authenticated()
      })

      guard let serialzedData = try? authenticated.serializedData() else {
          return Data()
      }
      
      return serialzedData
    }
  
    func getExpectedJoinEvent() -> Data {
      let mediaEvent =
          Jellyfish_PeerMessage.with({
              $0.mediaEvent = Jellyfish_PeerMessage.MediaEvent.with({
                  $0.data = "join"
              })
          })

      guard let serialzedData = try? mediaEvent.serializedData() else {
          return Data()
      }
      
      return serialzedData
    }
  
    func getSdpOfferResponse() -> Data {
      let mediaEvent =
          Jellyfish_PeerMessage.with({
              $0.mediaEvent = Jellyfish_PeerMessage.MediaEvent.with({
                  $0.data = "spdOffer"
              })
          })

      guard let serialzedData = try? mediaEvent.serializedData() else {
          return Data()
      }
      
      return serialzedData
    }
  
    override func setUp() {
      self.jellyfishClient = JellyfishClientInternal(listiner: self.jellyfichClientListiner, websocketFactory: getMockWebsocket, membraneRtcFactory: )
      
      givenSwift(self.mockedWebSocket.connect()).will {
        self.jellyfishClient?.websocketDidConnect()
      }
      
      givenSwift(self.mockedWebSocket.write(data: getExpectedAuthRequest())).will {_ in
        self.jellyfishClient?.websocketDidReceiveData(data: self.getExpectedAuthResponse())
      }
    }
  
    func testConnectAndAuthenticate() throws {
      jellyfishClient?.connect(config: self.testConfig)
      
      verify(self.mockedWebSocket.connect()).wasCalled()
      verify(self.mockedWebSocket.write(data: getExpectedAuthRequest())).wasCalled()
      verify(self.jellyfichClientListiner.onAuthSuccess()).wasCalled()
    }
  
    func testCleansUp() throws {
      jellyfishClient?.connect(config: self.testConfig)

      jellyfishClient?.cleanUp()
      verify(self.mockedWebSocket.disconnect()).wasCalled()
      verify(self.jellyfichClientListiner.onDisconnected()).wasCalled()
    }
  
  func testRecieveAndSendsMediaEvents() throws {
    givenSwift(self.mockedWebSocket.write(data: getExpectedJoinEvent())).will {_ in
      self.jellyfishClient?.websocketDidReceiveData(data: self.getSdpOfferResponse())
    }
    
    jellyfishClient?.connect(config: self.testConfig)

    
    jellyfishClient?.onSendMediaEvent(event: "join")
    verify(self.mockedWebSocket.write(data: getExpectedJoinEvent())).wasCalled()
  }
  
  func testCloseWithError() throws {
    let err = WSError(type: ErrorType.closeError, message: "Test reason", code: 1009)
    
    jellyfishClient?.connect(config: self.testConfig)
    jellyfishClient?.websocketDidDisconnect(error: err)
    
    verify(self.jellyfichClientListiner.onSocketClose(code: 1009, reason: "Test reason")).wasCalled()
  }
}
