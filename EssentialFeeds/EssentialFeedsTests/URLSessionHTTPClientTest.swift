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
    
    init(session:URLSession){
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

    func test_getFromUrl_resumeDataTaskWithURL(){
        let url = URL(string: "Http://any-url.com")
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url:url!,task:task)
        let sut = URLSessionHTTPClient(session:session)
        
        sut.get(from: url!) { _ in}
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getFromUrl_rfailsOnRequestError(){
        let url = URL(string: "Http://any-url.com")
        let session = URLSessionSpy()
        let error = NSError(domain: "Any error", code: 1)
        session.stub(url:url!,error: error)
        let sut = URLSessionHTTPClient(session:session)
        
        let exp = expectation(description: "eait for completion")
        
        sut.get(from: url!) { result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("expected failure, got result instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    private class URLSessionSpy:URLSession{
        private var stubs = [URL:Stub]()
        
        func stub( url:URL,task:URLSessionDataTask = FakeURLSessionDataTask(), error:Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
        private struct Stub{
            let task:URLSessionDataTask
            let error:Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else{
                fatalError("could not find stub for url: \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
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
