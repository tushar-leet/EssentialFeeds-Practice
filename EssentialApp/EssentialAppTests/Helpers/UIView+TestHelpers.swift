//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 12/09/23.
//

import UIKit

 extension UIView {
     func enforceLayoutCycle() {
         layoutIfNeeded()
         RunLoop.current.run(until: Date())
     }
 }
