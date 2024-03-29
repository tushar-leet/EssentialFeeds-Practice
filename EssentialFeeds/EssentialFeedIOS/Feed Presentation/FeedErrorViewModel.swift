//
//  ResourceErrorViewModel.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 01/08/23.
//

import Foundation

public struct ResourceErrorViewModel {
    let message: String?
    
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
