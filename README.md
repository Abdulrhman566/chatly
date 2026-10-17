# 💬 Chatly — Flutter Chat App

**Chatly** is a real-time, one-to-one messaging application built with Flutter and Firebase. It allows users to create accounts, discover other registered users, and exchange messages instantly through a clean and simple chat interface.

تطبيق **Chatly** هو تطبيق شات بين مستخدمين في الوقت الفعلي، مبني باستخدام Flutter و Firebase، بيوفر تسجيل الحسابات، عرض المستخدمين، وإجراء محادثات خاصة بسهولة.

## ✨ Features

- 🔐 **Authentication** — Sign up and log in using email and password.
- 👥 **Users List** — View registered users while hiding your own account.
- 💬 **Private Messaging** — Chat privately with another registered user.
- ⚡ **Real-Time Updates** — Receive messages instantly using Cloud Firestore.
- 🗨️ **Message Bubbles** — Blue bubbles for sent messages and grey bubbles for received messages.
- 🕒 **Message Timestamps** — Display the time of each message.
- 🚪 **Logout** — Sign out from the users screen.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI development |
| Dart | Application programming language |
| Firebase Authentication | User registration and login |
| Cloud Firestore | Real-time users and messages storage |
| StreamBuilder | Listen to live Firestore updates |

## 📂 Project Structure

```text
lib/
├── main.dart
├── pages/
│   ├── auth/
│   │   └── auth_screen.dart
│   ├── user_screen.dart
│   └── chat_screen.dart
└── service/
    └── chat_service.dart
```

## 🔄 How Chatly Works

### 1. Authentication

Chatly uses Firebase Authentication to register users and sign in with email and password. Every user has a unique Firebase UID.

### 2. Private Chat Rooms

Chatly creates a consistent room ID by sorting the two users' UIDs and joining them:

```dart
final ids = [myUid, otherUid]..sort();
final roomId = ids.join('_');
```

Sorting ensures both users access the same conversation, regardless of who starts the chat.

### 3. Firestore Data Structure

```text
users/{uid}
  ├── uid: String
  └── email: String

chats/{roomId}/messages/{messageId}
  ├── senderId: String
  ├── senderEmail: String
  ├── reciverId: String
  ├── text: String
  └── timestamp: Timestamp
```

### 4. Real-Time Messaging

Chatly uses Cloud Firestore streams and Flutter's `StreamBuilder` to listen for new messages and update the chat interface automatically without manual refreshing.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A [Firebase project](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)

### Installation

**1. Clone the repository**

```bash
git clone <your-repo-url>
cd <project-folder>
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure Firebase**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**4. Enable Email/Password Authentication**

In the Firebase Console, go to **Authentication → Sign-in method** and enable **Email/Password**.

**5. Set up Cloud Firestore**

Create a Firestore database in the Firebase Console and configure appropriate security rules for users and chat participants.

**6. Run Chatly**

```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core:
  firebase_auth:
  cloud_firestore:
```

Use compatible package versions in your `pubspec.yaml`.

## 🐛 Troubleshooting

| Issue | Solution |
|---|---|
| `permission-denied` | Verify Firebase Authentication and Firestore security rules. |
| Empty users list | Ensure at least two users are registered and have documents in Firestore. |
| Messages not updating | Check the chat room ID and Firestore stream path. |
| `ChatScreen` parameter error | Match the constructor parameters with those passed from `UserScreen`. |
| Firebase initialization error | Verify Firebase configuration for your target platform. |

## 🔮 Future Improvements

- 🔔 Unread message counters
- 🖼️ Image sharing
- 📲 Push notifications with Firebase Cloud Messaging
- 🟢 Online/offline status
- ✍️ Typing indicators
- ✔️ Message read receipts
- 🔍 Search users

## 👨‍💻 Author

**Abdelrahman Ayman Ragab Anani**

Built with ❤️ using Flutter and Firebase.

---

⭐ If you like Chatly, consider giving the repository a star!