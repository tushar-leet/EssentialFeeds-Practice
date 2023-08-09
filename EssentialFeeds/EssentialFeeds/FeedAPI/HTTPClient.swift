//
//  HTTPClient.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/04/23.
//

import Foundation

public protocol HTTPClientTask {
     func cancel()
 }

public protocol HTTPClient{
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    typealias Result = Swift.Result<(Data,HTTPURLResponse),Error>
    @discardableResult
         func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
