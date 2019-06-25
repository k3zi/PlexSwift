//
//  Track.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class Track: XMLMappable, Hashable {

    public static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.ratingKey == rhs.ratingKey
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ratingKey)
    }

    public var nodeName: String!
    public var directory: Directory!
    public var connection: Connection!
    public var device: Device!

    public var ratingKey: Int!
    public var key: String!
    public var parentRatingKey: Int!
    public var grandparentRatingKey: Int!
    public var type: String!
    public var title: String!
    public var grandparentKey: String!
    public var parentKey: String!
    public var grandparentTitle: String!
    public var parentTitle: String!
    public var summary: String!
    public var index: Int!
    public var parentIndex: String!
    public var year: Int!
    public var thumb: String!
    public var art: String?
    public var parentThumb: String!
    public var parentArt: String?
    public var grandparentThumb: String!
    public var grandparentArt: String?
    public var duration: Double!

    public var lastViewedAt: Date!
    public var addedAt: Date!
    public var updatedAt: Date!

    public var media: Media!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        ratingKey <- map.attributes["ratingKey"]
        key <- map.attributes["key"]
        parentRatingKey <- map.attributes["parentRatingKey"]
        grandparentRatingKey <- map.attributes["grandparentRatingKey"]
        type <- map.attributes["type"]
        title <- map.attributes["title"]
        grandparentKey <- map.attributes["grandparentKey"]
        parentKey <- map.attributes["parentKey"]
        grandparentTitle <- map.attributes["grandparentTitle"]
        parentTitle <- map.attributes["parentTitle"]
        summary <- map.attributes["summary"]
        index <- map.attributes["index"]
        parentIndex <- map.attributes["parentIndex"]
        year <- map.attributes["year"]
        thumb <- map.attributes["thumb"]
        art <- map.attributes["art"]
        parentThumb <- map.attributes["parentThumb"]
        parentArt <- map.attributes["parentArt"]
        grandparentThumb <- map.attributes["grandparentThumb"]
        grandparentArt <- map.attributes["grandparentArt"]
        duration <- map.attributes["duration"]

        lastViewedAt <- (map.attributes["lastViewedAt"], XMLDateTransform())
        addedAt <- (map.attributes["addedAt"], XMLDateTransform())
        updatedAt <- (map.attributes["updatedAt"], XMLDateTransform())

        if index == nil {
            index = 0
        }

        media <- map["Media"]
    }

}
