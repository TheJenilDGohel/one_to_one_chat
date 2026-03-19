# One-to-One Chat Application

A real-time messaging platform built with Flutter and Firebase, implementing Clean Architecture and hybrid state management (Redux + BLoC).

## Technical Overview

This application is designed with modularity and scalability as core priorities. It strictly adheres to Clean Architecture principles to ensure complete separation of concerns between business logic, data persistence, and UI presentation.

### Architectural Layers

*   **Domain Layer**: Contains enterprise-level business entities and use cases. This layer is independent of any external frameworks or libraries.
*   **Data Layer**: Handles data retrieval and persistence. Implements repository interfaces defined in the domain layer using Firebase Firestore and Authentication.
*   **Presentation Layer**: Manages UI state and rendering. Utilizes the Business Logic Component (BLoC) pattern for screen-level state and Flutter Redux for global application state (e.g., identity and session management).

## Core Functionality

*   **Asynchronous Messaging**: Real-time communication via Firestore streams.
*   **Session Management**: Secure authentication and persistent user sessions via Firebase Auth.
*   **Message Status Tracking**: Real-time read receipts and unread message counters.
*   **Presence System**: Real-time tracking of user online/offline status and last seen timestamps.
*   **Optimized Performance**: Efficient list rendering and state updates to minimize rebuilds.

## Technology Stack

*   **Frontend**: Flutter / Dart
*   **Backend**: Cloud Firestore, Firebase Authentication
*   **State Management**: flutter_redux, rxdart (BLoC)
*   **Dependency Injection**: get_it
*   **Logging**: snug_logger (Debug-only)
*   **Typography**: Inter (Google Fonts)

## Project Directory Structure

```text
lib/
├── core/               # Shared theme, constants, and global assets.
├── domain/             # Core business logic (Entities, UseCases, Repository interfaces).
├── data/               # Infrastructure (Models, Repository implementations, DataSources).
├── presentation/       # UI layer (Screens, Widgets, BLoCs).
├── redux/              # Global state management (Store, Actions, Reducers).
├── utils/              # Helper functions (Validators, Formatters).
├── injection.dart      # Service locator initialization.
└── main.dart           # Application entry point.
```

## Setup and Installation

### Prerequisites
*   Flutter SDK (Stable channel recommended)
*   Active Firebase Project
*   `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)

### Execution
1.  Initialize dependencies:
    ```bash
    flutter pub get
    ```
2.  Launch application:
    ```bash
    flutter run
    ```

## Development and Attribution
Developed by **Jenil Gohel**. Focus on SOLID principles and clean code.
