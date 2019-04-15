//
//  middlewares.swift
//  App
//
//  Created by OrbitRemit LAP048 on 15/04/19.
//

import Vapor

public func middlewares(config: inout MiddlewareConfig) throws {
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(StubsMiddleware.self) // Serves responses from 'Stubs/' directory
    config.use(LogMiddleware.self)   // Enforces cleaner logs
}
