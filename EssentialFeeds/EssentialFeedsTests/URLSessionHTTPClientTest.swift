//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/04/23.
//

import XCTest
import EssentialFeeds

class URLSessionHTTPClient{
    private let session:URLSession
    
    init(session:URLSession = .shared){
        self.session = session
    }
    
    func get(from url:URL,completion: @escaping ((HTTPClientResult) -> Void)){
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override  func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromUrl_performGetRequestWithURL(){
       
        let url = URL(string: "http://any-url.com")!
        let expectation = expectation(description: "wait for request")
        URLProtocolStub.observerRequest{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        URLSessionHTTPClient().get(from: url) { _ in
            
        }
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func test_getFromUrl_failsOnRequestError(){
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(data:nil,response:nil,error: error)
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "eait for completion")
        
        sut.get(from: url) { result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
            default:
                XCTFail("expected failure, got result instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    private class URLProtocolStub:URLProtocol{
        private static var stubs:Stub?
        private static var observerRequest:((URLRequest) -> Void)?
        
        static func stub(data:Data?,response:URLResponse?, error:Error?){
            stubs = Stub(data:data,response: response,error: error)
        }
        
        private struct Stub{
            let data:Data?
            let response:URLResponse?
            let error:Error?
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
        }
        
        static func observerRequest(observer: @escaping (URLRequest) -> Void){
            observerRequest = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observerRequest?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
           
            if let data = URLProtocolStub.stubs?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stubs?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let errorObj = URLProtocolStub.stubs?.error{
                client?.urlProtocol(self, didFailWithError: errorObj)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
