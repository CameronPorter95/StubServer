//
//  StubsMiddleware.swift
//  App
//
//  Created by Cam on 04/08/21.
//

import Vapor

public final class StubsMiddleware: Middleware {
    
  /// The stubs directory.
  /// - note: Must end with a slash.
  private let stubsDirectory: String
  private let resourcesDirectory: String
  private let logsDirectory: String

  /// Creates a new `FileMiddleware`.
  public init(directory: DirectoryConfiguration) {
    self.stubsDirectory = directory.publicDirectory.appending("Stubs/")
    self.resourcesDirectory = directory.resourcesDirectory
    self.logsDirectory = directory.resourcesDirectory.appending("Logs/")
  }

  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    let method = request.method
    let path = request.url.path.dropFirst().replacingOccurrences(of: "/", with: ".").replacingOccurrences(of: ":", with: ".")
    let query = request.url.query
    
    if request.method == .POST {
      logToFile(request: request, message: """
        \(request.description)
        \(request.body.string ?? "")
        """)
    }
    
    if request.method == .POST,
    let postPath = try? getPOSTResponsePath(for: request, path: path, method: method, query: query) {
      log(request: request, message: postPath)
      let res = request.fileio.streamFile(at: postPath)
      return request.eventLoop.makeSucceededFuture(res)
    }
    else {
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
  }
  
  private func getPOSTResponsePath(for request: Request, path: String, method: HTTPMethod, query: String?) throws -> String {
    guard let sortedString = request.body.string?.lazy.filter({ !$0.isWhitespace && $0 != "\"" }).sorted().map({ $0.description }).joined() else {
      throw Abort(.notFound)
    }

    let requestsMapPath = URL(fileURLWithPath: resourcesDirectory).appendingPathComponent("RequestsMap.json", isDirectory: false)
    let requestsMapData = try Data(contentsOf: requestsMapPath)
    let requestsMap: RequestsMap = try JSONDecoder().decode(RequestsMap.self, from: requestsMapData)
    
    guard let postIdentifier = requestsMap.requests.first(where: {
      $0.value == sortedString
    }) else {
      throw Abort(.notFound)
    }
    
    let straightfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path).\(postIdentifier.key).\(method).json", isDirectory: false).path

    let queryfilePath = URL(fileURLWithPath: stubsDirectory)
      .appendingPathComponent("\(path)?\(query ?? "").\(postIdentifier.key).\(method).json", isDirectory: false).path
    
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
  
  func logToFile(request: Request, message: String, level: Logger.Level = .info) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-DD"
    let dateString = dateFormatter.string(from: Date())
    let path = logsDirectory.appending("\(dateString).log")
    
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
      log(request: request, message: "log file exists, writing to \(path)")
      let content = request.fileio.streamFile(at: path)
      request.fileio.writeFile(ByteBuffer(string: """
        \(content)
        \(message)
        
        """), at: path)
    } else {
      log(request: request, message: "log file doesn't exist, creating at \(path)")
      FileManager.default.createFile(atPath: path, contents: message.data(using: .utf8))
    }
  }
}

struct RequestsMap: Decodable {
  var requests: [String: String]
}
