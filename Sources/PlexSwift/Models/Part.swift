//
//  Part.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Part: XMLMappable, Hashable {

    public static func == (lhs: Part, rhs: Part) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var nodeName: String!
    public var connection: Connection!

    public var id: Int!
    public var key: String!
    public var duration: Double!
    public var file: String!
    public var size: Int!
    public var audioProfile: String!
    public var container: String!
    public var has64bitOffsets: Bool!
    public var hasThumbnail: Bool!
    public var optimizedForStreaming: Bool!
    public var syncState: String?

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        key <- map.attributes["key"]
        duration <- map.attributes["duration"]
        file <- map.attributes["file"]
        size <- map.attributes["size"]
        audioProfile <- map.attributes["audioProfile"]
        container <- map.attributes["container"]
        syncState <- map.attributes["syncState"]
        has64bitOffsets <- (map.attributes["has64bitOffsets"], XMLBoolFromIntTransform())
        hasThumbnail <- (map.attributes["hasThumbnail"], XMLBoolFromIntTransform())
        optimizedForStreaming <- (map.attributes["optimizedForStreaming"], XMLBoolFromIntTransform())
    }
}
