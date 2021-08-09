//
//  StubsMiddleware.swift
//  App
//
//  Created by Cam on 04/08/21.
//

import Vapor
//import SwiftyJSON

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
    
//    if let postPath = try? getPOSTResponsePath(for: request, path: path, method: method, query: query) {
//      log(request: request, message: postPath)
//      let res = request.fileio.streamFile(at: postPath)
//      return request.eventLoop.makeSucceededFuture(res)
//    }
//    else {
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
//    }
  }
  
  func getPOSTResponsePath(for request: Request, path: String, method: HTTPMethod, query: String?) throws -> String {
    let json = request.content.decode(JSON.self)
    guard let attributesDict = response.data?.attributes else { throw Abort(.noContent) }

    let attributesData = try JSONSerialization.data(withJSONObject: attributesDict)
    let base64Attributes = attributesData.base64EncodedString()

    let straightfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path).\(base64Attributes).\(method).json", isDirectory: false).path

    let queryfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path)?\(query ?? "").\(base64Attributes).\(method).json", isDirectory: false).path
    log(request: request, message: straightfilePath)
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: queryfilePath, isDirectory: &isDir) {
      return queryfilePath
    } else if FileManager.default.fileExists(atPath: straightfilePath, isDirectory: &isDir) {
      return straightfilePath
    }

    throw Abort(.notFound)
  }
  
  func log(request: Request, message: String, level: Logger.Level = .info) {
    let log = Logger.Message.init(stringLiteral: message)
    request.logger.log(level: level, log)
  }
}

//struct BackendResponse: Codable {
//  var data: Attributes?
//
//  init(data: Attributes) {
//    self.data = data
//  }
//}
//
//struct Attributes: Codable {
//  var attributes: [String: Any]?
//}
