//
//  Connection.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Connection: XMLMappable {
    public var nodeName: String!
    public var device: Device!

    public var address: String!
    public var local: Bool!
    public var port: Int!
    public var `protocol`: String!
    public var relay: Bool!
    public var uri: String!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        address <- map.attributes["address"]
        local <- (map.attributes["local"], XMLBoolFromIntTransform())
        port <- map.attributes["port"]
        `protocol` <- map.attributes["protocol"]
        relay <- (map.attributes["relay"], XMLBoolFromIntTransform())
        uri <- map.attributes["uri"]
    }
}
