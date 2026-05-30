const functions = require("firebase-functions");
const express = require("express");
const { OpenAI } = require("openai");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors({ origin: true }));

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || functions.config().openai.key,
});

// Non-streaming AI reply
async function getChatGptReply(message) {
  const completion = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: message }],
  });

  return completion.choices[0].message.content.trim();
}

// Chat endpoint
app.post("/chatWithGPT", async (req, res) => {
  const { message } = req.body;
  if (!message || message.trim() === "") {
    return res.status(400).json({ error: "Message is required" });
  }

  try {
    const reply = await getChatGptReply(message);
    res.json({ reply });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || "Internal error" });
  }
});

// Export as separate Firebase function
exports.chatWithGPT = functions.https.onRequest(app);
