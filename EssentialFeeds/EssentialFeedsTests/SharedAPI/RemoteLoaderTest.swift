//
//  RemoteLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 15/09/23.
//

import XCTest
import EssentialFeeds

final class RemoteLoaderTest: XCTestCase {

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

    func test_load_deliversErrorOnMapperError(){
        let (sut,client) = makeSut(mapper:{_,_ in throw anyNSError()})

        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200,data:anyData())
        }
    }

    func test_load_deliversMappedResource(){
        let (sut,client) = makeSut(mapper:{data,_ in String(data: data, encoding: .utf8)!})
        let resource = "a resource"
        
        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatusCode: 200,data:Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client) { _, _ in
            "Any"
        }
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0)}
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func expect(_ sut:RemoteLoader<String>,toCompleteWith expectedResult:RemoteLoader<String>.Result,when action:() -> Void,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResults in
            switch (receivedResults,expectedResult){
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            case let (.failure(receivedItems as RemoteLoader<String>.Error),.failure(expectedItems as RemoteLoader<String>.Error)):
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
    
    private func failure(_ error:RemoteLoader<String>.Error) -> RemoteLoader<String>.Result{
        .failure(error)
    }

    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!,
                         mapper:@escaping RemoteLoader<String>.Mapper = {_,_ in "any"},
                         file:StaticString = #filePath,
                         line:UInt = #line) -> (remoteLoader:RemoteLoader<String>,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client:client,mapper: mapper)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut,client)
    }

}
