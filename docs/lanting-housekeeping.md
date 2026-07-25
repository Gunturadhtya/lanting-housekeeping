# Game Design Document: Lanting Housekeeping

## 1. Executive Summary

* **Game Title:** Lanting Housekeeping
* **Engine:** Godot
* **Platform:** Android
* **Genre:** Tower Defense, Roguelike Deck-builder, Strategy
* **Target Audience:** Gamers aged 10–40 who enjoy deck-building, strategy, and tower defense mechanics
* **Game Mode:** Single-player
* **Core Inspiration:** *Slay the Spire* and *Clash Royale*

---

## 2. High Concept & Narrative

### High Concept

Navigate a traditional Kalimantan floating house (*rumah lanting*) upriver to find the source of river pollution, defending it from living trash monsters and mutated creatures using a deck of customizable boat units and utility items.

### Narrative Background

Climate change has caused river levels to rise in South Kalimantan, while an irresponsible corporate entity dumps toxic industrial waste near the riverhead. A young local resident utilizes *rumah lanting* technology to journey upriver, deploying recycled local boats (*jukung* and *kelotok*) to fend off mutant trash monsters. Defeated trash is salvaged for energy to craft new defenses, heal units, and push toward the pollution source.

---

## 3. Core Gameplay & Mechanics

### Gameplay Overview

Players travel along a branching map from the downstream river mouth to the upstream source. Each node on the map represents an encounter (Combat, Workshop/Bengkel, Floating Market/Pasar Terapung, Treasure, or Random Events).

```md
[Downstream Start] ─> (Combat/Events/Markets) ─> [Upstream Final Boss]
```

### Combat Structure

Combat is turn-phased around enemy waves moving from the top of the screen toward the *rumah lanting* at the bottom.

#### Preparation Phase (Pre-Wave)

* Players draw **Unit Cards** (towers).
* Place, relocate, or recall units to defend lanes.

#### Action Phase (Mid-Wave)

* Enemy waves spawn and move downward.
* Unit relocation is locked.
* Defeated enemies drop **Scraps** (Energy/Recycled Trash).
* Players spend Scraps to play **Item Cards** in real time.

### Card Types & Roles

#### Unit Cards (Towers)

* **Striker:** Single-target high damage.
* **AoE:** Splash damage for swarms.
* **Wall:** High health, blocks enemy progress.

#### Item Cards (Utilities)

* **Heal/Repair:** Restores health to active units or the base.
* **Direct Damage:** Environmental or explosive strikes on trash monsters.
* **Crowd Control:** Slows down incoming monster progression.

---

## 4. Progression & Loop

```md
Map Navigation ─> Combat Phase ─> Collect Scraps & Card Rewards ─> Deck Building / Upgrades ─> Boss Encounter

```

### Map Nodes

* **Battle Node:** Wave-based defense encounters.
* **Floating Market (Pasar Terapung):** Shop node to buy/remove cards and items.
* **Workshop (Bengkel):** Rest site to repair the *rumah lanting* or upgrade cards.
* **Chest & Events:** Rewards, risk/reward choices, and lore encounters.

### Win/Loss Conditions

* **Victory:** Clear all enemy waves in a battle. Select 1 of 3 random item cards to expand the deck.
* **Defeat:** The *rumah lanting* HP reaches zero. The run ends, requiring a restart.

---

## 5. Technology Stack & Development Resources

| Category | Tool / Resource | Purpose |
| --- | --- | --- |
| **Engine** | Godot Engine | Free & Open-Source (FOSS) core framework |
| **Language** | GDScript | Native Godot scripting |
| **Visual Art** | Aseprite | Pixel art assets, animations, and UI elements |
| **Audio Tools** | Audacity & BandLab | Sound effect editing, composition, and audio mixing |
| **Hardware** | PC & Android Devices | PC for primary development; Android devices for mobile testing |

---
