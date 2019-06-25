//
//  Status.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/12.
//

import Foundation
import XMLMapper

public class Status: XMLMappable {
    public var nodeName: String!

    public var state: String!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        state <- map.attributes["state"]
    }
}
