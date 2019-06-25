//
//  Device.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Device: XMLMappable {
    public var nodeName: String!

    public var accessToken: String!
    public var createdAt: Date!
    public var clientIdentifier: String!
    public var device: String!
    public var httpsRequired: Bool!
    public var lastSeenAt: Date!
    public var name: String!
    public var owned: Bool!
    public var platform: String!
    public var platformVersion: String!
    public var port: Int!
    public var presence: Bool!
    public var productVersion: String!
    public var provides: String!
    public var publicAddress: String!
    public var publicAddressMatches: Bool!
    public var synced: Bool!

    public var relay: Bool?

    // Shared Device
    public var sourceTitle: String?
    public var ownerId: Int?
    public var home: Bool?

    public var connections: [Connection]!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        accessToken <- map.attributes["accessToken"]
        createdAt <- (map.attributes["createdAt"], XMLDateTransform())
        clientIdentifier <- map.attributes["clientIdentifier"]
        device <- map.attributes["device"]
        httpsRequired <- (map.attributes["httpsRequired"], XMLBoolFromIntTransform())
        lastSeenAt <- (map.attributes["lastSeenAt"], XMLDateTransform())
        name <- map.attributes["name"]
        owned <- (map.attributes["owned"], XMLBoolFromIntTransform())
        platform <- map.attributes["platform"]
        platformVersion <- map.attributes["platformVersion"]
        port <- map.attributes["port"]
        presence <- (map.attributes["presence"], XMLBoolFromIntTransform())
        productVersion <- map.attributes["productVersion"]
        provides <- map.attributes["provides"]
        publicAddress <- map.attributes["publicAddress"]
        publicAddressMatches <- (map.attributes["publicAddressMatches"], XMLBoolFromIntTransform())
        synced <- (map.attributes["synced"], XMLBoolFromIntTransform())

        relay <- (map.attributes["relay"], XMLBoolFromIntTransform())

        home <- (map.attributes["home"], XMLBoolFromIntTransform())
        ownerId <- map.attributes["ownerId"]
        sourceTitle <- map.attributes["sourceTitle"]

        connections <- map["Connection"]
        if connections == nil {
            connections = []
        }

        connections.forEach {
            $0.device = self
        }
    }
}
