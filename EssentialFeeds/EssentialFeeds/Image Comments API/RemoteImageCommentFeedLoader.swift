//
//  RemoteImageCommentFeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 14/09/23.
//

import Foundation

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentLoader {
     convenience init(url: URL, client: HTTPClient) {
         self.init(url: url, client: client, mapper: ImageCommentMapper.map)
     }
 }
