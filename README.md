# Mushin

Mushin is an innovative mobile app designed to help users improve their focus and productivity. It locks chosen apps on the device and allows access only after completing a task that promotes well-being. The app's main features include:

- **App Locking**: Prevents access to selected apps by locking them.
- **Greenery Verification**: Unlocks apps only after the user submits a picture of greenery, promoting a calming and focused environment.
- **Timer Functionality**: Allows users to set a timer, enabling app access after a specific duration.
- **Accessibility Features**: Built using Kotlin for advanced accessibility features that can detect and close the app if it is found in shared preferences.

## Features

- **App Lock**: Lock any app chosen by the user, ensuring that distractions are kept at bay.
- **Greenery Verification**: Users must submit a picture of greenery, such as plants or trees, to verify that they have engaged with nature before accessing the app.
- **Timer Lock**: Users can specify a timer to allow app access after a predefined period.
- **Shared Preferences Integration**: The app keeps track of locked apps using shared preferences, providing a smooth and user-friendly experience.

## How It Works

1. **Locking Apps**: The user selects an app to lock through the app's UI. The app will monitor the chosen app and close it if it's accessed.
2. **Greenery Submission**: To unlock the app, the user must submit a photo of greenery. The photo is verified using an image recognition model to ensure it matches the expected criteria (greenery).
3. **Timer Functionality**: Users can set a timer for automatic unlocking after a defined time period.
4. **Accessibility Features**: Implemented using Kotlin, the app leverages Android's accessibility services to detect when the chosen app is on top of the screen and automatically close it. This ensures the locked app cannot be accessed until the user performs the required tasks.

## Installation

### Requirements

- Flutter 3.x or higher
- Android device with Kotlin support
- Android Studio or Visual Studio Code

### Steps to Install

1. Clone the repository:
   ```bash
   git clone https://github.com/Achiket123/mushin
    #Navigate to the project directory:
   cd mushin
   #Install dependencies:
   flutter pub get
   #Run the app on an Android device or emulator:
   flutter run

### Permissions
System Alert Window: Required to display the lock screen and monitor the top app.

Package Usage Stats: Used to monitor which apps are being used and lock/unlock them accordingly.

Internet: Needed for any potential online features or future integrations.

### Technologies Used
Flutter: For building the cross-platform user interface.

Kotlin: For implementing Android-specific features like accessibility services and app monitoring.

Shared Preferences: To save user settings and manage locked apps.

Image Recognition (Optional): Used for greenery verification to enhance user experience.

## Contributing
We welcome contributions to improve the app! If you'd like to contribute, please fork the repository and submit a pull request with your changes. Make sure to follow the coding standards and write tests for any new features.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

For any questions, issues, or feature requests, please feel free to open an issue.
