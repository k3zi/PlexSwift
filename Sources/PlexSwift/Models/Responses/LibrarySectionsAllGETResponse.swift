//
//  LibrarySectionsAllGETResponse.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class LibrarySectionsAllGETResponse: XMLMappable, MediaContainer {

    public var nodeName: String!

    public var allowSync: Bool!
    public var identifier: String!
    public var mediaTagPrefix: String!
    public var mediaTagVersion: Date!
    public var size: Int!
    public var title1: String!

    public var tracks: [Track]!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        allowSync <- (map.attributes["allowSync"], XMLBoolFromIntTransform())
        identifier <- map.attributes["identifier"]
        mediaTagPrefix <- map.attributes["mediaTagPrefix"]
        mediaTagVersion <- (map.attributes["mediaTagVersion"], XMLDateTransform())
        size <- map.attributes["size"]
        title1 <- map.attributes["title1"]

        tracks <- map["Track"]
        if tracks == nil {
            tracks = []
        }
    }

}
