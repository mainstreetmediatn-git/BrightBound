import { randomUUID } from "node:crypto";

const service = Object.freeze({
  name: "brightbound-api",
  version: "1.0.0",
});

function sendJson(response, statusCode, payload, requestId) {
  response.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
    "x-content-type-options": "nosniff",
    "x-request-id": requestId,
  });
  response.end(JSON.stringify(payload));
}

export function app(request, response) {
  const requestId = request.headers["x-request-id"] || randomUUID();
  const url = new URL(request.url, "http://localhost");

  if (request.method !== "GET") {
    sendJson(response, 405, { error: "Method not allowed", requestId }, requestId);
    return;
  }

  if (url.pathname === "/health") {
    sendJson(response, 200, { status: "ok", service: service.name }, requestId);
    return;
  }

  if (url.pathname === "/api/verify") {
    sendJson(response, 200, { verified: true, ...service }, requestId);
    return;
  }

  sendJson(response, 404, { error: "Not found", requestId }, requestId);
}
