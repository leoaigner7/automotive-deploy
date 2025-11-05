import { useState, useEffect } from "react";

const API = "http://localhost:8088";

export default function App() {
  const [status, setStatus] = useState("Lade...");
  const [version, setVersion] = useState("4.0.0");
  const [logs, setLogs] = useState("");

  // --- Health-Status prüfen ---
  const loadStatus = () => {
    fetch(`${API}/health`)
      .then((res) => res.json())
      .then((d) => setStatus(d.msg))
      .catch(() => setStatus("❌ Backend down"));
  };

  // --- Deploy auslösen ---
  const deploy = async () => {
    setLogs("🚀 Deploy gestartet...\n");

    try {
      const res = await fetch(`${API}/deploy`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          service: "hello-service",
          version: version,
        }),
      });

      const data = await res.json();

      if (data.ok) {
        setLogs((prev) => prev + data.output + "\n✅ Deploy ${version} abgeschlossen!\n");
        setStatus(`Aktive Version: ${version}`);
      } else {
        setLogs((prev) => prev + "❌ Fehler beim Deploy:\n" + data.output);
      }
    } catch (err) {
      setLogs((prev) => prev + "⚠️ Fehler: " + err.message);
    }
  };

  // --- Logs manuell laden ---
  const loadLogs = async () => {
    const t = await fetch(`${API}/logs?service=hello-service`);
    setLogs(await t.text());
  };

  useEffect(loadStatus, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 20 }}>
      <h1>🚗 Automotive Deployment Dashboard</h1>

      <h3>Status: {status}</h3>

      <div>
        <input
          value={version}
          onChange={(e) => setVersion(e.target.value)}
          style={{ padding: 6, marginRight: 8 }}
        />
        <button onClick={deploy}>Deploy Version</button>
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
          height: 200,
          overflow: "auto",
        }}
      >
        {logs}
      </pre>
    </div>
  );
}
