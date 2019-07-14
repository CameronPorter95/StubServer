## Stub Server ##

To enable quick local testing and automated UI testing that doesn't rely on a
production server, you can use StubServer project locally that serves
prepared static responses. The stub server uses [Vapor](http://vapor.codes) and is written
in Swift. Stub server dependencies are managed with 
[Swift Package Manager](https://docs.vapor.codes/3.0/getting-started/spm/).

To setup the stub server:
1. install vapor by running 'brew install vapor/tap/vapor'
2. go to StubServer folder and run 'vapor xcode'
3. open the xcode "StubServer" workspace
4. select the "run" scheme and choose to execute on "My Mac"
5. you should see:
  "Migrating sqlite DB
  Migrations complete
  Server starting on http://localhost:8080"
  in the console.
  go to: http://localhost:8080/messages.json and check that you're getting json response from the stub server to verify that it is working
6. success!
