//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/04/23.
//

import XCTest
import EssentialFeeds

class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override  func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromUrl_performGetRequestWithURL(){
       
        let url = anyURL()
        let expectation = expectation(description: "wait for request")
        URLProtocolStub.observerRequest{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        makeSut().get(from: url) { _ in
            
        }
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func test_getFromUrl_failsOnRequestError(){
        let requestError = NSError(domain: "Any error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
    
        XCTAssertEqual((receivedError! as NSError).domain, requestError.domain)
    }
    
    func test_getFromUrl_suceedsOnHTTPUrlResponseWithData(){
        let data = anyData()
        let response = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url , response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromUrl_failsOnAllInvalidRepresentationCases(){
       XCTAssertNotNil(resultErrorFor(data:nil,response:nil,error:nil))
       XCTAssertNotNil(resultErrorFor(data:nil,response:nonHttpUrlResponse(),error:nil))
       XCTAssertNotNil(resultErrorFor(data:anyData(),response:nil,error:nil))
       XCTAssertNotNil(resultErrorFor(data:anyData(),response:nil,error:anyNSError()))
       XCTAssertNotNil(resultErrorFor(data:nil,response:anyHttpUrlResponse(),error:anyNSError()))
       XCTAssertNotNil(resultErrorFor(data:anyData(),response:nonHttpUrlResponse(),error:anyNSError()))
       XCTAssertNotNil(resultErrorFor(data:anyData(),response:anyHttpUrlResponse(),error:anyNSError()))
    }
    
    func test_getFromUrl_suceedsWithEmptyDataOnHTTPUrlResponseWithNilData(){
        let response = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, Data())
        XCTAssertEqual(receivedValues?.response.url , response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
           
    }
    
    private func makeSut(file:StaticString = #filePath, line:UInt = #line) -> HTTPClient{
       let sut =  URLSessionHTTPClient()
       trackForMemoryLeaks(sut, file: file, line: line)
       return sut
    }
    
    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data{
        Data("Any data".utf8)
    }
    
    private func anyNSError() -> NSError{
        NSError(domain: "Any error", code: 0)
    }
    
    private func nonHttpUrlResponse() -> URLResponse{
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpUrlResponse() -> HTTPURLResponse{
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultErrorFor(data:Data?,response:URLResponse?,error:Error?,file:StaticString = #filePath, line:UInt = #line) -> Error?{
        
        let result = resultFor(data: data, response: response, error: error,file:file, line: line)
        
        switch result{
        case .failure(let error):
            return error
        default:
            XCTFail("expected failure, got result instead",file: file,line: line)
            return nil
        }
    }
    
    private func resultValuesFor(data:Data?,response:URLResponse?,error:Error?,file:StaticString = #filePath, line:UInt = #line) -> (data:Data,response:HTTPURLResponse)?{
        let result = resultFor(data: data, response: response, error: error,file:file, line: line)
        
        switch result{
        case let .success(data, response):
            return (data,response)
        default:
            XCTFail("expected failure, got result instead",file: file,line: line)
            return nil
        }
    }
    
    private func resultFor(data:Data?,response:URLResponse?,error:Error?,file:StaticString = #filePath, line:UInt = #line) -> HTTPClientResult{
        let sut = makeSut(file:file,line: line)
        let url = anyURL()
        URLProtocolStub.stub(data:data,response:response,error: error)
        
        let exp = expectation(description: "wait for data and response")
        
        var receivedResult:HTTPClientResult!
        
        sut.get(from: url) { result in
           receivedResult = result
           exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
            observerRequest = nil
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
