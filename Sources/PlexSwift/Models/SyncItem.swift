//
//  SyncItem.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/12.
//

import Foundation
import XMLMapper

public class SyncItem: XMLMappable, Hashable {

    public static func == (lhs: SyncItem, rhs: SyncItem) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var nodeName: String!
    public var directory: Directory!
    public var connection: Connection!
    public var device: Device!

    public var id: Int!
    public var clientIdentifier: String!
    public var version: Int!
    public var location: String!

    public var status: Status!
    public var server: Server!
    public var mediaSettings: MediaSettings!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        id <- map.attributes["id"]
        clientIdentifier <- map.attributes["clientIdentifier"]
        version <- map.attributes["version"]

        var location: Location?
        location <- map["Location"]
        self.location = location?.uri ?? ""

        status <- map["Status"]
        server <- map["Server"]
        mediaSettings <- map["MediaSettings"]
    }
}
