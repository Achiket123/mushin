# 🌿 Mushin

**Mushin** is a productivity-focused mobile application that promotes digital wellness by controlling access to distracting apps. To unlock a selected app, users must either submit a picture of **greenery** (to promote mindfulness) or wait for a **preset timer** to expire.

This project combines **Flutter** for the frontend with **Kotlin** for native Android functionality, particularly leveraging **Accessibility Services** to monitor and block selected apps in real time.

---

## 🔒 Key Features

- ✅ **App Locking**: Block access to specific apps using accessibility services.
- 🌿 **Greenery Verification**: Unlock the app only after submitting an image of nature (verified via AI using Gemini API).
- ⏱️ **Timer Unlocking**: Set a countdown timer after which the locked app is unlocked automatically.
- 📲 **Native Android Integration**: Kotlin code handles app monitoring and detection via accessibility features.
- 💾 **Persistent Locking**: Locked apps are stored using shared preferences.
- 🔐 **Secure Image Recognition**: Uses Gemini API for verifying submitted greenery images.

---

## 🧠 How It Works

1. **App Selection**: Users choose which apps to lock.
2. **Lock Enforcement**: When a locked app is launched, Mushin intercepts it via accessibility services and redirects to a custom lock screen.
3. **Unlock Options**:
   - **Greenery Submission**: Upload a photo containing greenery.
   - **Timer**: Wait until the countdown expires.
4. **AI Verification**: The submitted image is processed using **Google’s Gemini API** to verify it contains greenery before unlocking the app.

---

## ⚙️ Installation Guide

### 📋 Prerequisites

- Flutter SDK (3.x or above)
- Android Studio or VS Code
- Android device (API level 21+)
- [Google Gemini API Key](https://makersuite.google.com/app/apikey)

### 📁 Clone and Setup

```bash
git clone git@github.com:Achiket123/mushin.git
cd mushin
flutter pub get
```
## 🔐 Set Up .env File
To use Gemini API for image verification, create a .env file in the root of your project:
```.env
API_KEY=your_gemini_api_key_here
```

🔐 Android Permissions Required
Add these permissions to your AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```
## 📲 Usage
Launch the app and select which apps you want to lock.

Choose your unlock method (Timer / Greenery Image).

If a locked app is accessed, the LockScreenActivity (built in Kotlin) will intercept and enforce your chosen restriction.

Submit a greenery image — it will be processed via the Gemini API to detect nature elements and validate unlock access.

## 🧪 Technologies Used
 
Flutter	: UI/UX Frontend Development

Kotlin	: Android-specific logic & Accessibility

Gemini API :	AI-powered greenery image verification
SharedPreferences :	Local app lock data persistence


# 📤 Contributing

We welcome contributors to improve Mushin! 🚀

Fork this repository.

Create your feature branch:

```bash
Copy
Edit
git checkout -b feature/YourFeatureName
Commit your changes:
```
```bash
Copy
Edit
git commit -am "Add a new feature"
Push and create a PR:
```
```bash
Copy
Edit
git push origin feature/YourFeatureName
Please ensure your changes are well-tested and follow the existing code style.
```
## 📝 License
This project is licensed under the MIT License.
See the LICENSE file for details.

