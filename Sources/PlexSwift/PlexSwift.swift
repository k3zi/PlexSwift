//
//  Plex.swift
//  PlexSwift
//
//  Created by Kesi Maduka on 2018/10/22.
//  Copyright © 2018 Kesi Maduka. All rights reserved.
//

import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum PlexError: Error {
    case dataParsingError
    case invalidRootKeyPath
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public class Plex: NSObject {

    enum Settings: String {
        case userId
        case authToken
    }

    enum SignInStatus {
        case noCredentials
        case authenticating(code: String)
        case signedIn
    }

    enum RequestBuilder {
        fileprivate static var tvBase = "https://plex.tv"
        case librarySectionTracks(connectionURI: String, sectionKey: String)
        case syncItems(clientIdentifier: String)
        case syncItemTracks(connectionURI: String, syncItemId: Int)
        case sections(connectionURI: String)

        private var urlString: String {
            switch self {
            case .librarySectionTracks(let connectionURI, let sectionKey):
                return "\(connectionURI)/library/sections/\(sectionKey)/all?type=10&includeRelated=1&includeCollections=1"

            case .sections(let connectionURI):
                return "\(connectionURI)/library/sections"

            case .syncItems(let clientIdentifier):
                let id = clientIdentifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                return "\(type(of: self).tvBase)/devices/\(id)/sync_items"

            case .syncItemTracks(let connectionURI, let syncItemId):
                return "\(connectionURI)/sync/items\(syncItemId)"
            }
        }

        var url: URL {
            return URL(string: urlString)!
        }
    }

    struct Path {
        static let _plexTV = "https://plex.tv"
        static let linkAccount = "\(_plexTV)/link"

        enum Pins {
            static let _pins = "\(_plexTV)/pins"
            static let request = "\(_pins).json"
            static func check(pin pinId: Int) -> String {
                return "\(_pins)/\(pinId).json"
            }
        }

        enum PMS {
            static let _pms = "\(_plexTV)/pms"
            static let servers = "\(_pms)/servers"
        }

        enum API {
            static let _api = "\(_plexTV)/api"
            static let resources = "\(_api)/resources"
        }

        struct library {
            let connection: Connection
            init(_ connection: Connection) {
                self.connection = connection
            }

            var _base: String {
                return "\(connection.uri!)/library"
            }
            var sections: String {
                // Adding .xml to this yields 0 results for directories
                return "\(_base)/sections"
            }

            func syncItems(id: Int) -> String {
                return "\(connection.uri!)/sync/items/\(id)"
            }

            struct _section {
                private let _base: String
                init(base: String) {
                    _base = base
                }

                var all: String {
                    return "\(_base)/all"
                }
            }

            func section(id: Int) -> _section {
                return _section(base: "\(sections)/\(id)")
            }
        }
    }

    lazy var clientIdentifier: String = {
        // TODO: Don't save the identifier to the user defaults.
        if let storedIdentifier = UserDefaults.standard.string(forKey: "clientIdentifier") {
            return storedIdentifier
        }

        #if canImport(UIKit)
        let identifier = UIDevice.current.identifierForVendor?.uuidString ?? ""
        #else
        let identifier = Host.current().address ?? "NoHostAddress"
        #endif
        UserDefaults.standard.set(identifier, forKey: "clientIdentifier")
        return identifier
    }()

    lazy var requestHeaders: [String: String] = {
        #if canImport(UIKit)
        let deviceName = UIDevice.current.name
        let platformVersion = UIDevice.current.systemVersion
        #else
        let deviceName = Host.current().name ?? "NoHostName"
        let platformVersion = ProcessInfo().operatingSystemVersionString
        #endif
        return [
            "X-Plex-Platform": "iOS",
            "X-Plex-Platform-Version": platformVersion,
            "X-Plex-Provides": "player,sync-target",
            "X-Plex-Client-Identifier": clientIdentifier,
            "X-Plex-Product": Bundle.main.bundleIdentifier ?? "NoBundleIdentifier",
            "X-Plex-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "NoBundleShortVersionString",
            "X-Plex-Device": deviceName,
            "X-Plex-Device-Name": [Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, "(\(deviceName)"]
                .compactMap { $0 }.joined(separator: " "),
            "X-Plex-Sync-Version": "2"
        ]
    }()

    lazy var requestHeadersQuery = requestHeaders.map {
        let key = $0.key
        let value = $0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "\(key)=\(value)"
        }.joined(separator: "&")

    var urlSession: URLSession!
    var authToken: String?

    public override init() {
        super.init()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1000
        configuration.timeoutIntervalForResource = 1000
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    // MARK: - API -

    // MARK: Sign In

    public enum SignInResponse {
        case inviteCode(String)
        case linked(PinRequest)
    }

    public func signIn() -> AnyPublisher<SignInResponse, Swift.Error> {
        let pinRequest = post(Path.Pins.request)
            .tryMap { [unowned self] in
                try self.parseResponseOrError(data: $0.data, keyPath: "pin") as PinRequest
            }.share()

        let checkRequest = Timer.publish(every: 5, on: .current, in: .common)
            .mapError { $0 } // FIXME: This probably isn't the right way.
            .drop(untilOutputFrom: pinRequest)
            // FIXME: There doesn't seem to be a way to `withLatestFrom`.
            .combineLatest(pinRequest) { [unowned self] (_, pin) in
                self.get(Path.Pins.check(pin: pin.id)).tryMap { [unowned self] in
                    try self.parseResponseOrError(data: $0.data, keyPath: "pin") as PinRequest
                }
            }
            .flatMap { $0 }
            .first { $0.authToken != nil && $0.expiresAt.timeIntervalSinceNow.sign == .plus }
            .map { SignInResponse.linked($0) }

        return pinRequest.map { SignInResponse.inviteCode($0.code) }
            .append(checkRequest).eraseToAnyPublisher()
    }

    // MARK: Info

    public func servers() -> AnyPublisher<PMSServersGETResponse, Swift.Error> {
        get(Path.PMS.servers)
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> PMSServersGETResponse in
                guard let object = PMSServersGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

    public func resources() -> AnyPublisher<APIResourcesGETResponse, Swift.Error> {
        get("\(Path.API.resources)?includeHttps=1&includeRelay=1")
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> APIResourcesGETResponse in
                guard let object = APIResourcesGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

    public func syncItems() -> AnyPublisher<DevicesSyncItemsGETResponse?, Swift.Error> {
        get("\(Path.API.resources)?includeHttps=1&includeRelay=1")
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> DevicesSyncItemsGETResponse in
                guard let object = DevicesSyncItemsGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

    public func allTracks(inSection sectionKey: String, connectionURI: String, deviceAccessToken: String) -> AnyPublisher<LibrarySectionsAllGETResponse, Swift.Error> {
        let url = Plex.RequestBuilder.librarySectionTracks(connectionURI: connectionURI, sectionKey: sectionKey).url.absoluteString
        return get(url, token: deviceAccessToken)
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> LibrarySectionsAllGETResponse in
                guard let object = LibrarySectionsAllGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

    public func tracks(forSyncItem syncItemID: Int, connectionURI: String, deviceAccessToken: String) -> AnyPublisher<LibrarySectionsAllGETResponse, Swift.Error> {
        let url = Plex.RequestBuilder.syncItemTracks(connectionURI: connectionURI, syncItemId: syncItemID).url.absoluteString
        return get(url, token: deviceAccessToken)
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> LibrarySectionsAllGETResponse in
                guard let object = LibrarySectionsAllGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

   public func sections(forConnectionURI connectionURI: String, deviceAccessToken: String) -> AnyPublisher<LibrarySectionsGETResponse, Swift.Error> {
        let url = Plex.RequestBuilder.sections(connectionURI: connectionURI).url.absoluteString
        return get(url, token: deviceAccessToken)
            .tryMap { response -> String in
                guard let stringValue = String(bytes: response.data, encoding: .utf8) else {
                    throw PlexError.dataParsingError
                }
                return stringValue
            }
            .tryMap { string -> LibrarySectionsGETResponse in
                guard let object = LibrarySectionsGETResponse(XMLString: string) else {
                    throw PlexError.dataParsingError
                }
                return object
            }
            .eraseToAnyPublisher()
    }

}

extension Plex {

    private func makeURLRequest(urlString: String, method: HTTPMethod, token: String? = nil, timeoutInterval: TimeInterval? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        var headers = requestHeaders
        headers["X-Plex-Token"] = token
        request.allHTTPHeaderFields = headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func parseResponseOrError<T: Codable>(data: Data, keyPath: String? = nil) throws -> T {
        var rootData = data

        if let keyPath = keyPath {
            let topLevel = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

            guard let nestedJson = (topLevel as AnyObject).value(forKeyPath: keyPath) else {
                throw PlexError.invalidRootKeyPath
            }

            rootData = try JSONSerialization.data(withJSONObject: nestedJson)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: rootData)
    }

    private func get(_ url: String, token: String? = nil, timeoutInterval: TimeInterval? = nil) -> URLSession.DataTaskPublisher {
        let request = makeURLRequest(urlString: url, method: HTTPMethod.get, token: token, timeoutInterval: timeoutInterval)
        return urlSession.dataTaskPublisher(for: request)
    }

    private func download(_ url: String, to saveLocation: URL, token: String? = nil, timeoutInterval: TimeInterval? = nil) -> Publishers.Future<URLResponse, Swift.Error> {
        let request = makeURLRequest(urlString: url, method: HTTPMethod.get, token: token, timeoutInterval: timeoutInterval)
        return Publishers.Future { observer in
            self.urlSession.downloadTask(with: request) { (url, response, error) in
                if let error = error {
                    observer(.failure(error))
                } else if let response = response, let url = url {
                    do {
                        try FileManager.default.moveItem(at: url, to: saveLocation)
                        observer(.success(response))
                    } catch let error {
                        observer(.failure(error))
                    }
                }
            }
        }
    }

    private func post(_ url: String, token: String? = nil, timeoutInterval: TimeInterval? = nil) -> URLSession.DataTaskPublisher {
        let request = makeURLRequest(urlString: url, method: HTTPMethod.post, token: token, timeoutInterval: timeoutInterval)
        return urlSession.dataTaskPublisher(for: request)
    }

    private func put(_ url: String, token: String? = nil, timeoutInterval: TimeInterval? = nil) -> URLSession.DataTaskPublisher {
        let request = makeURLRequest(urlString: url, method: HTTPMethod.put, token: token, timeoutInterval: timeoutInterval)
        return urlSession.dataTaskPublisher(for: request)
    }

}

extension Plex: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.performDefaultHandling, nil)
        }

        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }

}
