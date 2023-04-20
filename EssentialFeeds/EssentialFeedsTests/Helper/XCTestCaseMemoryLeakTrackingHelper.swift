//
//  XCTestCaseMemoryLeakTrackingHelper.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 20/04/23.
//

import Foundation
import XCTest

extension XCTestCase{
    func trackForMemoryLeaks(_ instance:AnyObject,file:StaticString = #filePath, line:UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated potential memory leak",file: file,line: line)
        }
    }
}
