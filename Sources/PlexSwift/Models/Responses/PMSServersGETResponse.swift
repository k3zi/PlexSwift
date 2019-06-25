//
//  Servers.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class PMSServersGETResponse: XMLMappable, MediaContainer {

    public var nodeName: String!

    public var friendlyName: String!
    public var identifier: String!
    public var machineIdentifier: String!
    public var size: Int!

    public var servers: [Server]!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        friendlyName <- map.attributes["friendlyName"]
        identifier <- map.attributes["identifier"]
        machineIdentifier <- map.attributes["machineIdentifier"]
        size <- map.attributes["size"]

        servers <- map["Server"]
    }

}
