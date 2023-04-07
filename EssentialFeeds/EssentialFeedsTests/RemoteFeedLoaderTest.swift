//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.url = URL(string: "Https://a-url.com")
    }
}

class HTTPClient{
    static let shared = HTTPClient()
    var url:URL?
    
    private init(){}
}

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.url)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.url)
    }
}
