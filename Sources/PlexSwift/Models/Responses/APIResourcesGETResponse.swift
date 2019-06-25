//
//  APIResourcesGETResponse.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/06.
//

import Foundation
import XMLMapper

public class APIResourcesGETResponse: XMLMappable, MediaContainer {

    public var nodeName: String!

    public var devices: [Device]!
    public var size: Int!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        devices <- map["Device"]
        size <- map.attributes["size"]
    }

}
