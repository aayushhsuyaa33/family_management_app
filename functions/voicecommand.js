const functions = require("firebase-functions");
const express = require("express");
const chrono = require("chrono-node");
const { OpenAI } = require("openai");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors({ origin: true }));

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || functions.config().openai.key,
});

function isPresent(v) {
  return v !== null && v !== undefined && !(typeof v === "string" && v.trim() === "");
}
// --- MAIN ENDPOINT ---
app.post("/voiceCommand", async (req, res) => {
  const { message, previousState = {} } = req.body;
  if (!message || message.trim() === "") {
    return res.status(400).json({ error: "Message is required" });
  }

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: `
You are a helpful assistant that helps users add a new task through voice commands.

Maintain and return a JSON like:
{
   "action": "add_task", "add_event",  // default is "add_task"; if user mentions "event" or "events" then "action" should be "add_event"
  "task": "string or null",        // title (required)
  "description": "string or null", // optional
  "member": "string or null",      // required
  "date": "string or null",       // required
  "question": "string or null"     // follow-up question if needed
}

Rules:
- First, check if the user explicitly mentions "event" or "events" (case-insensitive). 
  - If yes → set "action": "add_event"
  - Otherwise → default to "add_task"
- Always preserve known fields from previous state.
 Update **only missing or previously null fields**.  
   - If you are asking a follow-up question (in "question"), **only update that specific field** when the user responds.
- For tasks:
    - If task title missing → ask: "What should be the title of the task?"
    - If member missing → ask: "Who should I assign this task to?"
    - If date missing → ask: "Should I set the date for today or tomorrow?"
- For events:
    - If event title missing → ask: "What should be the title of the event?"
    - If date missing → ask: "Should I set the date for today or tomorrow?"
    - If member missing → ask: "Who should I assign this event to?"
- If all required fields (task, member, date) are present → question must be null.
- Return **pure JSON only** (no markdown or commentary).
          `,
        },
        {
          role: "user",
          content: `Previous known state: ${JSON.stringify(previousState)}
User said: ${message}`,
        },
      ],
      temperature: 0,
    });

    const rawResponse = completion.choices[0].message.content.trim();
    let parsed;

    try {
      parsed = JSON.parse(rawResponse);
    } catch (err) {
      console.error("Failed to parse JSON:", rawResponse);
      return res.status(500).json({ error: "Failed to parse JSON", raw: rawResponse });
    }

   const merged = {
  ...previousState,      // keep old fields
  ...parsed,             // override with AI's latest values
  action: parsed.action || previousState?.action || "add_task", // determine action properly
};

    const keys = ["task", "description", "member", "date", "question"];

    for (const k of keys) {
      if (isPresent(parsed[k])) merged[k] = parsed[k];
      else if (!(k in merged)) merged[k] = null;
    }




    // ✅ Backend-level check — if all required fields are present, clear question
    const allFilled = isPresent(merged.task) && isPresent(merged.member) && isPresent(merged.date);
    if (allFilled) merged.question = null;

    // Ensure all keys exist
    for (const k of keys) if (!(k in merged)) merged[k] = null;

    return res.json(merged);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message || "Internal error" });
  }
});

exports.voiceCommand = functions.https.onRequest(app);
