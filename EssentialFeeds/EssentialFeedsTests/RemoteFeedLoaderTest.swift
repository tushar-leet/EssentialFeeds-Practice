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

        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: [:])
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse(){
        let (sut,client) = makeSut()

        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { (index,errorCode) in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: errorCode,at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson(){
        let (sut,client) = makeSut()

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJson = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200,data:invalidJson)
        }
    }
    
    func test_load_deliversNoItemsn200HttpResponseWithEmptyJson(){
        let (sut,client) = makeSut()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200,data:emptyListJSON)
        }
    }
    
    func test_load_deliversItemsn200HttpResponseWithJSONList(){
        let (sut,client) = makeSut()
        
        let item1 = FeedItems(id: UUID(),
                              description: nil,
                              location: nil,
                              imageURL: URL(string: "http://a-url.com")!)
        
        let item1JSON = [
            "id":item1.id.uuidString,
            "description":nil,
            "location":nil,
            "image":item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItems(id: UUID(),
                              description: "a description",
                              location: "a location",
                              imageURL: URL(string: "http://a-url.com")!)
        
        let item2JSON = [
            "id":item2.id.uuidString,
            "description":item2.description,
            "location":item2.location,
            "image":item2.imageURL.absoluteString
        ]
        
        let itemsJSON = ["items":[item1JSON,item2JSON]]
        expect(sut, toCompleteWith: .success([item1,item2])) {
            let json = try! JSONSerialization.data(withJSONObject:itemsJSON)
            client.complete(withStatusCode: 200,data:json)
        }
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWith result:RemoteFeedLoader.Result,when action:() -> Void,file:StaticString = #filePath, line:UInt = #line){
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load{capturedResults.append($0)}
        action()
        XCTAssertEqual(capturedResults, [result],file:file,line: line)
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
