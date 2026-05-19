# MissionApp - Implementation Plan (Flutter)

This document outlines the implementation strategy for **MissionApp**, a global missionary support platform focused on recurring donations, built with **Flutter**.

## 1. Project Setup
- **Framework:** Flutter (Stable Channel)
- **Platforms:** Web (Priority), Android, iOS.
- **State Management:** Riverpod (for dependency injection and reactive state).
- **Routing:** GoRouter (handling deep links and potentially subdomain logic for `nomedomissionario.missionapp.com`).
- **Localization:** `flutter_localizations` (handling PT-BR, EN-US, ES-CL automatically based on locale).
- **Styling:** Custom `ThemeData` based on "Green Hope", "Glassmorphism", and modern typography (Google Fonts: Inter/Roboto).

## 2. Core Architecture
Since backend APIs are not provided yet, we will implement a **Mock Repository Pattern** to simulate data fetching (missionary details, donation stats, etc.). This allows frontend development to proceed independently.

### Folders Structure
```
lib/
├── core/
│   ├── theme/          # Colors, Typography, Glassmorphism styles
│   ├── routing/        # GoRouter configuration
│   ├── localization/   # i18n setup
│   └── constants/      # Assets strings, API endpoints (mocks)
├── features/
│   ├── landing/        # Public Missionary Page
│   ├── donation/       # Donation flow & Gamification
│   ├── checkout/       # Payment Modal (Stripe Mock)
│   ├── donor/          # Donor Dashboard (Post-login)
│   └── missionary/     # Missionary Dashboard (Admin)
├── shared/             # Reusable widgets (Buttons, Cards, Loaders)
└── main.dart
```

## 3. Detailed Features

### A. Landing Page (Public View)
*   **Dynamic Content:** Loads data based on the "subdomain" (mocked via URL parameter or hardcoded initially).
*   **Hero Section:** Full-width image with gradient overlay + Circular profile picture.
*   **Trust Bar:** Icons with statistics (Years in field, lives impacted).
*   **Storytelling:** Clean text layout.
*   **Progress Bar:** Custom animated widget showing funding percentage.

### B. Donation Widget (The Heart)
*   **Floating Action:** Always visible (Bottom Sheet on Mobile, Floating Card on Desktop).
*   **Gamification:**
    *   Toggle "One-time" vs "Monthly".
    *   **Animation:** Unlocking "Seed" icon when "Monthly" is selected.
    *   **Levels:** Seed -> Cultivator -> Provider.

### C. Checkout Modal
*   **Adaptive Currency:** Detects locale (BRL, USD, CLP) and updates currency symbol calls.
*   **Stripe Mock:** Visual representation of a secure credit card form using `flutter_stripe` UI components (mock functional).

### D. Donor Dashboard
*   **Exclusive Feed:** Timeline widget for "behind the scenes" updates.
*   **Badges:** Shiny animated badges for donor levels.

### E. Missionary Dashboard
*   **Stats:** Real-time balance and "New Partner" notifications.
*   **Gratitude Tool:** One-click WhatsApp generator.

## 4. Visual Design System
*   **Colors:**
    *   Primary: "Green Hope" (Vibrant Green)
    *   Background: Light Grey / Clean White
    *   Accents: Gold/Silver (for badges)
*   **Typography:** Modern Sans-Serif (Google Fonts).
*   **Effects:**
    *   `BackdropFilter` for glassmorphism on modals/cards.
    *   `AnimatedContainer` for progress bars and button states.

## 5. Next Steps
1.  Initialize Flutter project.
2.  Set up directory structure and core packages.
3.  Implement the **Base Theme** and **Layout Skeleton**.
4.  Build the **Landing Page** with mock data.
