import express from "express";
const app = express();

app.get("/health", (req, res) => {
  res.json({ ok: true, msg: "hello-service läuft ✅" });
});

const port = process.env.PORT || 9090;
app.listen(port, "0.0.0.0", () => {
  console.log(`hello-service läuft auf Port ${port}`);
});
