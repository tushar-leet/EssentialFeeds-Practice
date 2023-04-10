//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest
import EssentialFeeds

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let (_,client) = makeSut()
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }

    func test_load_requestsDataFromURL(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        
        XCTAssertEqual([url], client.requestedUrls)
    }

    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual([url,url], client.requestedUrls)
    }

    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSut()

        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: [:])
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse(){
        let (sut,client) = makeSut()

        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { (index,errorCode) in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: errorCode,at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson(){
        let (sut,client) = makeSut()

        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200,data:invalidJson)
        }
    }
    
    func test_load_deliversNoItemsn200HttpResponseWithEmptyJson(){
        let (sut,client) = makeSut()
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load {capturedResult.append($0)}
        let emptyListJSON = Data("{\"items\":[]}".utf8)
        client.complete(withStatusCode: 200,data:emptyListJSON)
        XCTAssertEqual(capturedResult, [.success([])])
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWithError error:RemoteFeedLoader.Error,when action:() -> Void,file:StaticString = #filePath, line:UInt = #line){
        var capturedError = [RemoteFeedLoader.Result]()
        sut.load{capturedError.append($0)}
        action()
        XCTAssertEqual(capturedError, [.failure(error)],file:file,line: line)

    }

    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!) -> (remoteLoader:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        return (sut,client)
    }

    private class HTTPClientSpy:HTTPClient{

        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }

        var messages = [(url:URL,completion: (HTTPClientResult) -> Void)]()

        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }

        func complete(with error:Error, at index:Int = 0){
            messages[index].completion(.error(error))
        }

        func complete(withStatusCode code:Int,data:Data = Data(), at index:Int = 0){
          let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields:nil)!
            messages[index].completion(.success(data,response))
        }
    }
}
