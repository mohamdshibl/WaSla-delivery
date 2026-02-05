# 🚀 Wasla (وصلة) - On-Demand Delivery Reimagined

Wasla is a premium, world-class on-demand delivery application built with Flutter. It bridges the gap between customers and providers with a focus on speed, reliability, and a state-of-the-art user experience.

![Premium UI](https://raw.githubusercontent.com/mohamdshibl/WaSla-delivery/main/assets/banner_mockup.png) <!-- Placeholder for actual asset if available -->

---

## ✨ Key Features

### 👤 Dual-User Experience
- **Customer Side**: Effortless order placement with free-text descriptions and photo support. Real-time tracking and direct chat with delivery heroes.
- **Provider Side**: A powerful order feed to browse, accept, and manage deliveries. Real-time status updates and specialized order history.

### 🌍 Fully Localized (EN/AR)
- Native support for **English** and **Arabic**.
- Real-time language toggling from the Profile screen.
- Comprehensive **RTL (Right-to-Left)** layout support for a seamless Arabic experience.

### 💎 World-Class UI/UX
- **Modern Aesthetics**: Sleek dark mode, vibrant gradients, and glassmorphism effects.
- **Micro-animations**: Smooth transitions and interactive elements for a "WOW" factor.
- **Haptic Feedback**: Meaningful tactile responses integrated across all core interactions.
- **Custom Branding**: Features the unique `WaslaLogo` with its signature "W" to "L" kinetic arrow design.

### 💬 Real-Time Communication
- Integrated customer-provider chat system for instant coordination and updates.

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Material 3)
- **Architecture**: **Clean Architecture** (Domain, Data, Presentation layers)
- **State Management**: [Riverpod](https://riverpod.dev/) (Performance-first state handling)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore, Firebase Storage)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing)
- **Localization**: `flutter_localizations` & `intl` (Robust i18n support)

---

## 📂 Project Structure

```text
lib/
├── core/               # Shared constants, widgets, and utilities
├── features/           # Feature-based design (Clean Architecture)
│   ├── auth/           # Login, Register, Profile, Role-base logic
│   ├── home/           # Dashboard and Feed logic
│   ├── orders/         # Creation, Editing, and Management
│   └── chat/           # Real-time message exchange
└── l10n/               # Translation files and generated code
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Firebase Project configured for Android/iOS/Web

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mohamdshibl/WaSla-delivery.git
   cd wasla
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Localization Files**:
   ```bash
   flutter gen-l10n
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🛡️ License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Developed with ❤️ for the next generation of delivery services.
