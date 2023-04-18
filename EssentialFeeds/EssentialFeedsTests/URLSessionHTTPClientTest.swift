//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/04/23.
//

import XCTest
import EssentialFeeds

protocol HTTPSession{
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask{
    func resume()
}

class URLSessionHTTPClient{
    private let session:HTTPSession
    
    init(session:HTTPSession){
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
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url:url!,task:task)
        let sut = URLSessionHTTPClient(session:session)
        
        sut.get(from: url!) { _ in}
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getFromUrl_rfailsOnRequestError(){
        let url = URL(string: "Http://any-url.com")
        let session = HTTPSessionSpy()
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
    private class HTTPSessionSpy:HTTPSession{
        private var stubs = [URL:Stub]()
        
        func stub( url:URL,task:HTTPSessionTask = FakeURLSessionDataTask(), error:Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
        private struct Stub{
            let task:HTTPSessionTask
            let error:Error?
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else{
                fatalError("could not find stub for url: \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask:HTTPSessionTask{
        func resume() {}
    }
    
    private class URLSessionDataTaskSpy:HTTPSessionTask{
        var resumeCount = 0
        
        func resume() {
            resumeCount += 1
        }
    }
}
