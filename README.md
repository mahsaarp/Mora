# MORA : PhotoShare_Project

An **Advanced Programming** term project introducing **"PhotoShare"** — a feature-rich, socket-driven social photo platform.  
Snap your favorite moments, build curated image collections, level up your community rank, customize your app's aesthetics, and keep sharing until your storage runs out!

---

## ✨Features✨:

### 🗣️Identity, Profiles & Custom Themes🗣️:
Signing up takes just a few seconds using an **Email address** (`@gmail.com`) or a **Mobile number**. Choose a unique handle, set a strong password, and you're good to go!  

- **Account Ranks:** As you stay active by sharing pictures and dropping comments, the system automatically elevates your status from a humble **`NEWBIE`** to **`PHOTOGRAPHER`**, **`COMMENTER`**, or an elite **`INFLUENCER`**!
- **Edit Credentials:** Need a refresh? Easily edit your username or update your password directly from your profile settings.
- **Dark Mode & Color Themes:** Eyestrain at 3 AM? Switch to **Dark Mode** or pick from multiple vibrant **Color Themes** to match your personal vibe!

<p align="center">
  <img src="screenshots/splash.jpg" alt="Splash Screen" width="220"/>
  <img src="screenshots/login.jpg" alt="Login Screen" width="220"/>
  <img src="screenshots/profile.jpg" alt="Profile Screen" width="220"/>
  <img src="screenshots/edit_profile.jpg" alt="Edit Profile Screen" width="220"/>
</p>

---

### 📖Dynamic Feed, Camera & Photo Editing📖:
Unleash your creativity with a complete media uploading and discovery ecosystem!

- **Camera & Gallery Support:** Snap fresh pictures instantly using your phone's **Camera** or pick existing masterpieces straight from your **Gallery** (encoded smoothly via Base64).
- **Captions, Tags & Privacy:** Add custom captions, throw in `#hashtags`, edit post details, and toggle whether comments are **Enabled or Disabled** on your post.

<p align="center">
  <img src="screenshots/posts.jpg" alt="Posts Feed" width="300"/>
  <img src="screenshots/edit_photo.jpg" alt="Edit Photo & Captions" width="300"/>
</p>

---

### 🔍Explore & Discovery Engine🔍:
Discover trending content from creators across the platform! Filter and sort the Explore feed on the fly by **Date** (Newest/Oldest), **Name/Title**, or **Most Liked**.

<p align="center">
  <img src="screenshots/explore_photos.jpg" alt="Explore Photos" width="300"/>
  <img src="screenshots/explore_album.jpg" alt="Explore Albums" width="300"/>
</p>

---

### 💬Social Interactions & User Directory💬:
- **Interactive Comments:** Share your thoughts and engage with other creators by leaving comments under posts (unless the post owner closed comments!).
- **User Directory:** Browse the full list of community members, check out their public profiles, and see what they've been capturing.

<p align="center">
  <img src="screenshots/explore_users.jpg" alt="User Directory" width="300"/>
</p>

---

### ⚙️Custom Albums & Advanced Sorting⚙️:
Group your favorite shots into neat, thematic albums to keep your profile organized.  

- Add or remove photos from your collections without risking the original files on the server.
- **Album Sorting:** Organize your albums seamlessly based on **Album Name** (Alphabetical), **Creation Date**, or **Total Likes**.

<p align="center">
  <img src="screenshots/albums.jpg" alt="Albums View" width="300"/>
</p>

---

### 👨‍💻Admin Operations Panel👩‍💻:
Take control of community safety! Admins can inspect the full user list, view account metrics, and maintain order by **Banning toxic profiles** or **Unbanning reformed users** in real time.

<p align="center">
  <img src="screenshots/adminpanel.jpg" alt="Admin Panel" width="300"/>
</p>

> [!NOTE]
> Admin functions run through direct socket commands to monitor and manage server activity and accounts instantly.

---

## ❗❗Requirements❗❗:
- Flutter SDK (latest stable branch)
- Java Development Kit (JDK 17+)
- Mobile-capable IDE (Android Studio or VS Code)
- Android physical device or Virtual Device (AVD)

> [!NOTE]
> If newly uploaded photos or fresh comments fail to render immediately, pull down to refresh or re-launch the client app while the Java server is running.

---

## ❗ Step-by-Step Setup ❗:

1. Clone this repository to your machine.
2. Fire up the **Java Backend**:
   - Execute `BackendServer.java` to open up the TCP socket receiver.
3. Configure the **Flutter Client**:
   - Set your computer's local IP address in the app's socket configuration.
4. Run `flutter pub get` followed by `flutter run` and enjoy the platform!

---

## Credits:

Hat tip to the teams behind [Java](https://www.oracle.com/java/technologies/downloads/), [Flutter](https://flutter.dev/), and [Dart](https://dart.dev/).

Special appreciation to our instructor **Dr. Sadegh Aliakbari** for his invaluable course lectures, as well as our dedicated TA mentor team for steering us through every roadblock.
