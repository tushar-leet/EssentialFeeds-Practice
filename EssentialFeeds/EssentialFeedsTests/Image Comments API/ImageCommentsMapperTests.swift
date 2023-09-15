//
//  LoadImageCommentFromRemoteUseCase.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 14/09/23.
//

import XCTest
import EssentialFeeds

final class ImageCommentsMapperTests: XCTestCase {
   
    func test_map_throwsErrorOnNon2xxHttpResponse() throws{
        let json = makeItemJSON([])

        let samples = [199,150,300,400,500]
        try samples.forEach { code in
            XCTAssertThrowsError(try ImageCommentMapper
                .map(json, from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_throwsErrorOn2xxHttpResponseWithInvalidJson() throws{
        let samples = [200,201,250,280,299]
        let invalidJson = Data("Invalid json".utf8)
        try samples.forEach { code in
            XCTAssertThrowsError(try ImageCommentMapper
                .map(invalidJson, from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_throwsNoItemson2xxHttpResponseWithEmptyJson() throws{
        let samples = [200,201,250,280,299]
        let emptyListJSON = Data("{\"items\":[]}".utf8)
        try samples.forEach { code in
            let result = try ImageCommentMapper
                .map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_load_deliversItemsn2xxHttpResponseWithJSONList() throws{

        let item1 = makeItems(id: UUID(),
                              message: "a message",
                              createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                              username: "a username")
        
        let item2 = makeItems(id: UUID(),
                              message: "another message",
                              createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                              username: "another username")
        
    
        
        let items = [item1.model,item2.model]
        let samples = [200,201,250,280,299]
        let json = makeItemJSON([item1.json,item2.json])
        try samples.enumerated().forEach { (index,code) in
            let result = try ImageCommentMapper
                .map(json, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
    }
   
    private func makeItems(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
            let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json:[String:Any] = [
            "id":id.uuidString,
            "message":message,
            "created_at":createdAt.iso8601String,
            "author":[
                "username":username
            ]
        ]
        
        return (item,json)
    }
}
