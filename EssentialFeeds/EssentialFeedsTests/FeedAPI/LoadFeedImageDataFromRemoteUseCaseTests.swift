//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest
import EssentialFeeds

class LoadFeedImageDataFromRemoteUseCaseTests:XCTestCase{

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
}
