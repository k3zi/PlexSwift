//
//  DevicesSyncItemsGETResponse.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2019/01/12.
//

import Foundation
import XMLMapper

public class DevicesSyncItemsGETResponse: XMLMappable {

    public var nodeName: String!

    public var directory: Directory! {
        didSet {
            items.forEach {
                $0.directory = self.directory
            }
        }
    }
    public var connection: Connection! {
        didSet {
            items.forEach {
                $0.connection = self.connection
            }
        }
    }
    public var device: Device! {
        didSet {
            items.forEach {
                $0.device = self.device
            }
        }
    }

    public var clientIdentifier: String!
    public var status: String!
    public var items: [SyncItem]!

    public required init?(map: XMLMap) {}

    public func mapping(map: XMLMap) {
        clientIdentifier <- map.attributes["clientIdentifier"]
        status <- map.attributes["status"]
        items <- map["SyncItems.SyncItem"]
        if items == nil {
            items = []
        }
    }

}
