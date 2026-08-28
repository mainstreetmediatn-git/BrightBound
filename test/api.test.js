import assert from "node:assert/strict";
import { createServer } from "node:http";
import { after, before, test } from "node:test";
import { app } from "../src/app.js";

let server;
let baseUrl;

before(async () => {
  server = createServer(app);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) =>
    server.close((error) => (error ? reject(error) : resolve())),
  );
});

test("health endpoint reports a healthy service", async () => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    status: "ok",
    service: "brightbound-api",
  });
});

test("verification endpoint returns API identity", async () => {
  const response = await fetch(`${baseUrl}/api/verify`, {
    headers: { "x-request-id": "test-request" },
  });
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("x-request-id"), "test-request");
  assert.deepEqual(await response.json(), {
    verified: true,
    name: "brightbound-api",
    version: "1.0.0",
  });
});

test("unknown routes and unsupported methods return JSON errors", async () => {
  const missing = await fetch(`${baseUrl}/missing`);
  assert.equal(missing.status, 404);
  assert.equal((await missing.json()).error, "Not found");

  const unsupported = await fetch(`${baseUrl}/health`, { method: "POST" });
  assert.equal(unsupported.status, 405);
  assert.equal((await unsupported.json()).error, "Method not allowed");
});
