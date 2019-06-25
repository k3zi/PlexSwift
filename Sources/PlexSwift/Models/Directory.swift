//
//  Directory.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public enum DirectoryType: String {
    case artist
    case movie
    case show
}

public class Directory: XMLMappable, Hashable {

    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    public var nodeName: String!
    public var device: Device!

    public var allowSync: Bool!
    public var art: String!
    public var composite: String!
    public var filters: Bool!
    public var refreshing: Bool!
    public var thumb: String!
    public var key: Int!
    public var type: DirectoryType!
    public var title: String!
    public var agent: String!
    public var scanner: String!
    public var language: String!
    public var uuid: String!

    public var updatedAt: Date!
    public var createdAt: Date!
    public var scannedAt: Date!

    public var locations: [Location]!
    public var connection: Connection!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        allowSync <- (map.attributes["allowSync"], XMLBoolFromIntTransform())
        art <- map.attributes["art"]
        composite <- map.attributes["composite"]
        filters <- (map.attributes["filters"], XMLBoolFromIntTransform())
        refreshing <- (map.attributes["refreshing"], XMLBoolFromIntTransform())
        thumb <- map.attributes["thumb"]
        key <- map.attributes["key"]
        type <- map.attributes["type"]
        title <- map.attributes["title"]
        agent <- map.attributes["agent"]
        scanner <- map.attributes["scanner"]
        language <- map.attributes["language"]
        uuid <- map.attributes["uuid"]

        updatedAt <- (map.attributes["updatedAt"], XMLDateTransform())
        createdAt <- (map.attributes["createdAt"], XMLDateTransform())
        scannedAt <- (map.attributes["scannedAt"], XMLDateTransform())

        locations <- map["Location"]
    }

}
