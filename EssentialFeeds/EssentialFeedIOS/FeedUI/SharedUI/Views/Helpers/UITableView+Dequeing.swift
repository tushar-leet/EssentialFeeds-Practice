//
//  UITableView+Dequeing.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 22/07/23.
//

import UIKit

extension UITableView {
     func dequeueReusableCell<T: UITableViewCell>() -> T {
         let identifier = String(describing: T.self)
         return dequeueReusableCell(withIdentifier: identifier) as! T
     }
 }
