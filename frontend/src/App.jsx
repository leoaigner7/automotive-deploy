import { useState, useEffect } from "react";

const API = "http://localhost:8088";

export default function App() {
  const [status, setStatus] = useState("Lade...");
  const [activeVersion, setActiveVersion] = useState("unbekannt");
  const [nextVersion, setNextVersion] = useState("1.0.0");
  const [logs, setLogs] = useState("");

  const loadStatus = () =>
    fetch(`${API}/health`)
      .then((r) => r.json())
      .then((d) => setStatus(d.msg))
      .catch(() => setStatus("❌ Backend down"));

  const loadVersion = () =>
    fetch(`${API}/version`)
      .then((r) => r.json())
      .then((d) => {
        const v = d.version || "0.0.0";
        setActiveVersion(v);
        const [maj] = v.split(".").map(Number);
        setNextVersion(`${maj + 1}.0.0`);
      })
      .catch(() => {
        setActiveVersion("unbekannt");
        setNextVersion("1.0.0");
      });

  const deploy = async () => {
    setLogs("🚀 Deploy gestartet...\n");
    try {
      const res = await fetch(`${API}/deploy`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ service: "hello-service", version: nextVersion }),
      });

      const data = await res.json();
      if (data.ok) {
        setLogs(
          (prev) => prev + data.output + `\n✅ Deploy ${nextVersion} abgeschlossen!\n`
        );
        setTimeout(() => {
          setActiveVersion(nextVersion);
          const [maj] = nextVersion.split(".").map(Number);
          setNextVersion(`${maj + 1}.0.0`);
          loadStatus();
        }, 3000);
      } else {
        setLogs((prev) => prev + "❌ Fehler beim Deploy:\n" + data.output);
      }
    } catch (e) {
      setLogs((prev) => prev + "\n❌ Netzwerkfehler: " + e);
    }
  };

  const loadLogs = async () => {
    const t = await fetch(`${API}/logs?service=hello-service`);
    setLogs(await t.text());
  };

  useEffect(() => {
    loadStatus();
    loadVersion();
  }, []);

  // === UI ===
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-100 via-gray-50 to-gray-200 dark:from-neutral-900 dark:via-neutral-950 dark:to-neutral-900 text-gray-900 dark:text-gray-100 p-8 transition-colors duration-500">
      
      {/* 🌙 / ☀️ Theme Toggle */}
      <button
        onClick={() => document.documentElement.classList.toggle("dark")}
        className="absolute top-6 right-6 text-gray-400 hover:text-yellow-300 text-xl transition"
        title="Theme umschalten"
      >
        🌙 / ☀️
      </button>

      <header className="flex items-center justify-between mb-10">
        <h1 className="text-4xl font-extrabold text-blue-600 tracking-tight flex items-center gap-2">
          🚗 Automotive Deploy <span className="text-gray-700 dark:text-gray-300">v2</span>
        </h1>
        <span className="text-sm text-gray-500 dark:text-gray-400">CI/CD Dashboard</span>
      </header>

      <div className="grid md:grid-cols-3 gap-8">
        {/* System-Status */}
        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 bg-white/60 dark:bg-neutral-800/80 backdrop-blur-xl p-6 shadow-lg hover:shadow-blue-500/10 transition-all duration-300">
          <h2 className="font-semibold text-lg mb-3 text-gray-800 dark:text-gray-100">System-Status</h2>
          <p>
            {status.includes("läuft") ? (
              <span className="text-green-500 font-medium">
                Aktiv ✅ – Version {activeVersion}
              </span>
            ) : (
              <span className="text-red-500">{status}</span>
            )}
          </p>
          <button
            onClick={loadStatus}
            className="mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-md shadow-blue-600/20 hover:shadow-blue-600/40 transition"
          >
            🔄 Neu laden
          </button>
        </div>

        {/* Deployment */}
        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 bg-white/60 dark:bg-neutral-800/80 backdrop-blur-xl p-6 shadow-lg hover:shadow-green-500/10 transition-all duration-300">
          <h2 className="font-semibold text-lg mb-3 text-gray-800 dark:text-gray-100">Deployment</h2>
          <input
            value={nextVersion}
            onChange={(e) => setNextVersion(e.target.value)}
            className="border border-gray-300 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-gray-900 dark:text-gray-100 placeholder-gray-400 rounded-lg px-3 py-2 w-full mb-3"
          />
          <button
            onClick={deploy}
            className="w-full py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl shadow-md shadow-green-600/20 hover:shadow-green-600/40 transition"
          >
            🚀 Deploy {nextVersion}
          </button>
        </div>

        {/* Logs */}
        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 bg-white/60 dark:bg-neutral-800/80 backdrop-blur-xl p-6 shadow-lg hover:shadow-yellow-500/10 transition-all duration-300 flex flex-col">
          <h2 className="font-semibold text-lg mb-3 text-gray-800 dark:text-gray-100">📜 Logs</h2>
          <button
            onClick={loadLogs}
            className="mb-3 px-4 py-2 bg-neutral-800 text-gray-100 rounded-lg hover:bg-neutral-700 transition"
          >
            Logs aktualisieren
          </button>
          <pre className="flex-1 bg-neutral-950 text-green-400 text-xs font-mono p-4 rounded-lg overflow-auto border border-neutral-700 shadow-inner">
            {logs || "Noch keine Logs geladen…"}
          </pre>
        </div>
      </div>
    </div>
  );
}
