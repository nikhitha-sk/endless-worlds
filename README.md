# 🌍 Endless Worlds

**Endless Worlds** is a 2D educational adventure game built with **Godot 4**. You explore a procedurally generated island world, collect hints, and answer AI-powered riddles to earn points and level up. The game uses a real AI (Groq LLM) to create fresh questions on any topic you choose — making every run a unique learning experience.

---

## Table of Contents

1. [What is this game?](#what-is-this-game)
2. [How to Play](#how-to-play)
3. [How It Works](#how-it-works)
4. [Features](#features)
5. [Question Types](#question-types)
6. [AI and Riddle System](#ai-and-riddle-system)
7. [The Learning Journal](#the-learning-journal)
8. [The Agentic Bot](#the-agentic-bot)
9. [Controls](#controls)
10. [Technical Overview](#technical-overview)
11. [Setup and Configuration](#setup-and-configuration)

---

## What is this game?

Endless Worlds turns learning into an adventure. Instead of sitting through a quiz, you walk around a living island — dodging lava, wading through water, watching fireflies at night — while collecting clues and answering questions about a topic **you choose**.

The AI generates a new riddle every time you play. Collect hint pickups hidden across the map to unlock clues, then walk up to the **well** and submit your answer. Get it right and you level up. Run out of hearts and the run ends, sending you back to the home screen with your score saved.

---

## How to Play

1. **Start the game** — you land on the Home Screen.
2. **Type a topic** in the text box (e.g. `python`, `history`, `space`, `cricket`). Leave it blank and it defaults to `programming`.
3. Press **Start** — the world generates and a riddle is created by the AI.
4. **Explore** the island to find glowing hint pickups. Each one you collect unlocks the next hint for your riddle.
5. Walk up to the **well** and press the interaction key to open the answer popup.
6. Answer the question correctly to earn **+50 points** and advance to the next level.
7. Avoid **lava** and **magma** — they drain your hearts. Staying too long in **water** consumes air bubbles and eventually damages you too.
8. Lose all hearts and you are sent back to the Home Screen. Your high score is saved automatically.

---

## How It Works

Here is the flow from start to finish:

```
Home Screen
   |
   +-- Player types a topic and presses Start
   |
   +--> Map Scene loads
          |
          +-- World generates procedurally (Simplex noise)
          +-- AI picks a subtopic and searches the web for context
          +-- Groq LLM generates a riddle + 4 options + 4 hints + a fun fact
          +-- Hint pickups are scattered around the map
          |
          +-- Player explores, collects hints (bot reads them out loud)
          +-- Player answers at the well --> popup appears
          |
          +-- Correct answer --> +50 score, next level, new riddle generated
          +-- Wrong answer --> lose a heart; try again
                |
                +--> 0 hearts --> death screen --> back to Home Screen
```

---

## Features

### World and Environment

| Feature | Description |
|---|---|
| Procedural generation | Every game creates a new island using Simplex noise |
| Tile types | Grass, Dirt, Clay, Mud, Sand, Lava, Magma, Water — each with different effects |
| Day/Night cycle | The world transitions through dawn, day, dusk, and night automatically |
| Dynamic lighting | Brightness and color shift based on the time of day; lava tiles glow at night |
| Weather | Rain falls with a parallax effect (near and far layers); one world variant has snow |
| Decorations | Flowers and trees are randomly placed on grass tiles each run |
| Fireflies | Appear at night and add to the atmosphere |

### Education and AI

| Feature | Description |
|---|---|
| AI riddle generation | Groq LLM creates a unique question every run based on your chosen topic |
| Web-grounded questions | The AI searches the web (via Serper.dev) before generating, so questions are current and relevant |
| Any topic | Type anything — programming, maths, geography, cooking, film — the AI adapts |
| Adaptive difficulty | A reinforcement learning model adjusts difficulty (Very Easy to Very Hard) based on your win/loss history |
| Hint system | Collect up to 4 hints by picking up glowing items on the map |
| Fallback riddles | If the AI or internet is unavailable, pre-written fallback riddles are used |

### Player and Survival

| Feature | Description |
|---|---|
| Heart system | 5 hearts; displayed top-right with animated heart icons |
| Lava/Magma damage | Walking on these tiles deals 1 heart of damage every 2 seconds |
| Water drowning | You have 5 air bubbles in water; when they run out you start losing hearts |
| Camera shake | The screen shakes every time you take damage |
| Death screen | A blurred overlay appears with a message, your score, and the correct answer |

### Progression and Scores

| Feature | Description |
|---|---|
| Score | +50 points per correct answer; displayed live on the map |
| High score | Persists between sessions |
| Level | Increases with each correct answer |
| Lifetime stats | Tracks total games, wins, losses, hints used, best level, play time, and per-topic records |
| Reset | You can wipe all stats from the Stats panel on the Home Screen |

### Visual Polish

| Feature | Description |
|---|---|
| Animated player | Frame-based directional walk animations |
| Water tinting | Player sprite gets a blue tint and visually sinks when in water |
| Particle effects | Water bubbles, rain particles, splash effects |
| Custom fonts | Jersey10 pixel font and Noto Color Emoji for emoji characters |
| Screen blur shader | Death overlay uses a GLSL blur shader |
| Smooth tweens | UI elements (hearts, death screen, bot bubble) animate in and out smoothly |

---

## Question Types

Every game randomly picks one of six question formats:

| Type | How you answer |
|---|---|
| **MCQ** (Multiple Choice) | Pick A, B, C, or D from four options |
| **Fill in the Blank** | Type the answer in a text box |
| **Wordle** | Guess the answer letter by letter (green = correct spot, yellow = wrong spot, grey = not in word) |
| **Whack-a-Mole** | Click the correct answer when it pops up in a mole grid before time runs out |
| **Word Lock** | Scroll columns of letters to spell out the correct word |
| **KBC** (Kaun Banega Crorepati style) | Multiple choice with three lifelines: 50:50 (removes two wrong answers), Audience Poll, and Phone a Friend — each lifeline costs 2 hearts |

---

## AI and Riddle System

Here is what happens behind the scenes when a riddle is generated:

1. **Topic resolution** — The AI takes your topic and picks one of five related subtopics to focus on (e.g. "python" might become "list comprehensions").
2. **Web search** — Serper.dev searches Google for quiz content on that subtopic.
3. **Web scraping** — The top result is fetched and the visible text is extracted (HTML tags are stripped).
4. **LLM call** — The extracted text (up to 5,000 characters) is sent to Groq with a prompt asking for a question, 4 options, 1 correct answer, 4 hints, and a fun fact — all returned as JSON.
5. **Fallback** — If any step fails (no API key, network error, bad response), a pre-written riddle is used instead.

The fact extracted from the riddle is automatically saved to your **Learning Journal** as a concept.

---

## The Learning Journal

The Learning Journal is a book-style popup you can open from the Home Screen using the **Journal** button in the top-right corner. It has three tabs:

- **Solved Riddles** — Every riddle you answered correctly, with the question, your answer, the topic, and the time.
- **Concepts** — Facts and explanations pulled from the AI's response for each riddle.
- **Fun Facts** — Facts the Agentic Bot shares with you during gameplay (drawn from your concept pool).

Everything is saved automatically and persists between sessions.

---

## The Agentic Bot

A small animated robot lives in the bottom-right corner of the game screen. It:

- **Waves, thinks, then speaks** — when you collect a hint, the bot reads it out in a speech bubble with a typewriter effect.
- **Shares facts every 2 minutes** — it picks a random concept or fun fact from your Learning Journal to keep you engaged.
- **Reacts to you** — clicking the bot makes it jump.

The bot cycles through five animations: idle, talking, thinking, happy, and waving.

---

## Controls

| Action | Key / Input |
|---|---|
| Move | WASD or Arrow Keys |
| Sprint | Left Shift |
| Interact with well | Walk up to it (popup opens automatically) |
| Virtual joystick | On-screen joystick (touch / mobile) |
| Gamepad | D-pad or left analog stick |

---

## Technical Overview

The project is built with **Godot 4.5** using **GDScript**. Here is how the code is organized:

```
endless-worlds/
+-- HomeScreen.gd / .tscn      — Main menu scene
+-- map/
|   +-- map.gd                 — Core game scene: world setup, scoring, death, fact timer
|   +-- world_generator.gd     — Simplex noise island generation
|   +-- time_system.gd         — Day/night cycle
|   +-- lighting_system.gd     — Dynamic lighting and lava lights
|   +-- rain_system.gd         — Rain/snow particles
|   +-- rain_controller.gd     — Weather intensity control
|   +-- flower_spawner.gd      — Random flower placement
|   +-- tree_spawner.gd        — Random tree placement
|   +-- firefly_manager.gd     — Night firefly effects
+-- scripts/
|   +-- utils/
|   |   +-- Global.gd          — Autoload singleton: score, level, stats, journal, save/load
|   |   +-- env_loader.gd      — Reads API keys from .env file
|   +-- ui/
|   |   +-- HeartSystem.gd     — Heart display, damage, camera shake
|   |   +-- AgenticBot.gd      — Animated bot with speech bubble
|   |   +-- LearningJournal.gd — Book-style journal popup (3 tabs)
|   +-- riddleui/
|       +-- RiddleUI.gd        — In-world riddle display and hint unlocking
|       +-- HintBulb.gd        — Hint bulb icon
+-- ai/
|   +-- DifficultyRL.gd        — Q-learning model for adaptive difficulty
+-- answer_popup.gd / .tscn    — All 6 question-type UIs in one popup
+-- gemini_riddle.gd           — AI pipeline: topic resolve -> web search -> scrape -> LLM call
+-- player.gd                  — Player movement, animations, water/tile effects
+-- tasks.gd                   — Hint pickup spawning and collection
+-- HintPickup.gd / .tscn      — Individual hint item in the world
+-- well.gd                    — Interactive well that opens the answer popup
```

**Key autoloads (always active):**
- `Global` — game state, stats, journal, save/load
- `DifficultyRl` — adaptive difficulty model
- `env_loader` — API key loading

**Persistence files** (stored in the Godot user data directory):
- `save.json` — score, high score, level, stats, selected topic, learning journal
- `difficulty_rl.json` — the Q-table for the adaptive difficulty model

---

## Setup and Configuration

1. **Clone or download** the project.
2. Open it in **Godot 4.5** (or later).
3. Create a `.env` file in the project root with your API keys:

```
GROQ_API_KEY=your_groq_api_key_here
SERPER_API_KEY=your_serper_api_key_here
```

- Get a free Groq API key at https://console.groq.com
- Get a Serper API key at https://serper.dev (used for web search to ground riddles in real content)

4. Press **F5** (or click Run) in Godot to start the game.

> **No API keys?** The game still works — it falls back to a set of built-in programming riddles automatically.
