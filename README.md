# Nationwide Visas - Your Path to Global Citizenship 🌎

Empowering your dreams of immigrating to Canada, Australia, and Germany with expert guidance and a premium mobile experience. Built with Flutter, this application provides a seamless journey from onboarding to visa discovery.

## ✨ Key Features

-   **Interactive Onboarding**: A beautiful, fluid start to the user journey that introduces the Nationwide Visas mission.
-   **Modular Authentication**: Secure, step-based authentication system featuring:
    -   Phone number validation.
    -   Automated OTP verification.
    -   Smart account detection (Login vs. Register).
-   **Profile Intelligence**: Personalized onboarding flow that gathers study levels and start dates to tailor immigration paths.
-   **Premium Home Dashboard**: An "Edvoy-inspired" UI featuring:
    -   **Dynamic Header**: Gradient-rich search and notification center.
    -   **Services Carousel**: Discover Study, Work, Invest, and Settle programs.
    -   **Popular Destinations**: Quick access to Canada, Australia, and Germany specific content.
    -   **Trending Programs**: Real-time listings for PNPs, Spouse PR, and Opportunity Cards.

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/) (Material 3)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative, scalable routing.
-   **State Management**: [Provider](https://pub.dev/packages/provider) for efficient reactive data binding.
-   **Typography**: [Google Fonts (Poppins)](https://fonts.google.com/specimen/Poppins) for a modern, sleek feel.
-   **Architecture**: Modular Feature-based Architecture for high maintainability.

## 📂 Directory Structure

```text
lib/
├── core/               # App configuration, theme (AppColors), and routing
├── features/
│   ├── auth/           # Authentication UI, ViewModels, and logic
│   ├── onboarding/     # Onboarding screens and widgets
│   └── home/           # Main dashboard and service discovery
└── assets/             # Logos, illustrations, and images
```

## 🚀 Getting Started

### Prerequisites
-   Flutter SDK installed.
-   An IDE like VS Code or Android Studio.

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/medhavi-cmyk/nationwide_visa.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

---
*Built with ❤️ for a seamless immigration experience.*
