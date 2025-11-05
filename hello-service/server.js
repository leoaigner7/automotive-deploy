import http from "http";

const port = 9090;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ ok: true, version: process.env.VERSION || "1.0.0" }));
  } else {
    const version = process.env.VERSION || "unknown";
    res.end(`Hello Automotive 🚗 Version ${version}`);
  }
});

server.listen(port, () => {
  console.log("hello-service läuft auf Port", port);
});
