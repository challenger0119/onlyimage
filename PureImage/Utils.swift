//
//  Utils.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/25.
//

import UIKit

func DLog(identifier: String = "PureImage", _ log: String) {
    #if DEBUG
    print("\(identifier) - \(log)")
    #endif
}

extension UIApplication {
    static func endEdit() {
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil)
    }
}

extension URL {
    func withHostFixed() -> URL {
        if self.absoluteString.hasPrefix("//") {
            return URL(string: "https:\(self.absoluteString)")!
        }
        if !self.absoluteString.hasPrefix("http") {
            return URL(string: "https://\(self.absoluteString)")!
        }
        return self
    }
}
