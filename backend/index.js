import fs from "fs";
import express from "express";
import cors from "cors";
import { exec } from "child_process";

const app = express();
app.use(cors());
app.use(express.json());

app.post("/deploy", (req, res) => {
  const { service, version } = req.body;
  if (!service || !version) {
    return res.status(400).json({ ok: false, output: "Missing parameters" });
  }

  const cmd = `bash /ops/scripts/deploy.sh ${service} ${version}`;
  exec(cmd, (err, stdout, stderr) => {
    if (err) return res.json({ ok: false, output: stderr || stdout });

    // ✅ Version speichern
    try {
      fs.mkdirSync("/ops/state", { recursive: true });
      fs.writeFileSync("/ops/state/current_version.txt", version);
    } catch (e) {
      console.error("Fehler beim Speichern der Version:", e);
    }

    res.json({ ok: true, output: stdout });
  });
});

app.get("/version", (req, res) => {
  try {
    const path = "/ops/state/hello-service.current";
    const version = fs.readFileSync(path, "utf8").trim();
    res.json({ version });
  } catch (e) {
    res.json({ version: "unbekannt" });
  }
});

app.get("/health", (req, res) => {
  res.json({ ok: true, msg: "Backend läuft ✅" });
});

const port = process.env.PORT || 8088;
app.listen(port, "0.0.0.0", () => console.log(`✅ Backend läuft auf Port ${port}`));
