# 🚀 Cosmo Clash

**Cosmo Clash** is a fast‑paced **2D space shooter game** built with **UIKit** for iOS.

The project focuses on **classic arcade gameplay**, responsive touch controls, and visually rich space environments. It is intentionally designed **without MVVM**, using a more direct and game‑oriented architecture that prioritizes performance and simplicity.

---

## 🌌 Game Overview

* 🎮 **Arcade-style Space Shooter**
* 🛸 Player-controlled spaceship
* ☄️ Enemy waves and projectiles
* ⭐ Level-based progression & scoring system

Players control their ship by **touch & drag** to move and **tap to shoot**, aiming to survive waves of enemies and achieve the highest score possible.

---

## ✨ Features

### 🚀 Core Gameplay

* Smooth **touch & drag movement**
* Tap-based shooting mechanics
* Real-time collision detection
* Increasing difficulty over time

### ❤️ Player Stats

* **Health system** (lives)
* **Shield system** for temporary protection
* Visual HUD indicators for instant feedback

### 🧮 Scoring & Progress

* Real-time **score tracking**
* **High score** display on main menu
* Level completion screen with:

  * Star rating
  * Score summary
  * Completion time

### 🧩 Levels

* Clear **level start** and **level completed** states
* Performance-based star system
* Replay and next-level options

---

## 🖥 UI & Visual Design

* Space-themed background with depth
* Sci‑fi inspired UI panels and buttons
* Neon HUD elements for score, time, and stats
* Clean separation between gameplay and overlays

The visuals are designed to feel **arcade‑like**, immersive, and energetic without overwhelming the player.

---

## 🛠 Tech Stack

* **Platform:** iOS
* **Language:** Swift
* **Framework:** UIKit
* **Game Logic:** Custom game loop
* **Architecture:** Scene‑driven / Controller‑based (non‑MVVM)
* **Rendering:** UIImageView & CALayer based elements

> This project intentionally avoids MVVM to better suit real‑time gameplay logic.

---

## 🧠 Architectural Notes

* Game logic handled directly in **ViewControllers**
* Clear separation between:

  * Game state
  * Player state
  * UI overlays (HUD, menus)
  
* Optimized for **real-time interaction** rather than data flow abstraction

This structure keeps the code **straightforward, debuggable, and performant** for a 2D arcade game.

---

## 📷 Screens Included

* Main menu with high score display
* Active gameplay screen
* Level completion summary screen

---

## 🔮 Possible Improvements

* Power-ups & special weapons
* Boss fights
* Sound effects & background music
* Difficulty modes
* Game Center integration

---

## 📄 License

MIT License

---

## 👤 Author

**Emirhan Çitgez**

iOS Developer
