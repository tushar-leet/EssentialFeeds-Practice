//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.get(url: URL(string: "Https://a-url.com")!)
    }
}

class HTTPClient{
    static var  shared = HTTPClient()

    func get(url:URL){}
}

class HTTPClientSpy:HTTPClient{
    var requestedURL:URL?
    
    override func get(url:URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
