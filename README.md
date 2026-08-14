# MORA

<p align="center">
  <strong>A modern photo-sharing and album management application built with Flutter and Java.</strong>
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

**MORA** is a full-featured photo-sharing application developed for the **Advanced Programming** course.

The application combines a Flutter mobile client with a Java backend connected through a custom **TCP Socket** communication layer. MORA provides users with a unified space to upload, organize, discover, and share photos while managing profiles, albums, interactions, and application preferences.

---

## ✨ Features

### Authentication & Profiles

* User registration and login
* Profile and account management
* Username and password editing
* Profile picture selection from the camera or gallery
* Account logout and deletion
* User photo and album overview

### Photo Sharing & Management

* Select photos from the device gallery
* Capture photos using the camera
* Add titles, captions, and tags
* Assign photos to albums
* Edit published photos
* Enable or disable comments on individual posts
* Like and comment on photos
* Share photos with other applications
* Save photos directly to the device gallery

### Explore, Search & Discovery

* Browse photos, albums, and users
* Search photos by name or tag
* Sort available content
* Explore user profiles
* Browse public album collections

### Albums

* Create custom albums
* Add photos to albums
* Organize photos into multiple collections
* Browse album contents
* View albums associated with user profiles

### Personalization

* Light mode
* Dark mode
* Multiple color themes
* Account management settings

### Administration

* Admin dashboard
* User management
* User statistics
* Ban and unban controls

---

## 📱 Screenshots

### Authentication

<p align="center">
  <img src="screenshots/splash.jpg" alt="Splash Screen" width="220"/>
  <img src="screenshots/login.jpg" alt="Login" width="220"/>
  <img src="screenshots/sign_up.jpg" alt="Sign Up" width="220"/>
</p>

### Explore

<p align="center">
  <img src="screenshots/explore_photos.jpg" alt="Explore Photos" width="220"/>
  <img src="screenshots/explore_albums.jpg" alt="Explore Albums" width="220"/>
  <img src="screenshots/explore_users.jpg" alt="Explore Users" width="220"/>
</p>

### Profile & Account Management

<p align="center">
  <img src="screenshots/profile_photos.jpg" alt="Profile" width="220"/>
  <img src="screenshots/edit_profile.jpg" alt="Edit Profile" width="220"/>
</p>

### Personalization & Settings

<p align="center">
  <img src="screenshots/light_mode.jpg" alt="Light Mode and Theme Settings" width="220"/>
  <img src="screenshots/dark_mode.jpg" alt="Dark Mode" width="220"/>
  <img src="screenshots/blue_theme.jpg" alt="Color Theme" width="220"/>
</p>

### Discovery

<p align="center">
  <img src="screenshots/search.jpg" alt="Search" width="220"/>
  <img src="screenshots/sort.jpg" alt="Sort Options" width="220"/>
</p>

### Photo Details & Interaction

<p align="center">
  <img src="screenshots/photo_detail.jpg" alt="Photo Details" width="220"/>
</p>

### Photo Publishing

<p align="center">
  <img src="screenshots/choose.jpg" alt="Choose Photo from Gallery" width="220"/>
  <img src="screenshots/post.jpg" alt="Create New Post" width="220"/>
</p>

### Photo Editing

<p align="center">
  <img src="screenshots/edit_photo.jpg" alt="Edit Photo" width="220"/>
  <img src="screenshots/comments_off.jpg" alt="Comments Disabled" width="220"/>
</p>

### Administration

<p align="center">
  <img src="screenshots/admin_dashboard.jpg" alt="Admin Dashboard" width="300"/>
</p>

---

## 🛠️ Technology

| Layer              | Technology |
| ------------------ | ---------- |
| Mobile Application | Flutter    |
| Frontend Language  | Dart       |
| Backend            | Java       |
| Communication      | TCP Socket |
| Data Exchange      | JSON       |
| JSON Processing    | Gson       |

MORA uses a custom socket-based communication layer between the Flutter client and Java backend rather than a conventional REST API.

---

## 🔗 Client–Server Communication

The Flutter client communicates directly with the Java server through a custom TCP Socket connection.

Requests and responses are exchanged as JSON messages, allowing the application to handle authentication, photo management, album operations, and user-related actions through a unified communication layer.

The backend supports multiple client connections concurrently.

```text
Flutter Application
        |
        |  JSON over TCP
        v
   Java Backend
        |
   +----+----+
   |         |
   v         v
Data Logic  File Management
```

---

## ⚙️ Requirements

* Flutter SDK
* Dart SDK
* Java Development Kit (JDK 17 or newer)
* Android Studio or Visual Studio Code
* Android Emulator or a physical Android device

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/mahsaarp/Mora.git
cd Mora
```

### 2. Start the Backend

Launch the Java backend and make sure the server is running before starting the mobile application.

### 3. Configure the Connection

Set the backend machine's local IP address in the Flutter application's socket configuration.

When using a physical device or an emulator, make sure it can communicate with the machine running the Java server.

### 4. Install Flutter Dependencies

```bash
flutter pub get
```

### 5. Run the Application

```bash
flutter run
```

---

## 🎓 Academic Context

MORA was developed as part of the **Advanced Programming** course, with a focus on applying core programming and software engineering concepts to a complete client-server application.

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

## 👥 Credits

**Course:** Advanced Programming

**Instructor:** Dr. Sadegh Aliakbari

**Contributors:** Mahsadat Ahmadi, Sara Jafari

