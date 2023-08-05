//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 05/08/23.
//

import Foundation

 extension HTTPURLResponse {
     private static var OK_200: Int { return 200 }

     var isOK: Bool {
         return statusCode == HTTPURLResponse.OK_200
     }
 }
