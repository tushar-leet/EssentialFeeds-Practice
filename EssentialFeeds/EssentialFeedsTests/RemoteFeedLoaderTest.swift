//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest

class RemoteFeedLoader{
    var client:HTTPClient
    init(client:HTTPClient) {
        self.client = client
    }
    
    func load(){
        client.get(url: URL(string: "Https://a-url.com")!)
    }
}

protocol HTTPClient{
    func get(url:URL)
}

class HTTPClientSpy:HTTPClient{
    var requestedURL:URL?
    
    func get(url:URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client:client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client:client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
