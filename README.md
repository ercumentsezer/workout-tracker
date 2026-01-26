# 🏋️‍♂️ Workout Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-purple?style=for-the-badge)
![Hive](https://img.shields.io/badge/Local%20DB-Hive-orange?style=for-the-badge)

**Workout Tracker** is a minimalist, distraction-free fitness tracking application built with Flutter. It is designed for serious lifters who want to focus on their training, track progressive overload, and manage their workout data efficiently without internet dependency.



## ✨ Key Features

### 👻 Ghost Data (Previous Performance)
Never forget what you lifted last week. The app displays your previous weight and rep count as "ghost text" inside the input fields, allowing you to easily aim for progressive overload.

### ⚙️ Smart Machine Settings
Stop guessing your seat height or bench angle.
- Record specific settings for each exercise (e.g., **Seat: 4**, **Angle: 30°**, **Pin: 12**).
- Custom UI picker for quick input (no typing required).

### 📋 Routine Management
- Create custom workout routines (e.g., Push, Pull, Legs).
- Edit routines, reorder exercises, and manage sets.
- Swipe-to-delete functionality for easy management.

### 💾 Offline-First & Privacy Focused
- Built with **Hive**, a lightweight and blazing fast NoSQL database.
- All data is stored locally on your device. No account or internet connection required.

### 📊 History & Analytics
- View detailed logs of past workouts.
- Edit past logs if you made a mistake.
- See total volume and consistency over time.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** [Dart](https://dart.dev/)
- **State Management:** [Flutter Riverpod](https://riverpod.dev/)
- **Local Database:** [Hive](https://docs.hivedb.dev/)
- **Unique IDs:** UUID
- **Date Formatting:** Intl

---

## 🚀 Getting Started

To run this project locally, follow these steps:

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code set up

### Installation

1. **Clone the repository**
   ```bash
   git clone [https://github.com/your-username/workout-track.git](https://github.com/your-username/workout-track.git)
   cd workout-track
