import Vapor

// configures your application
public func configure(_ app: Application) throws {
  //Serve files from /Public folder
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  //Serve json stubs from /Public/Stubs folder
  app.middleware.use(StubsMiddleware(publicDirectory: app.directory.publicDirectory))
  // register routes
  try routes(app)
}
