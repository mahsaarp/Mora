# MORA

<p align="center">
  <strong>Photo sharing, discovery, and organization — built for a seamless mobile experience.</strong>
</p>

<p align="center">
  <a href="#features">Features</a>
  &nbsp;·&nbsp;
  <a href="#screenshots">Screenshots</a>
  &nbsp;·&nbsp;
  <a href="#technology">Technology</a>
  &nbsp;·&nbsp;
  <a href="#getting-started">Getting Started</a>
</p>

---

## About

**MORA** is a photo-sharing and album management application developed for the **Advanced Programming** course.

Built with **Flutter** and **Java**, MORA combines photo management, album organization, search and discovery, social interactions, account customization, and administrative controls in a single mobile application.

The client and server communicate through a custom **TCP Socket** layer using **JSON** for data exchange.

---

## Features

### Authentication & Profiles

* User registration and login
* Profile and account management
* Username and password editing
* Profile picture selection from camera or gallery
* Account logout and deletion

### Photo Management

* Upload photos from gallery or camera
* Add titles, captions, and tags
* Assign photos to albums
* Edit published photos
* Enable or disable comments
* Like and comment on photos
* Share photos
* Save photos to the device gallery

### Explore & Discovery

* Browse photos, albums, and users
* Search by photo name or tag
* Sort available content
* Explore user profiles and public albums

### Albums

* Create custom albums
* Add and remove photos
* Organize photos across multiple collections
* Browse album contents

### Personalization

* Light and dark modes
* Multiple color themes
* Account and application settings

### Administration

* Admin dashboard
* User management
* User statistics
* Ban and unban controls

---

## Screenshots

### Authentication

<p align="center">
  <img src="screenshots/splash.jpg" alt="Splash Screen" width="220"/>
  <img src="screenshots/login.jpg" alt="Login" width="220"/>
  <img src="screenshots/sign_up.jpg" alt="Sign Up" width="220"/>
</p>

### Profile & Account Management

<p align="center">
  <img src="screenshots/profile_photos.jpg" alt="Profile" width="220"/>
  <img src="screenshots/edit_profile.jpg" alt="Edit Profile" width="220"/>
</p>

### Photo Details & Interaction

<p align="center">
  <img src="screenshots/photo_detail.jpg" alt="Photo Details" width="220"/>
  <img src="screenshots/save_to_gallery.jpg" alt="Save Photo to Gallery" width="220"/>
  <img src="screenshots/comments_off.jpg" alt="Comments Disabled" width="220"/>
</p>

### Photo Publishing & Editing

<p align="center">
  <img src="screenshots/choose.jpg" alt="Choose Photo" width="220"/>
  <img src="screenshots/post.jpg" alt="Create Post" width="220"/>
  <img src="screenshots/edit_photo.jpg" alt="Edit Photo" width="220"/>
</p>

### Explore & Discovery

<p align="center">
  <img src="screenshots/explore_photos.jpg" alt="Explore Photos" width="220"/>
  <img src="screenshots/explore_albums.jpg" alt="Explore Albums" width="220"/>
  <img src="screenshots/explore_users.jpg" alt="Explore Users" width="220"/>
</p>

<p align="center">
  <img src="screenshots/search.jpg" alt="Search" width="220"/>
  <img src="screenshots/sort.jpg" alt="Sort Options" width="220"/>
</p>

### Albums

<p align="center">
  <img src="screenshots/profile_albums.jpg" alt="Profile Albums" width="220"/>
</p>

### Personalization & Settings

<p align="center">
  <img src="screenshots/light_mode.jpg" alt="Light Mode" width="220"/>
  <img src="screenshots/dark_mode.jpg" alt="Dark Mode" width="220"/>
  <img src="screenshots/blue_theme.jpg" alt="Blue Theme" width="220"/>
</p>

### Administration

<p align="center">
  <img src="screenshots/admin_dashboard.jpg" alt="Admin Dashboard" width="300"/>
</p>

---

## Technology

| Layer              | Technology |
| ------------------ | ---------- |
| Mobile Application | Flutter    |
| Frontend           | Dart       |
| Backend            | Java 17    |
| Communication      | TCP Socket |
| Data Exchange      | JSON       |
| JSON Processing    | Gson       |

---

## Client–Server Communication

MORA uses a custom TCP Socket communication layer between the Flutter client and Java backend.

Requests and responses are exchanged as JSON messages, allowing the application to handle authentication, photo management, albums, user operations, and other interactions through a unified communication channel.

The backend supports concurrent client connections and processes requests independently.

```text
Flutter Application
        |
        | JSON over TCP
        v
   Java Backend
        |
   +----+----+
   |         |
   v         v
Data Logic  File Management
```

---

## Requirements

* Flutter SDK
* Dart SDK
* Java Development Kit 17+
* Android Studio or Visual Studio Code
* Android Emulator or physical Android device

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd MORA
```

### 2. Start the backend

Run the Java backend and make sure the server is active before launching the mobile application.

### 3. Configure the connection

Set the backend machine's local IP address in the Flutter socket configuration.

For physical devices and emulators, ensure that the client can reach the machine running the backend.

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Run the application

```bash
flutter run
```

---

## Academic Context

MORA was developed as part of the **Advanced Programming** course, with a focus on applying software engineering and object-oriented programming concepts to a complete client-server application.

The project covers:

* Object-oriented programming
* Client-server architecture
* TCP socket communication
* JSON-based data exchange
* CRUD operations
* Persistent data management
* File handling
* Concurrent server processing
* Mobile application development with Flutter

---

## Credits

**Course:** Advanced Programming
**Instructor:** Dr. Sadegh Aliakbari

**Built with Flutter, Dart, Java, TCP Sockets, and JSON.**
