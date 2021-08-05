# StubServer
Vapor based server used for stubbing http responses. Useful for testing.

Before running make sure you have Docker installed

1: Build the docker image by running `docker compose build` from project root

2: Start a docker container for the StubServer by running `docker compose up app`

3: You can now go to localhost:8080/{Path} and get stub responses (E.G. `http://localhost:8080/fee.json`)

4: If you want to change the stubs then you must rebuild the image afterwards by running `docker compose up --build app`
