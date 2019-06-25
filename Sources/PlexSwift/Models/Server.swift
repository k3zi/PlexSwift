//
//  Server.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Server: XMLMappable {

    public var nodeName: String!

    public var accessToken: String!
    public var address: String!
    public var createdAt: Date!
    public var host: String!
    public var localAddresses: String!
    public var machineIdentifier: String!
    public var name: String!
    public var owned: Bool!
    public var port: Int!
    public var scheme: String!
    public var synced: Bool!
    public var updatedAt: Date!
    public var version: String!

    // Shared Server
    public var sourceTitle: String?
    public var ownerId: Int?
    public var home: Bool?

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        accessToken <- map.attributes["accessToken"]
        address <- map.attributes["address"]
        createdAt <- (map.attributes["createdAt"], XMLDateTransform())
        host <- map.attributes["host"]
        localAddresses <- map.attributes["localAddresses"]
        machineIdentifier <- map.attributes["machineIdentifier"]
        name <- map.attributes["name"]
        owned <- (map.attributes["owned"], XMLBoolFromIntTransform())
        port <- map.attributes["port"]
        scheme <- map.attributes["scheme"]
        synced <- (map.attributes["synced"], XMLBoolFromIntTransform())
        updatedAt <- (map.attributes["updatedAt"], XMLDateTransform())
        version <- map.attributes["version"]

        home <- (map.attributes["home"], XMLBoolFromIntTransform())
        ownerId <- map.attributes["ownerId"]
        sourceTitle <- map.attributes["sourceTitle"]
    }
}
