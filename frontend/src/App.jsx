import { useState, useEffect } from "react";

const API = "http://localhost:8088";

export default function App() {
  const [status, setStatus] = useState("Lade...");
  const [activeVersion, setActiveVersion] = useState("unbekannt");
  const [nextVersion, setNextVersion] = useState("1.0.0");
  const [logs, setLogs] = useState("");

  // --- Healthcheck ---
  const loadStatus = () => {
    fetch(`${API}/health`)
      .then((res) => res.json())
      .then((d) => setStatus(d.msg))
      .catch(() => setStatus("❌ Backend down"));
  };

  // --- Aktuelle Version ---
  const loadVersion = () => {
    fetch(`${API}/version`)
      .then((res) => res.json())
      .then((d) => {
        const current = d.version || "0.0.0";
        setActiveVersion(current);

        // Automatisch nächste Version berechnen (Major +1)
        const [major, minor, patch] = current.split(".").map(Number);
        const next = `${major + 1}.0.0`;
        setNextVersion(next);
      })
      .catch(() => {
        setActiveVersion("unbekannt");
        setNextVersion("1.0.0");
      });
  };

  // --- Deploy ---
  const deploy = async () => {
    setLogs("🚀 Deploy gestartet...\n");

    const res = await fetch(`${API}/deploy`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ service: "hello-service", version: nextVersion }),
    });

    const data = await res.json();

    if (data.ok) {
      setLogs(
        (prev) =>
          prev +
          data.output +
          `\n✅ Deploy ${nextVersion} abgeschlossen!\n`
      );

      // Nach kurzer Zeit Versionen neu berechnen
      setTimeout(() => {
        setActiveVersion(nextVersion);
        const [major, minor, patch] = nextVersion.split(".").map(Number);
        const upcoming = `${major + 1}.0.0`; // nächste Deploy-Version
        setNextVersion(upcoming);
        loadStatus();
      }, 3000);
    } else {
      setLogs((prev) => prev + "❌ Fehler beim Deploy:\n" + data.output);
    }
  };

  // --- Logs anzeigen ---
  const loadLogs = async () => {
    const t = await fetch(`${API}/logs?service=hello-service`);
    setLogs(await t.text());
  };

  // --- Beim Start alles laden ---
  useEffect(() => {
    loadStatus();
    loadVersion();
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 20 }}>
      <h1>🚗 Automotive Deployment Dashboard</h1>

      <h3>
        Status:{" "}
        {status.includes("läuft") ? (
          <span>
            Aktive Version: {activeVersion} ✅
          </span>
        ) : (
          <span>{status}</span>
        )}
      </h3>

      <div>
        <input
          value={nextVersion}
          onChange={(e) => setNextVersion(e.target.value)}
          style={{ padding: 6, marginRight: 8 }}
        />
        <button onClick={deploy}>Deploy neuVersion</button>
      </div>

      <button onClick={loadLogs} style={{ marginTop: 20 }}>
        📜 Logs anzeigen
      </button>

      <pre
        style={{
          background: "#111",
          color: "#0f0",
          padding: 10,
          marginTop: 10,
          height: 220,
          overflow: "auto",
        }}
      >
        {logs}
      </pre>
    </div>
  );
}
