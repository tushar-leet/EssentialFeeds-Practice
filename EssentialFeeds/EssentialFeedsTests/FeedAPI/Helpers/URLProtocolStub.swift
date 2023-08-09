//
//  URLProtocolStub.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 05/08/23.
//

import Foundation

// MARK: Helpers
class URLProtocolStub:URLProtocol{

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private struct Stub{
        let data:Data?
        let response:URLResponse?
        let error:Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    static func stub(data:Data?,response:URLResponse?, error:Error?){
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
  
    static func removeStub() {
        stub = nil
    }
    
    static func observerRequest(observer: @escaping (URLRequest) -> Void){
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        stub.requestObserver?(request)
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
