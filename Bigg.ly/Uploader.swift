//
//  Uploader.swift
//  Bigg.ly
//
//  Created by Navdeep Rana on 2/8/22.
//

import Foundation


extension Data{
mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
    if let data = string.data(using: encoding) {
        append(data)
    }
}
}
