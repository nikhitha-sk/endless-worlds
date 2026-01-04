# FEATURE

## Project Summary

**Endless Worlds** is an educational 2D top-down exploration game built in **Godot** that combines environmental gameplay with AI-powered learning. Players navigate a procedurally-generated island world while solving AI-generated riddles and programming-focused educational challenges. The game leverages the **Groq API (LLM integration)** to dynamically create context-specific riddles about user-selected topics like programming, mathematics, or other subjects.

The core gameplay loop involves exploring a tile-based world with varied terrain (grass, dirt, clay, water, lava), collecting hint pickups scattered across the map, and answering riddles to progress through levels. The game features a complete day–night cycle that dynamically adjusts world lighting and spawns decorative elements like flowers and trees.

Environmental immersion includes weather systems (rain with parallax effects), water mechanics where players can wade and sink visually, and interactive NPCs like wells that provide context.

Score and progression tracking motivate players through a level-based system with high score persistence. The educational component is deeply integrated—every interaction reinforces learning through gamification. The project emphasizes visual polish with proper depth sorting, sprite animations, particle effects, and responsive controls supporting both keyboard and gamepad input.

---

## Feature List

### Core Gameplay
- **2D Top-Down Exploration:** Free-roaming player movement across procedurally-generated islands  
- **Procedural World Generation:** Simplex noise-based terrain with connected islands, water borders, and varied biomes  
- **Tile-Based World:** Multiple terrain types (grass, dirt, clay, mud, sand, lava, magma, water)  
- **Character Movement:** Walking/sprinting with dynamic speed adjustments  
- **Water Physics:** Depth-based visual sinking, movement slowdown in water, splash particle effects  

---

### Educational & AI Features
- **AI-Generated Riddles:** Integration with Groq LLM API for dynamic, context-aware riddle generation  
- **Topic Selection:** User-selectable learning topics (default: programming)  
- **Progressive Difficulty:** Level-based progression system tied to riddle solutions  
- **Hint System:** Collectible hint pickups scattered on the map to aid riddle solving  
- **Fallback Riddles:** 6 pre-written programming riddles as LLM fallback  
- **Answer Validation:** Case-insensitive answer checking with immediate feedback  

---

### Environment & Atmosphere
- **Day-Night Cycle:** Dynamic time progression with color transitions between day/night states  
- **Dynamic Lighting:** Automatic lighting adjustments at dawn, day, dusk, and night  
- **Weather System:** Rain particle effects with parallax (far/near layers) and intensity transitions  
- **Decorative Spawners:**  
  - Random flower placement on grass tiles with varied textures and rotations  
  - Tree spawning system  
- **Depth Sorting:** Foot-based Z-indexing for proper sprite layering without performance lag  

---

### Player Progression
- **Score System:** Dynamic scoring with answer bonuses (50 points per riddle)  
- **Level Progression:** Level advancement on correct answers  
- **High Score Tracking:** Persistent high score across sessions  
- **Home Screen:** Main menu with score display, high score, current level, and topic input  

---

### Interactive Elements
- **Interactive Well:** NPC-like structures in the world  
- **Hint Pickups:** Collectable items with minimum spacing to prevent clustering  
- **Answer Popup UI:** Focused input interface for riddle answers with submit/close functionality  

---

### Controls & Input
- **Keyboard Support:** WASD for movement, arrow keys as fallback  
- **Gamepad Support:** D-pad and analog stick compatible  
- **Sprint Mechanic:** Shift key for speed boost  
- **Virtual Joystick:** On-screen UI joystick for mobile/touch compatibility  

---

### Visual Polish
- **Animated Sprites:** Frame-based character animations for directional movement  
- **Sprite Tinting:** Color modulation in water with depth-based blue tinting  
- **Particle Effects:** Water bubbles, rain, weather visuals  
- **UI Polish:** Custom fonts (Jersey10, Noto Color Emoji), opacity controls  
- **Parallax Effects:** Multi-layer rain rendering for depth perception  

---

### Technical Features
- **Environment File Loading:** `.env` file support for API key management  
- **HTTP Requests:** Async LLM API calls via `HTTPRequest` nodes  
- **Global Autoload:** Persistent game state management via Global singleton  
- **Modular Architecture:** Separate scripts for systems (time, weather, spawning, player physics)  
- **Scene Management:** Proper scene transitions (Home → Map → Home loop)  

---

## ADDITIONAL FEATURES

### 1. Concept Card UI
- After solving:
  - Show concept name  
  - Short explanation  
  - Real-world example  
- Save it in **Learning Journal**

### 2. Learning Journal
Add a **Learning Journal UI** that stores everything learned.

**What it contains:**
- Solved riddles  
- Learned concepts  
- Definitions  
- Diagrams (later)  

---

### 3. Wrong Answer Feedback
- Show why it’s wrong  
- Give guided hint  

---

### 4. Hint Challenges
- Timed riddles  
- Logical puzzles  
- Pattern recognition  

---

### 5. Learning Stats System
Replace normal XP with **Learning Stats**.

Each solved riddle:
- `+2 Logic`
- `+1 Memory`

This makes learning measurable.

---

### 6. Daily Learning Quests
- “Riddle of the Day”  
- “Concept of the Day”  

---

### 7. Accessibility
Features that make the project stand out academically:
- Simple language mode  
- Audio hints (text-to-speech later)  
- Highlight keywords  
- Difficulty slider  

---

### 8. Personalization
Collect player data:
- Time to solve  
- Hints used  
- Wrong attempts  
- Areas explored  

Use it to adjust:
- Riddle difficulty  
- Number of hints  
- Time limits  
- Topics to be focused on  

---

### 9. Computer Vision
*(Planned feature)*

---

### 10. Leaderboard
Global and/or local leaderboard system
