//
//  MediaSettings.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/12.
//

import Foundation
import XMLMapper

public class MediaSettings: XMLMappable {

    public var nodeName: String!

    public var audioBoost: Int!
    public var maxVideoBitrate: Int!
    public var musicBitrate: Int!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        audioBoost <- map.attributes["audioBoost"]
        maxVideoBitrate <- map.attributes["maxVideoBitrate"]
        musicBitrate <- map.attributes["musicBitrate"]
    }
}
