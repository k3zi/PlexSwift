//
//  Media.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Media: XMLMappable, Hashable {

    public static func == (lhs: Media, rhs: Media) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var nodeName: String!
    public var connection: Connection!

    public var id: Int!
    public var duration: Double!
    public var bitrate: Int!
    public var audioChannels: Int!
    public var audioCodec: String!
    public var container: String!
    public var optimizedForStreaming: Bool!
    public var audioProfile: String!
    public var has64bitOffsets: Bool!

    public var part: Part!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        duration <- map.attributes["duration"]
        bitrate <- map.attributes["bitrate"]
        audioChannels <- map.attributes["audioChannels"]
        audioCodec <- map.attributes["audioCodec"]
        container <- map.attributes["container"]
        optimizedForStreaming <- (map.attributes["optimizedForStreaming"], XMLBoolFromIntTransform())
        audioProfile <- map.attributes["audioProfile"]
        has64bitOffsets <- (map.attributes["has64bitOffsets"], XMLBoolFromIntTransform())

        part <- map["Part"]
    }
}
