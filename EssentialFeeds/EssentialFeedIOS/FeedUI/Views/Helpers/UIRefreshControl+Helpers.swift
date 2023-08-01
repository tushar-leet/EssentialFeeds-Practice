//
//  UIRefreshControl+Helpers.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 01/08/23.
//


import UIKit

 extension UIRefreshControl {
     func update(isRefreshing: Bool) {
         isRefreshing ? beginRefreshing() : endRefreshing()
     }
 }
