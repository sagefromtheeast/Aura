# Design.md — Aura: The Intelligent Music Companion

*Last updated: 2026-05-14*

## Overview

Aura is the “Everything App” for local music — a privacy‑first, emotionally intelligent, cross‑platform player that merges the best of iOS’s liquid glass aesthetic with Android’s Material Design 3 dynamic color system. It feels alive, personal, and deeply polished, as if the music itself is breathing inside the device.

**Core experience pillars:**
- **Warm intelligence** — the app learns your taste, never judges, and surfaces music like an old friend
- **Frictionless control** — thumb‑zone ergonomics, 8‑pt grid precision, every interaction intentional
- **Emotional resonance** — celebrate listening milestones, deliver delightful micro‑interactions, and wrap every session with closure

---

## Design Philosophy

We design for the **peak‑end rule**:
- The *peak* is the Now Playing screen — a luminous, depth‑rich canvas where album art takes center stage, surrounded by soft glass controls.
- The *end* is the daily summary card — a gentle “here’s what you loved today” moment that makes the user feel seen.

All visual decisions follow the **60/30/10 color rule**, the **8‑point spacing grid**, and strict typographic hierarchy. Every screen exists in one of three states: **empty / idle, active, and celebratory**.

---

## Color System — Liquid Warmth

The palette adapts dynamically to album art and time of day (Material You dynamic color on Android, custom fluid gradient on iOS). Base system:

| Role | Color | Usage |
|------|-------|-------|
| **Background** | `#FBF9F6` (Light) / `#0F0D0A` (Dark) | 60% surface |
| **Surface** | Semi‑transparent white / black with `backdrop-filter: blur(40px)` | Cards, sheets |
| **Primary** | Accent derived from currently playing album art or user‑chosen seed (e.g., warm apricot `#FF8F6D`) | 10% — buttons, active indicators, highlights |
| **Secondary** | Primary at 5‑10% opacity | Subtle card accents, dividers |
| **Text** | Base `#1A1410` (Light) / `#F0EBE4` (Dark) at 100% / 80% / 60% opacity | Hierarchy |
| **Shadow** | Tinted shadows matching background hue (never pure black/gray) | Elevation |

---

## Typography

- **Primary font:** SF Pro (iOS) / Google Sans Text (Android) — both geometric, friendly, and highly readable.
- **Monospace variant:** `JetBrains Mono` for large statistics, timestamps, and metadata.
- **Sizing scale (4 sizes max):**
  - `Headline`: 28sp / 34px, weight 700
  - `Title`: 22sp / 28px, weight 600
  - `Body`: 16sp / 20px, weight 400
  - `Caption`: 12sp / 16px, weight 400
- **Hierarchy:** Use size + weight + opacity, never more than two weights in a single view.

---

## Spacing & Grid

All spacing based on an **8‑point system**:
- **Card padding:** 24px internal, 32px external gap
- **Section vertical rhythm:** 96px padding between major blocks
- **Relationship spacing:** 16px between title and its body, 32px to next group
- **Touch targets:** minimum 48×48px (accessibility)

---

## iOS & Android Fusion — The “Liquid Material” Language

**iOS Liquid Glass details:**
- Frosted glass effect (`backdrop-blur-xl`, semi‑transparent backgrounds) on Now Playing, bottom sheets, and overlays.
- Depth created by subtle white inner shadows and soft tinted drop shadows.
- Fluid spring animations (iOS spring curve) on transitions.

**Android Material Design 3 (latest, 2026):**
- Dynamic color (`MaterialDynamicColors`) extracts palette from wallpaper/album art — our app uses the same engine for cross‑platform harmony.
- Large corner radii (`rounded-3xl` = 24px, `rounded-4xl` = 32px) on cards and dialogs.
- Smooth motion easing (standard decelerate) and container transform for shared‑element transitions.

**Unified approach:**
- Navigation: Bottom tab bar with pill‑shaped active indicator (iOS feel) using dynamic color (Android).
- Lists: Full‑bleed translucent cards with 16px rounded corners and subtle glass effect.
- Buttons: Pill‑shaped, primary color fill with 2px white inner shadow and soft drop shadow.

---

## Component Library (Tone‑Setting)

### Primary Button
- `rounded-full`, `py-14px px-24px`, primary color, text `Title/600/white`, inner shadow `inset 0 1px 0 rgba(255,255,255,0.2)`, drop shadow `0 8px 24px -6px {primary}40`

### Secondary Button
- `rounded-full`, `border-1.5 border-primary/20`, background `primary/5`, text `primary`

### Mini‑Player (collapsed)
- Frosted glass pill, 64px height, floating above tab bar, contains small album art thumbnail, track title, play/pause, and a subtle waveform animation.

### Now Playing Screen
- Full‑bleed blurred album art background with `blur-3xl` and a `linear‑gradient` overlay (black 10% → 60%).
- Central: large album art with soft‑glow shadow (primary color) and subtle rotation animation.
- Controls: arranged in thumb zone, 48px spacing, glass effect.

### Library Cards
- Horizontal list: pill‑shaped chips for genres/moods; album/artist cards with 24px rounded corners, soft tinted shadow.

### Statistics Card
- Frosted glass, large monospace number, subtle gradient accent line.

---

## Human‑Computer Interaction Principles Applied

- **Thumb zone mapping:** primary actions (play, skip, playlists) always in the bottom 1/3.
- **F‑pattern reading:** Library screens list items left‑aligned, with important metadata stacked vertically.
- **Progressive disclosure:** Onboarding gradually reveals features based on user type selection (casual, power, audiophile).
- **Error prevention:** Duplicate‑check feedback, confirmation dialogs, undo toast.
- **Delightful feedback:** Haptic‑coupled animations, subtle sparkle on like/favorite, celebratory confetti on milestone.