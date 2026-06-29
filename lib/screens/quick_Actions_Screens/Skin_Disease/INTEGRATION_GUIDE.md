# DrugSure — Skin Disease AI Checker — Integration Guide

## Kya banaya gaya hai

4 naye Dart files jo Skin Disease detection feature add karte hain DrugSure me:

| File | Kaam |
|------|------|
| `lib/services/skin_analysis_service.dart` | Gemini AI ko call karta hai — image bhejke disease name, cause, remedies wapas leta hai |
| `lib/services/skin_history_service.dart` | Firestore + Storage me result save/fetch karta hai |
| `lib/screens/skin_checker_screen.dart` | Main screen — photo upload + analyze button + result display |
| `lib/screens/skin_history_screen.dart` | Past analyses ki history list (optional but recommended) |

---

## STEP 1 — Free Gemini API Key lo (2 minute ka kaam)

1. Jao: **https://aistudio.google.com/app/apikey**
2. Google account se sign in karo (credit card NAHI chahiye)
3. **"Create API Key"** click karo
4. Key copy karo (kuch is jaisi dikhegi: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXX`)

**Free limits:** ~10-15 requests/minute, sufficient daily quota — college project/personal app ke liye zyada se zyada hai.

⚠️ Important: Free tier me Google tumhare prompts model training ke liye use kar sakta hai. Production app ke liye baad me billing enable karna better hoga, but abhi testing/project ke liye free tier perfect hai.

---

## STEP 2 — `pubspec.yaml` me dependencies add karo

Apne existing `pubspec.yaml` ke `dependencies:` section me ye add karo (agar already nahi hai):

```yaml
dependencies:
  http: ^1.2.0                    # Gemini API call karne ke liye
  image_picker: ^1.1.2            # Camera/Gallery se image lene ke liye
  cached_network_image: ^3.4.1    # History screen me image dikhane ke liye
  # cloud_firestore, firebase_storage, firebase_auth -> already hain tumhare
  # DrugSure project me (admin dashboard wagera me use ho rahe hain)
```

Phir terminal me:
```bash
flutter pub get
```

---

## STEP 3 — Naye files ko apne project me daalo

```
your_drugsure_project/
└── lib/
    ├── services/
    │   ├── skin_analysis_service.dart    ← YE FILE YAHA DAALO
    │   └── skin_history_service.dart     ← YE FILE YAHA DAALO
    └── screens/
        ├── skin_checker_screen.dart      ← YE FILE YAHA DAALO
        └── skin_history_screen.dart      ← YE FILE YAHA DAALO
```

Agar tumhara `services/` ya `screens/` folder ka naam different hai (jaise `models/` ya kuch aur structure), to imports adjust karna padega in dono files me:
```dart
import '../services/skin_analysis_service.dart';
import '../services/skin_history_service.dart';
```

---

## STEP 4 — API key paste karo

`lib/services/skin_analysis_service.dart` file kholo, ye line dhoondo:

```dart
static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Apni Step 1 wali key yaha paste karo:
```dart
static const String _geminiApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

⚠️ **Security note (important for IEEE paper / production discussion):**
Hardcoding API key directly in code theek hai testing/college project ke liye, but agar app Play Store pe publish karna hai to:
- API key ko `.env` file me rakho with `flutter_dotenv` package, ya
- Better: Firebase Cloud Function banao jo backend se Gemini ko call kare, taaki key kabhi client app me expose na ho.

Abhi ke liye direct approach se shuru karo, baad me migrate kar sakte ho.

---

## STEP 5 — Navigation me add karo

Tumhara DrugSure me jaise Health Risk Assessment module ko home/drawer me add kiya tha, waise hi:

**Agar Bottom Navigation use kar rahe ho** (`main_navigation.dart` ya jo bhi file hai):
```dart
import 'screens/skin_checker_screen.dart';

// Apni existing list/array me ek naya item add karo:
const SkinCheckerScreen(),
```

**Agar Drawer/Home Grid se navigate karte ho:**
```dart
ListTile(
  leading: const Icon(Icons.healing),
  title: const Text('Skin Health Checker'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SkinCheckerScreen()),
    );
  },
),
```

History screen ko SkinCheckerScreen ke AppBar me ek icon button se link kar sakte ho:
```dart
appBar: AppBar(
  title: const Text('Skin Health Checker'),
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SkinHistoryScreen()),
      ),
    ),
  ],
),
```
(Ye `skin_checker_screen.dart` ke `AppBar(...)` part me already-existing code ke saath manually merge karna hoga.)

---

## STEP 6 — Android/iOS permissions (Camera + Gallery)

### Android — `android/app/src/main/AndroidManifest.xml`
`<manifest>` tag ke andar, `<application>` tag se BAHAR ye lines add karo (agar already nahi hain):

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### iOS — `ios/Runner/Info.plist`
`<dict>` ke andar ye add karo:

```xml
<key>NSCameraUsageDescription</key>
<string>DrugSure needs camera access to analyze skin photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DrugSure needs photo library access to select skin photos</string>
```

---

## STEP 7 — Firestore Security Rules update

Apne existing `firestore.rules` me ye add karo (taaki har user sirf apna data dekh/likh sake):

```
match /users/{userId}/skin_analyses/{analysisId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## STEP 8 — Test karo

1. `flutter run`
2. Skin Checker screen kholo
3. Camera ya Gallery se koi bhi skin photo upload karo
4. "Analyze Skin" tap karo
5. 3-5 second me result aana chahiye: condition name, cause, remedies, severity

**Agar error aaye:**
- `"API key not set"` → Step 4 dobara check karo
- `429 error` → free tier limit hit hua, 1 minute wait karke try karo
- `400 error` → API key galat hai, AI Studio se dobara copy karo

---

## Important Honest Note (for your project report/viva)

Gemini ek **general-purpose multimodal model** hai, specifically trained dermatology model nahi (jaise hospital-grade systems). Isliye:
- Accuracy clinical-grade nahi hai — academic/awareness tool ke roop me present karo, diagnostic tool nahi.
- UI me disclaimer already add kiya hai ("AI-based estimate only...").
- IEEE paper ya viva me ye honestly mention karna — "leverages a general-purpose vision-language model (Gemini) for accessible preliminary skin condition awareness, not intended to replace dermatological diagnosis" — strong aur honest framing hai, evaluators isko appreciate karte hain.

---

## Quick Summary of Changes

| File/Location | Change |
|---|---|
| `pubspec.yaml` | Add `http`, `image_picker`, `cached_network_image` |
| `lib/services/` | Add 2 new files |
| `lib/screens/` | Add 2 new files |
| `skin_analysis_service.dart` line ~50 | Paste your Gemini API key |
| Navigation file | Add route/button to `SkinCheckerScreen` |
| `AndroidManifest.xml` | Add camera + storage permissions |
| `Info.plist` | Add camera + photo library usage descriptions |
| `firestore.rules` | Add rule for `skin_analyses` subcollection |
