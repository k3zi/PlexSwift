//
//  Location.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Location: XMLMappable {
    public var nodeName: String!

    public var id: Int!
    public var path: String?
    public var uri: String?

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        path <- map.attributes["path"]
        uri <- map.attributes["uri"]
    }
}
