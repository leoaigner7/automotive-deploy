import { useState, useEffect } from "react";

export default function App() {
  const [status, setStatus] = useState("Lade...");

  useEffect(() => {
    fetch("http://localhost:8088/health")
      .then(res => res.json())
      .then(data => setStatus(data.msg))
      .catch(() => setStatus("Backend nicht erreichbar ❌"));
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 30 }}>
      <h1>🚗 Automotive Deployment Dashboard</h1>
      <h3>Status:</h3>
      <p>{status}</p>
    </div>
  );
}
