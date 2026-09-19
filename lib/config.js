const DEFAULT_ALLOWED_ORIGINS = "http://localhost:3000,http://localhost:5173";

function numberFromEnv(name, fallback) {
  const value = Number(process.env[name] ?? fallback);
  return Number.isFinite(value) && value >= 0 && value <= 1 ? value : fallback;
}

function getRoboflowConfig() {
  const config = {
    apiKey: String(process.env.ROBOFLOW_API_KEY || "").trim(),
    projectId: String(process.env.ROBOFLOW_PROJECT_ID || "").trim(),
    modelVersion: String(process.env.ROBOFLOW_MODEL_VERSION || "").trim(),
    confidence: numberFromEnv("ROBOFLOW_CONFIDENCE_THRESHOLD", 0.45),
    overlap: numberFromEnv("ROBOFLOW_OVERLAP_THRESHOLD", 0.30)
  };
  return { ...config, configured: Boolean(config.apiKey && config.projectId && config.modelVersion) };
}

function allowedOrigins() {
  return String(process.env.ALLOWED_ORIGINS || DEFAULT_ALLOWED_ORIGINS)
    .split(",").map(value => value.trim()).filter(Boolean);
}

module.exports = { allowedOrigins, getRoboflowConfig };
