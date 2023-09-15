//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest
import EssentialFeeds

class FeedItemsMapperTest:XCTestCase{

    func test_map_throwsErrorOnNon200HttpResponse() throws {
        let samples = [199,201,300,400,500]
        let json = makeItemJSON([])
        try samples.forEach { code in
          XCTAssertThrowsError(try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_throwsErrorOn200HttpResponseWithInvalidJson() throws {
        let invalidJson = Data("Invalid json".utf8)

        XCTAssertThrowsError(try FeedItemsMapper.map(invalidJson, from: HTTPURLResponse(statusCode: 200)))
        
    }
    
    func test_map_deliversNoItemsn200HttpResponseWithEmptyJson() throws{
        let emptyListJSON = Data("{\"items\":[]}".utf8)
        let result = try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsn200HttpResponseWithJSONList() throws{

        let item1 = makeItems(id: UUID(),
                              imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItems(id: UUID(),
                              description: "a description",
                              location: "a location",
                              imageURL: URL(string: "http://a-url.com")!)
        
    
        
        let items = [item1.model,item2.model]
        let json = makeItemJSON([item1.json,item2.json])
        let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, items)
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
}


