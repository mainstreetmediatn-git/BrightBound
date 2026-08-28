# BrightBound API

A small, dependency-free Node.js API with Docker and VS Code Dev Container support.

## Verify locally

Node.js 22 or newer is required.

```sh
npm test
npm start
curl http://localhost:3000/health
curl http://localhost:3000/api/verify
```

The verification endpoint responds with:

```json
{"verified":true,"name":"brightbound-api","version":"1.0.0"}
```

## Run with Docker

```sh
docker compose up --build
```

Docker publishes the API at <http://localhost:3000> and checks `/health` to
verify container health.

## Open in VS Code

Install the **Dev Containers** extension and run **Dev Containers: Reopen in
Container**. The repository includes recommended extensions, a debugger, test
and Docker tasks, port forwarding, and automatic API startup.
