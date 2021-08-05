# StubServer
To enable quick local testing and automated UI testing that doesn't rely on a production server, you can use StubServer project locally that serves prepared static responses. The stub server uses Vapor and is written in Swift. Stub server dependencies are managed with Swift Package Manager.

Before running make sure you have Docker installed

1: Build the docker image by running `docker compose build` from project root

2: Start a docker container for the StubServer by running `docker compose up app`

3: You can now go to localhost:8080/{Path} and get stub responses (E.G. `http://localhost:8080/fee.json`)

4: If you want to change the stubs then you must rebuild the image afterwards by running `docker compose up --build app`
