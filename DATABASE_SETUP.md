# RentEase Database Setup Guide

## Option 1: Firebase Firestore (RECOMMENDED)
Firebase is the best option for Flutter apps - real-time sync, scalable, and easy to integrate.

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Create a new project"
3. Name it "RentEase" and click Continue
4. Enable Google Analytics (optional)
5. Click Create Project
6. Wait for project to be created

### Step 2: Create Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create Database**
3. Select **Start in test mode** (for development)
4. Choose region closest to you (e.g., asia-southeast1)
5. Click **Create**

### Step 3: Add Firebase to Flutter App
1. Install Firebase CLI: https://firebase.google.com/docs/cli
2. In your project root, run:
```bash
firebase login
firebase init
```
3. Select:
   - Firestore
   - Android
   - iOS
4. Choose your Firebase project

### Step 4: Add Flutter Firebase Packages
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.15.0
```

Then run:
```bash
flutter pub get
```

### Step 5: Initialize Firebase in main.dart
Update your `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## Option 2: SQLite (Local Only)
For local-only database without internet.

### Step 1: Add Package
Add to `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

### Step 2: Create Database Helper
See `lib/database/db_helper.dart` (will be created)

---

## Option 3: Supabase (Firebase Alternative)
Similar to Firebase but open-source and self-hosted option.

### Step 1: Create Supabase Project
1. Go to https://supabase.com
2. Click "New Project"
3. Fill in details and create

### Step 2: Add Supabase Package
```yaml
dependencies:
  supabase_flutter: ^1.10.0
```

---

## My Recommendation: Firebase Firestore

**Why Firebase?**
- ✅ Real-time synchronization
- ✅ Built-in authentication
- ✅ Scalable and reliable
- ✅ Easy integration with Flutter
- ✅ Free tier generous (1GB storage, 50K reads/day)
- ✅ Perfect for landlord-tenant connections

---

## Next Steps:
1. Choose your database option (Firebase recommended)
2. Follow the setup steps above
3. I will then modify your providers to use the database
4. Your data will be automatically synced to the cloud

**Which option would you like?** Reply with:
- "firebase" - Cloud Firestore (Recommended)
- "sqlite" - Local database
- "supabase" - Firebase alternative
