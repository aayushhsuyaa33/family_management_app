const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const { OpenAI } = require("openai");

const app = express();
app.use(express.json());
app.use(cors({ origin: true }));

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || functions.config().openai.key
});

app.post("/chatWithGPTStreaming", async (req, res) => {
  const { message } = req.body;
  if (!message) return res.status(400).json({ error: "Message is required" });

  try {
    // SSE headers
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");
    res.flushHeaders();

    let assistantMessage = "";

    // Stream from OpenAI
    const stream = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: message }],
      stream: true
    });

    for await (const event of stream) {
      // Each event may contain a delta
      const delta = event.choices[0].delta?.content;
      if (delta) {
        assistantMessage += delta;

        // Send each delta as SSE chunk
        res.write(`data: ${delta}\n\n`);
      }
    }

    // Signal end of stream
    res.write("data: [DONE]\n\n");
    res.end();
  } catch (err) {
    console.error("Streaming error:", err);
    if (!res.headersSent) {
      res.status(500).json({ error: err.message });
    } else {
      res.write(`data: Error: ${err.message}\n\n`);
      res.end();
    }
  }
});

exports.chatWithGPTStreaming = functions.https.onRequest(app);
