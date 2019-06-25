//
//  File.swift
//  
//
//  Created by Kesi Maduka on 6/25/19.
//

import Combine
import Foundation

extension Publisher {

    public func wait() -> (outputs: [Self.Output], failure: Self.Failure?) {
        var outputs = [Self.Output]()
        var failure: Self.Failure?
        var running = true
        _ = self.sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                failure = error
            }
            running = false
        }, receiveValue: { output in
            outputs.append(output)
        })

        while running {
            RunLoop.main.run(mode: .common, before: .distantFuture)
        }

        return (outputs: outputs, failure: failure)
    }

    public func waitFirst() throws -> Self.Output? {
        var output: Self.Output?
        var failure: Self.Failure?
        var running = true
        _ = self.sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                failure = error
            }
            running = false
        }, receiveValue: { o in
            output = o
        })

        while output == nil && running {
            RunLoop.main.run(mode: .common, before: .distantFuture)
        }

        if let failure = failure {
            throw failure
        }

        return output
    }

}
