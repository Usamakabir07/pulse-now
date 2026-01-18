# 📱 PulseNow — Flutter App

PulseNow is a Flutter mobile application that displays crypto market data in a clean, responsive dashboard. The app follows a structured architecture using **Provider** for state management and separates concerns into models, services, providers, and UI screens for maintainability and scalability.

---

## 📂 Project Structure

The Flutter project is organized using a feature-based, layered architecture:

```text
lib/
├── main.dart                 # App entry point, theme setup, and providers
├── utils/
│   └── constants.dart      # App-wide constants (API URLs, endpoints, colors)
│
├── models/                 # Data models
│   ├── market_data_model.dart
│   ├── analytics_model.dart
│   └── portfolio_model.dart
│
├── services/              # External services and utilities
│   ├── api_service.dart        # REST API integration
│   └── analytics_tracker.dart # App analytics and logging
│
├── providers/            # State management (Provider)
│   ├── market_data_provider.dart
│   ├── analytics_provider.dart
│   └── portfolio_provider.dart
│
├── screens/              # UI screens
│   ├── home_screen.dart
│   ├── market_data_screen.dart
│   ├── market_detail_screen.dart
│   ├── analytics_screen.dart
│   └── portfolio_screen.dart
│
└── widgets/             # Reusable UI components (optional / extendable)



---

## 🧠 Architecture Overview

The app follows a clean and scalable architecture:

- **Models** define the shape of data used throughout the app.
- **Services** handle external interactions such as API calls and analytics logging.
- **Providers** manage application state and business logic using the Provider package.
- **Screens** build the UI and react to state changes via Consumers.

This structure ensures:
- Clear separation of concerns
- Testable business logic
- Maintainable and extensible codebase

---

## ✨ App Overview

PulseNow presents crypto market information in an intuitive interface that includes:

- A market view displaying symbols, prices, and daily changes
- A detail screen for individual assets
- An analytics dashboard showing high-level market insights
- A portfolio view summarizing asset performance
- Support for light and dark themes
- Clean Material Design UI with responsive layouts

---
