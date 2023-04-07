//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest

class RemoteFeedLoader{
    
    let client:HTTPClient
    let url:URL
    
    init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(){
        client.get(url: url)
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
        let url = URL(string: "Https://a-url.com")
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url!, client:client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "Https://a-given-url.com")
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url!, client:client)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }
}
