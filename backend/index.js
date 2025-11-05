import express from "express";
import cors from "cors";
import { exec } from "child_process";
const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ ok:true, msg: "Backend läuft ✅" });
});

app.get("/about", (req,res) => {
  res.json({ author: "DeinName", lernst: "Backend" });
});

const port = process.env.PORT || 8080;

app.listen(port, "0.0.0.0", () => {
  console.log("✅ Backend läuft auf Port " + port);
});

// DEPLOY ENDPOINT
app.post("/deploy", (req, res) => {
  const { service, version } = req.body;

  if (!service || !version) {
    return res.status(400).json({ error: "service & version required" });
  }

  const cmd = `cd /ops/scripts && ./deploy.sh ${service} ${version}`;

  exec(cmd, (err, stdout, stderr) => {
    if (err) {
      return res.json({ ok: false, output: stderr || stdout });
    }
    res.json({ ok: true, output: stdout });
  });
});

// LOGS ENDPOINT
app.get("/logs", (req, res) => {
  const service = req.query.service;

  if (!service) return res.status(400).send("service missing");

  const cmd = `docker logs --tail 50 ${service} 2>&1`;

  exec(cmd, (err, stdout) => {
    res.set("Content-Type", "text/plain");
    res.send(stdout || "No logs");
  });
});
