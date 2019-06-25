//
//  PinRequest.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2018/10/25.
//  Copyright © 2018 Kesi Maduka. All rights reserved.
//

import Foundation

public class PinRequest: Codable {

    public let id: Int
    public let code: String
    public let expiresAt: Date
    public let userId: Int?
    public let clientIdentifier: String
    public let trusted: Bool
    public let authToken: String?

}
