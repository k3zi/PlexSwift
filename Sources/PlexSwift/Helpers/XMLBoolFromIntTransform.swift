//
//  XMLBoolFromIntTransform.swift
//  
//
//  Created by Kesi Maduka on 6/24/19.
//

import Foundation
import XMLMapper

class XMLBoolFromIntTransform: XMLTransformType {
    public typealias Object = Bool
    public typealias XML = String

    public init() {}

    open func transformFromXML(_ value: Any?) -> Bool? {
        guard let boolStr = value as? String else {
            return nil
        }

        if boolStr == "0" {
            return false
        }

        if boolStr == "1" {
            return true
        }

        return nil
    }

    open func transformToXML(_ value: Bool?) -> String? {
        if let bool = value {
            return bool ? "1" : "0"
        }
        return nil
    }
}
