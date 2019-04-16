//
//  StubsMiddleware.swift
//  App
//
//  Created by OrbitRemit LAP048 on 15/04/19.
//

import FluentSQLite
import Vapor
import Foundation

struct RouteError: Error {
    let message: String
}

private let projectDir = ProcessInfo.processInfo.environment["PROJECT_DIR"]

final class StubsMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard let projectDir = projectDir else {
            throw RouteError(message: "PROJECT_DIR environment variable not set")
        }
        
        let method = request.http.method
        let path = request.http.url.path.dropFirst().replacingOccurrences(of: "/", with: ".")
        let query = request.http.url.query
        let queryfilePath = "\(projectDir)/Stubs/\(path)?\(query ?? "").\(method).json"
        let straightfilePath = "\(projectDir)/Stubs/\(path).\(method).json"
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: queryfilePath, isDirectory: &isDir) {
            print(queryfilePath)
            return try request.streamFile(at: queryfilePath)
        } else {
            if FileManager.default.fileExists(atPath: straightfilePath, isDirectory: &isDir) {
                print(straightfilePath)
                return try request.streamFile(at: straightfilePath)
            } else {
                return try next.respond(to: request)
            }
        }
    }
}

extension StubsMiddleware: ServiceType {
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
}
