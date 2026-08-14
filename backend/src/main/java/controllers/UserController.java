package controllers;

import com.google.gson.*;
import database.DatabaseManager;
import model.Admin;
import model.Album;
import model.Photo;
import model.User;
import server.Response;

import java.io.File;
import java.io.FileOutputStream;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

public class UserController {
    private static final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime localDateTime, Type type, JsonSerializationContext jsonSerializationContext) {
                    return new JsonPrimitive(localDateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                }
            })
            .registerTypeAdapter(LocalDateTime.class, new JsonDeserializer<LocalDateTime>() {
                @Override
                public LocalDateTime deserialize(JsonElement jsonElement, Type type, JsonDeserializationContext jsonDeserializationContext) throws JsonParseException {
                    return LocalDateTime.parse(jsonElement.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                }
            })
            .create();

    public static Response signup(JsonObject payload) {
        try {
            if (payload == null || !payload.has("username") || !payload.has("password")) {
                return new Response(400, "Username and password are required", null);
            }

            String username = payload.get("username").getAsString();
            String password = payload.get("password").getAsString();

            User.EnterType enterType = User.detectEnterType(username);
            User newUser = User.signUp(enterType, username, password);

            DatabaseManager.getInstance().addUser(newUser);
            DatabaseManager.getInstance().saveDatabase();

            JsonObject resp = new JsonObject();
            resp.addProperty("id", newUser.getId());
            resp.addProperty("userId", newUser.getId());
            resp.addProperty("username", newUser.getUsername());
            resp.addProperty("rank", newUser.getRank().name());

            return new Response(200, "Signup successful", resp);
        } catch (IllegalArgumentException e) {
            return new Response(400, e.getMessage(), null);
        } catch (Exception e) {
            return new Response(500, "Server error: " + e.getMessage(), null);
        }
    }

    public static Response login(JsonObject payload) {
        try {
            String username = payload.get("username").getAsString();
            String password = payload.get("password").getAsString();

            if (Admin.checkPassword(password)) {
                JsonObject resp = new JsonObject();
                resp.addProperty("id", -1);
                resp.addProperty("userId", -1);
                resp.addProperty("username", username);
                resp.addProperty("rank", "ADMIN");
                resp.addProperty("isAdmin", true);
                resp.addProperty("themeMode", "light");
                resp.addProperty("themeColor", "blue");
                return new Response(200, "Admin login successful", resp);
            }

            User user = User.login(username, password);
            DatabaseManager.getInstance().saveDatabase();

            JsonObject resp = new JsonObject();
            resp.addProperty("id", user.getId());
            resp.addProperty("userId", user.getId());
            resp.addProperty("username", user.getUsername());
            resp.addProperty("avatarRoute", user.getAvatarRoute());
            resp.addProperty("rank", user.getRank().name());
            resp.addProperty("isAdmin", user.getRank() == User.UserRank.ADMIN);
            resp.addProperty("themeMode", user.getThemeMode());
            resp.addProperty("themeColor", user.getThemeColor());

            return new Response(200, "Login successful", resp);
        } catch (IllegalStateException e) {
            if ("User is banned".equals(e.getMessage())) {
                return new Response(401, "Your account has been banned by admin", null);
            }
            return new Response(401, e.getMessage(), null);
        } catch (Exception e) {
            return new Response(401, e.getMessage(), null);
        }
    }

    public static Response logout(JsonObject payload) {
        User user = findUser(payload);
        if (user != null) {
            user.logout();
            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Logged out", null);
        }
        return new Response(404, "User not found", null);
    }

    public static Response deleteAccount(JsonObject payload) {
        User user = findUser(payload);
        if (user != null) {
            User.deleteAccount(user);
            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Account deleted", null);
        }
        return new Response(404, "User not found", null);
    }

    public static Response updateSettings(JsonObject payload) {
        User user = findUser(payload);
        if (user == null) return new Response(404, "User not found", null);

        if (payload.has("themeMode")) user.setThemeMode(payload.get("themeMode").getAsString());
        if (payload.has("themeColor")) user.setThemeColor(payload.get("themeColor").getAsString());

        DatabaseManager.getInstance().saveDatabase();
        return new Response(200, "Settings updated", null);
    }

    public static Response updateProfile(JsonObject payload) {
        try {
            User user = null;
            if (payload.has("oldUsername")) {
                String oldUsername = payload.get("oldUsername").getAsString();
                user = User.getUsers().values().stream()
                        .filter(u -> u.getUsername().equals(oldUsername))
                        .findFirst().orElse(null);
            } else {
                user = findUser(payload);
            }

            if (user == null) return new Response(404, "User not found", null);

            if (payload.has("newUsername")) {
                user.changeUsername(payload.get("newUsername").getAsString());
            }
            if (payload.has("newPassword")) {
                user.changePassword(payload.get("newPassword").getAsString());
            }
            if (payload.has("avatarData")) {
                JsonElement avatarDataElem = payload.get("avatarData");
                if (avatarDataElem.isJsonNull() || avatarDataElem.getAsString().isEmpty()) {
                    user.setAvatarRoute(null);
                } else {
                    String avatarData = avatarDataElem.getAsString();
                    try {
                        String base64Image = avatarData;
                        if (avatarData.contains(",")) {
                            base64Image = avatarData.split(",")[1];
                        }
                        byte[] imageBytes = Base64.getDecoder().decode(base64Image);

                        String directoryPath = "uploads" + File.separator + "avatars";
                        File directory = new File(directoryPath);
                        if (!directory.exists()) {
                            directory.mkdirs();
                        }

                        String fileName = "user_" + user.getId() + ".jpg";
                        String relativePath = "uploads/avatars/" + fileName;
                        File file = new File(directory, fileName);

                        try (FileOutputStream fos = new FileOutputStream(file)) {
                            fos.write(imageBytes);
                        }

                        user.setAvatarRoute(relativePath);
                    } catch (Exception e) {
                        user.setAvatarRoute(avatarData);
                    }
                }
            }

            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Profile updated", null);
        } catch (Exception e) {
            return new Response(400, e.getMessage(), null);
        }
    }

    public static Response getUserProfile(JsonObject payload) {
        User user = findUser(payload);
        if (user == null) return new Response(404, "User not found", null);

        JsonObject resp = new JsonObject();
        resp.addProperty("id", user.getId());
        resp.addProperty("username", user.getUsername());
        resp.addProperty("avatarRoute", user.getAvatarRoute());
        resp.addProperty("rank", user.getRank().name());
        resp.addProperty("themeMode", user.getThemeMode());
        resp.addProperty("themeColor", user.getThemeColor());
        resp.addProperty("isBanned", user.isBanned());

        List<Photo> photos = new ArrayList<>();
        for (int pid : user.getPhotoIds()) {
            Photo p = DatabaseManager.getInstance().getPhoto(pid);
            if (p != null) photos.add(p);
        }
        resp.add("photos", gson.toJsonTree(photos));

        List<Album> albums = new ArrayList<>();
        for (int aid : user.getAlbumIds()) {
            Album a = DatabaseManager.getInstance().getAlbum(aid);
            if (a != null) albums.add(a);
        }
        resp.add("albums", gson.toJsonTree(albums));

        return new Response(200, "OK", resp);
    }

    public static Response getAllUsers() {
        try {
            List<User> users = new ArrayList<>(DatabaseManager.getInstance().getAllUsers().values());
            JsonArray array = new JsonArray();
            for (User user : users) {
                JsonObject obj = new JsonObject();
                obj.addProperty("id", user.getId());
                obj.addProperty("username", user.getUsername());
                obj.addProperty("avatarRoute", user.getAvatarRoute());
                obj.addProperty("rank", user.getRank().name());
                obj.addProperty("isBanned", user.isBanned());
                obj.addProperty("photoCount", user.getPhotoIds().size());
                obj.addProperty("albumCount", user.getAlbumIds().size());
                array.add(obj);
            }
            return new Response(200, "OK", array);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response banUser(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            User user = DatabaseManager.getInstance().getUser(userId);
            if (user == null) return new Response(404, "User not found", null);
            user.ban();
            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "User banned", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response unbanUser(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            User user = DatabaseManager.getInstance().getUser(userId);
            if (user == null) return new Response(404, "User not found", null);
            user.unban();
            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "User unbanned", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    private static User findUser(JsonObject payload) {
        if (payload == null) return null;
        if (payload.has("userId")) return DatabaseManager.getInstance().getUser(payload.get("userId").getAsInt());
        if (payload.has("username")) {
            String uname = payload.get("username").getAsString();
            return User.getUsers().values().stream().filter(u -> u.getUsername().equals(uname)).findFirst().orElse(null);
        }
        return null;
    }
}
