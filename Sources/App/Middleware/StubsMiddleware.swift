//
//  StubsMiddleware.swift
//  App
//
//  Created by Cam on 04/08/21.
//

import Vapor

public final class StubsMiddleware: Middleware {
    
  /// The public directory.
  /// - note: Must end with a slash.
  private let stubsDirectory: String

  /// Creates a new `FileMiddleware`.
  public init(publicDirectory: String) {
    self.stubsDirectory = (publicDirectory.hasSuffix("/") ? publicDirectory : publicDirectory + "/").appending("Stubs/")
  }

  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    let method = request.method
    let path = request.url.path.dropFirst().replacingOccurrences(of: "/", with: ".")
    let query = request.url.query
    let straightfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path).\(method).json", isDirectory: false).path
    
    let queryfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path)?\(query ?? "").\(method).json", isDirectory: false).path
    
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: queryfilePath, isDirectory: &isDir) {
      log(request: request, message: queryfilePath)
      let res = request.fileio.streamFile(at: queryfilePath)
      return request.eventLoop.makeSucceededFuture(res)
    } else {
      if FileManager.default.fileExists(atPath: straightfilePath, isDirectory: &isDir) {
        log(request: request, message: straightfilePath)
        let res = request.fileio.streamFile(at: straightfilePath)
        return request.eventLoop.makeSucceededFuture(res)
      } else {
        log(request: request, message: "couldn't find any files", level: .error)
        return next.respond(to: request)
      }
    }
  }
  
  func log(request: Request, message: String, level: Logger.Level = .info) {
    let log = Logger.Message.init(stringLiteral: message)
    request.logger.log(level: level, log)
  }
}
