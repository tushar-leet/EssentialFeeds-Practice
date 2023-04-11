//
//  HTTPClient.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/04/23.
//

import Foundation

public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case error(Error)
}

public protocol HTTPClient{
    func get(url:URL,completion:@escaping (HTTPClientResult) -> Void)
}
