//
//  LoadImageCommentFromRemoteUseCase.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 14/09/23.
//

import XCTest
import EssentialFeeds

final class LoadImageCommentFromRemoteUseCase: XCTestCase {
    func test_init_doesNotLoadDataFromURL(){
        let (_,client) = makeSut()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        
        XCTAssertEqual([url], client.requestedURLs)
    }

    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual([url,url], client.requestedURLs)
    }

    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSut()

        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: [:])
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon2xxHttpResponse(){
        let (sut,client) = makeSut()

        let samples = [199,150,300,400,500]
        samples.enumerated().forEach { (index,errorCode) in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemJSON([])
                client.complete(withStatusCode: errorCode, data: json,at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHttpResponseWithInvalidJson(){
        let (sut,client) = makeSut()
        let samples = [200,201,250,280,299]
        samples.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let invalidJson = Data("Invalid json".utf8)
                client.complete(withStatusCode: code,data:invalidJson,at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsn2xxHttpResponseWithEmptyJson(){
        let (sut,client) = makeSut()
        let samples = [200,201,250,280,299]
        samples.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWith: .success([])) {
                let emptyListJSON = Data("{\"items\":[]}".utf8)
                client.complete(withStatusCode: code,data:emptyListJSON,at: index)
            }
        }
    }
    
    func test_load_deliversItemsn2xxHttpResponseWithJSONList(){
        let (sut,client) = makeSut()
        
        let item1 = makeItems(id: UUID(),
                              imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItems(id: UUID(),
                              description: "a description",
                              location: "a location",
                              imageURL: URL(string: "http://a-url.com")!)
        
    
        
        let items = [item1.model,item2.model]
        let samples = [200,201,250,280,299]
        samples.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWith: .success(items)) {
                let json = makeItemJSON([item1.json,item2.json])
                client.complete(withStatusCode: code,data:json,at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteImageCommentLoader? = RemoteImageCommentLoader(url: url, client: client)
        var capturedResults = [RemoteImageCommentLoader.Result]()
        sut?.load { capturedResults.append($0)}
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func expect(_ sut:RemoteImageCommentLoader,toCompleteWith expectedResult:RemoteImageCommentLoader.Result,when action:() -> Void,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResults in
            switch (receivedResults,expectedResult){
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            case let (.failure(receivedItems as RemoteImageCommentLoader.Error),.failure(expectedItems as RemoteImageCommentLoader.Error)):
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
    
    private func failure(_ error:RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result{
        .failure(error)
    }

    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!,file:StaticString = #filePath, line:UInt = #line) -> (remoteLoader:RemoteImageCommentLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client:client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut,client)
    }
}
