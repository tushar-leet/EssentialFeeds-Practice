//
//  SharedTestHelpers.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 22/05/23.
//

import Foundation

func anyNSError() -> NSError{
   NSError(domain: "Any error", code: 0)
}

func anyURL() -> URL{
   URL(string: "http://any-url.com")!
}

func anyData() -> Data {
     return Data("any data".utf8)
 }

extension HTTPURLResponse {
     convenience init(statusCode: Int) {
         self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
     }
 }

func makeItemJSON(_ items:[[String:Any]]) -> Data{
    let itemsJSON = ["items":items]
    let json = try! JSONSerialization.data(withJSONObject:itemsJSON)
    return json
}
