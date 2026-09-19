const assert = require("node:assert/strict");
const { EventEmitter } = require("node:events");
const { detectionHandler } = require("../lib/detection-handler");
const { detectedMimeType } = require("../lib/multipart");
const { mapRoboflowClass, normalizeLabel, normalizeRoboflowResponse,
  selectPrimaryPrediction } = require("../lib/roboflow");

const tests = [];
function test(name, fn) { tests.push({ name, fn }); }

function responseRecorder() {
  const response = new EventEmitter();
  response.headers = {};
  response.setHeader = (name, value) => { response.headers[name.toLowerCase()] = value; };
  response.end = body => { response.body = body || ""; response.emit("done"); };
  return response;
}

async function callHandler({ method = "POST", contentType = "multipart/form-data; boundary=x", parse, fetch }) {
  const request = { method, headers: { "content-type": contentType } };
  const response = responseRecorder();
  await detectionHandler(request, response, { parseImageUpload: parse, fetch });
  return { status: response.statusCode, body: JSON.parse(response.body || "{}") };
}

test("normalizes labels", () => {
  assert.equal(normalizeLabel(" Printed Circuit__Board "), "printed-circuit-board");
});

test("maps supported classes and unknowns", () => {
  assert.equal(mapRoboflowClass("copper wire"), "cables");
  assert.equal(mapRoboflowClass("battery-cell"), "battery");
  assert.equal(mapRoboflowClass("CRT Monitor"), "crt");
  assert.equal(mapRoboflowClass("plastic bottle"), "other");
});

test("selects highest reliable supported prediction", () => {
  const result = normalizeRoboflowResponse({ predictions: [
    { class: "plastic bottle", confidence: 0.92, width: 100, height: 100 },
    { class: "battery", confidence: 0.88, width: 10, height: 10 }
  ] });
  assert.equal(result.categoryId, "battery");
  assert.equal(result.status, "detected");
});

test("uses area as tie breaker for close confidence", () => {
  const primary = selectPrimaryPrediction([
    { categoryId: "pcb", confidence: 0.81, width: 10, height: 10 },
    { categoryId: "motor", confidence: 0.80, width: 50, height: 50 }
  ]);
  assert.equal(primary.categoryId, "motor");
});

test("empty and low-confidence predictions are uncertain", () => {
  assert.equal(normalizeRoboflowResponse({ predictions: [] }).status, "uncertain");
  const low = normalizeRoboflowResponse({ predictions: [{ class: "pcb", confidence: 0.2 }] });
  assert.equal(low.categoryId, null);
  assert.deepEqual(low.predictions, []);
});

test("image signatures accept JPEG PNG and WebP only", () => {
  assert.equal(detectedMimeType(Buffer.from([0xff, 0xd8, 0xff, 0x00])), "image/jpeg");
  assert.equal(detectedMimeType(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])), "image/png");
  assert.equal(detectedMimeType(Buffer.from("RIFF0000WEBP")), "image/webp");
  assert.equal(detectedMimeType(Buffer.from("not-an-image")), null);
});

test("missing configuration returns a sanitized error", async () => {
  const previous = process.env.ROBOFLOW_API_KEY;
  delete process.env.ROBOFLOW_API_KEY;
  const result = await callHandler({ parse: async () => { throw new Error("should not run"); } });
  assert.equal(result.status, 503);
  assert.equal(result.body.code, "INFERENCE_NOT_CONFIGURED");
  assert.doesNotMatch(JSON.stringify(result.body), /stack|Bearer/i);
  if (previous === undefined) delete process.env.ROBOFLOW_API_KEY;
  else process.env.ROBOFLOW_API_KEY = previous;
});

test("missing image and invalid type are handled", async () => {
  Object.assign(process.env, { ROBOFLOW_API_KEY: "test-placeholder", ROBOFLOW_PROJECT_ID: "project", ROBOFLOW_MODEL_VERSION: "1" });
  const missing = await callHandler({ parse: async () => { throw Object.assign(new Error(), { code: "MISSING_IMAGE" }); } });
  assert.equal(missing.status, 400);
  assert.equal(missing.body.code, "MISSING_IMAGE");
  const invalid = await callHandler({ parse: async () => { throw Object.assign(new Error(), { code: "INVALID_FILE_TYPE" }); } });
  assert.equal(invalid.status, 400);
  assert.equal(invalid.body.code, "INVALID_FILE_TYPE");
});

test("upstream errors never expose secret or stack", async () => {
  Object.assign(process.env, { ROBOFLOW_API_KEY: "private-test-value", ROBOFLOW_PROJECT_ID: "project", ROBOFLOW_MODEL_VERSION: "1" });
  const result = await callHandler({
    parse: async () => ({ buffer: Buffer.from([1]), mimeType: "image/jpeg" }),
    fetch: async () => ({ ok: false, status: 500 })
  });
  assert.equal(result.status, 502);
  assert.equal(result.body.code, "INFERENCE_UNAVAILABLE");
  assert.doesNotMatch(JSON.stringify(result.body), /private-test-value|stack/i);
});

(async () => {
  for (const { name, fn } of tests) {
    try { await fn(); console.log(`ok - ${name}`); }
    catch (error) { console.error(`not ok - ${name}`); console.error(error); process.exitCode = 1; }
  }
})();
