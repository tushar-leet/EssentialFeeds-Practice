//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest
import EssentialFeeds

class LoadFeedFromRemoteFeedUseCaseTests:XCTestCase{
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

        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: [:])
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse(){
        let (sut,client) = makeSut()

        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { (index,errorCode) in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemJSON([])
                client.complete(withStatusCode: errorCode, data: json,at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson(){
        let (sut,client) = makeSut()

        expect(sut, toCompleteWith: failure(.invalidData)) {
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
        
        let item1 = makeItems(id: UUID(),
                              imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItems(id: UUID(),
                              description: "a description",
                              location: "a location",
                              imageURL: URL(string: "http://a-url.com")!)
        
    
        
        let items = [item1.model,item2.model]
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemJSON([item1.json,item2.json])
            client.complete(withStatusCode: 200,data:json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0)}
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWith expectedResult:RemoteFeedLoader.Result,when action:() -> Void,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResults in
            switch (receivedResults,expectedResult){
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            case let (.failure(receivedItems as RemoteFeedLoader.Error),.failure(expectedItems as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            default:
                XCTFail("expected result :\(expectedResult) instead received : \(receivedResults)",file:file,line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItems(id:UUID,description:String? = nil,location:String? = nil,imageURL:URL) -> (model:FeedImage,json:[String:Any]){
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id":id.uuidString,
            "description":description,
            "location":location,
            "image":imageURL.absoluteString
        ].compactMapValues{$0}
        
        return (item,json)
    }
    
    func makeItemJSON(_ items:[[String:Any]]) -> Data{
        let itemsJSON = ["items":items]
        let json = try! JSONSerialization.data(withJSONObject:itemsJSON)
        return json
    }
    
    private func failure(_ error:RemoteFeedLoader.Error) -> RemoteFeedLoader.Result{
        .failure(error)
    }

    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!,file:StaticString = #filePath, line:UInt = #line) -> (remoteLoader:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{

        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }

        var messages = [(url:URL,completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }

        func complete(with error:Error, at index:Int = 0){
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code:Int,data:Data, at index:Int = 0){
          let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields:nil)!
            messages[index].completion(.success(data,response))
        }
    }
}
