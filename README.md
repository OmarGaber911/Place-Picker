# Place Picker and Shortest Path

## Overview
This Flutter application allows users to pick locations on a map and find the shortest path between two specified locations. It uses Flutter's flutter_map package for map rendering and marker management, and includes functionality for geocoding and pathfinding.
## Features
-Map Display: View a map with markers for the start and end locations.

-Shortest Path Calculation: Calculate and display the shortest path between two locations.

-Location Picker: Enter locations to see them on the map.
## Getting Started
### Prerequisites
-Flutter SDK
-Dart SDK
-An IDE such as Android Studio or Visual Studio Code
## Installation
1- Clone the repository:
```bash
git clone https://github.com/your-username/your-repo-name.git

```
2-Navigate to the project directory:
```bash
cd your-repo-name

```
3-Install dependencies:
```bash
flutter pub get

```
## Usage
1-Run the Application
```bash
flutter run

```
2-interacting with the App:

-Enter the start and end locations in the text fields.
-Click the search icon to find the shortest path.
-The map will show markers for both locations and a polyline representing the shortest path.
## Dependencies

```bash

dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^3.1.0
  latlong2: ^0.8.1
  http: ^0.15.0

```
## Contributing 
1-Fork the repository.
2-Create a new branch (git checkout -b feature-branch).
3-Commit your changes (git commit -am 'Add new feature').
4-Push the branch (git push origin feature-branch).
5-Create a Pull Request on GitHub.
    
