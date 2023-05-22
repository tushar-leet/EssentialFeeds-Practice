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

