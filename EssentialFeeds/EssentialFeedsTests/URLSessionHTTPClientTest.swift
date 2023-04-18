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
        session.dataTask(with: url) { _, _, _ in}.resume()
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
    
    func test_getFromUrl_resumeDataTaskWithURL(){
        let url = URL(string: "Http://any-url.com")
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url!,task)
        let sut = URLSessionHTTPClient(session:session)
        
        sut.get(from: url!)
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    // MARK: Helpers
    private class URLSessionSpy:URLSession{
        var receivedUrls = [URL]()
        private var stubs = [URL:URLSessionDataTask]()
        
        func stub(_ url:URL,_ task:URLSessionDataTask){
            stubs[url] = task
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask:URLSessionDataTask{
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy:URLSessionDataTask{
        var resumeCount = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
}
