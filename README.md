<div align="center">

# ⛅ Weather Pro App

**A professional, feature-rich Flutter application delivering real-time weather,  
detailed forecasts, and air quality data — wrapped in a premium UI experience.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-Academic-green?style=for-the-badge)

</div>

---

## 👨‍💻 Developer

| Field | Details |
|---|---|
| **Name** | Muhammad Talha |
| **Registration No.** | SP23-BCS-086 |
| **Assignment** | Assignment 4 — Mobile Application Development |

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 📍 **Auto-Location Detection** | GPS-based city detection fetches local weather automatically on launch |
| 🌡️ **Real-Time Weather** | Current temperature, humidity, wind speed, and "feels like" data |
| 🎨 **Dynamic Backgrounds** | App background shifts with conditions — sunny, rainy, cloudy, and more |
| 🎞️ **Lottie Animations** | Beautifully animated weather icons for an immersive visual experience |
| 📈 **Hourly Temperature Chart** | FL Chart-powered line graph showing 24-hour temperature trends |
| 📅 **5-Day Forecast** | Extended daily weather predictions for the week ahead |
| 🌿 **Air Quality Index (AQI)** | Live AQI monitoring with health recommendations |
| 🔍 **Search History** | Remembers recently searched cities for quick access |
| 🔄 **Unit Switching** | Instantly toggle between Celsius (°C) and Fahrenheit (°F) |
| ⚡ **Shimmer Loading** | Premium skeleton loading effect while data is being fetched |

---

## 📸 Screenshots

<div align="center">
<img src="https://github.com/user-attachments/assets/9e22bc65-ea17-4d68-a7d8-bdf9ae6c6180" width="180"/>
<img src="https://github.com/user-attachments/assets/e476a97a-d97e-404d-8a7b-30b92869be4b" width="180"/>
<img src="https://github.com/user-attachments/assets/847ee71b-7feb-4061-8442-d6897c4b6a1c" width="180"/>
<img src="https://github.com/user-attachments/assets/07c34d9b-f991-4409-80db-fd5d5961da69" width="180"/>
<img src="https://github.com/user-attachments/assets/ebba0cab-23f4-4164-88e5-46f45341ef94" width="180"/>
<img src="https://github.com/user-attachments/assets/b1c8a266-dd86-4bcd-ab63-e7ab707e1452" width="180"/>
<img src="https://github.com/user-attachments/assets/8998f0ce-5497-4b52-a8b7-a1016cf42451" width="180"/>
<img src="https://github.com/user-attachments/assets/c5691bdc-6174-4964-89c1-d102ee67f8d8" width="180"/>
<img src="https://github.com/user-attachments/assets/ba394aaa-ef9f-4135-8495-9a942c0d11c6" width="180"/>
</div>

---

## 🛠️ Tech Stack

| Category | Library / Tool |
|---|---|
| **State Management** | [Flutter Riverpod](https://riverpod.dev/) |
| **Networking** | `http` package |
| **Location** | Geolocator & Geocoding |
| **Local Storage** | Shared Preferences |
| **Charts** | FL Chart |
| **Animations** | Lottie |
| **Icons** | Font Awesome & Material Icons |
| **Typography** | Google Fonts — Poppins |
| **UI Effects** | Shimmer |

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code with Flutter plugin

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/your-username/weather_pro_app.git
cd weather_pro_app
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate app icons**
```bash
flutter pub run flutter_launcher_icons
```

**4. Run the app**
```bash
flutter run
```

> **Note:** Make sure a device or emulator is running before executing `flutter run`.

---

## 🔑 Permissions Required

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

| Permission | Purpose |
|---|---|
| `ACCESS_FINE_LOCATION` | Precise GPS coordinates for automatic city detection |
| `ACCESS_COARSE_LOCATION` | Approximate network-based location as fallback |
| `INTERNET` | Fetching weather data from the OpenWeatherMap API |

---

## 📁 Project Structure

```
weather_pro_app/
├── lib/
│   ├── main.dart
│   ├── models/          # Data models (weather, forecast, AQI)
│   ├── providers/       # Riverpod state providers
│   ├── screens/         # App screens & pages
│   ├── services/        # API service layer
│   └── widgets/         # Reusable UI components
├── assets/
│   └── animations/      # Lottie animation files
├── android/
│   └── app/src/main/AndroidManifest.xml
└── pubspec.yaml
```

---

<div align="center">

Developed by **Muhammad Talha** · SP23-BCS-086  
*Submitted as academic coursework — Mobile Application Development*

</div>
