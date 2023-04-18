//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/04/23.
//

import XCTest

class URLSessionHTTPClient{
    private let session:URLSession
    
    init(session:URLSession){
        self.session = session
    }
    
    func get(from url:URL){
        session.dataTask(with: url) { _, _, _ in}
    }
}

class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromUrl_createDataTaskWithURL(){
        let url = URL(string: "Http://any-url.com")
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session:session)
        
        sut.get(from: url!)
        
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    // MARK: Helpers
    private class URLSessionSpy:URLSession{
        var receivedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask:URLSessionDataTask{

    }
}
