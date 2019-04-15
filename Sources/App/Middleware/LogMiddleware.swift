//
//  LogMiddleware.swift
//  App
//
//  Created by OrbitRemit LAP048 on 15/04/19.
//

import Vapor
import Foundation

public final class LogMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let logger = try request.make(ConsoleLogger.self)
        
        var reqString = request.http.method.string
        let path = request.http.url.path
        
        // not using string interpolation:
        // https://twitter.com/nicklockwood/status/971506873387143168
        reqString += "@"
        reqString += path
        if let query = request.http.url.query {
            reqString += " with query:\(query)"
        }
        
        let start = Date()
        
        // FIXME: better response error handling
        return try next.respond(to: request).map(to: Response.self) { res in
            let end = Date()
            // `end - start` is the length of the request handling, if no error was thrown
            var timing = (end.timeIntervalSinceReferenceDate -
                start.timeIntervalSinceReferenceDate).description
            timing += "s: "
            timing += reqString
            logger.console.output(reqString, style: .init(color: .red))
            return res
        }
    }
}

extension LogMiddleware: ServiceType {
    public static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
