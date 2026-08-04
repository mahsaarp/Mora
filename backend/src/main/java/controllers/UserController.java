package controllers;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import database.DatabaseManager;
import model.Album;
import model.Photo;
import model.User;
import server.Response;

import java.util.ArrayList;
import java.util.List;

public class UserController {
    private static final Gson gson = new Gson();

    public static Response signup(JsonObject payload) {
        try {
            if (payload == null || !payload.has("username") || !payload.has("password")) {
                return new Response(400, "Username and password are required", null);
            }

            String username = payload.get("username").getAsString();
            String password = payload.get("password").getAsString();

            User.EnterType enterType;
            if (payload.has("enterType")) {
                enterType = User.EnterType.valueOf(payload.get("enterType").getAsString().toUpperCase());
            } else {
                enterType = username.contains("@gmail.com") ? User.EnterType.EMAIL : User.EnterType.PHONE;
            }

            User newUser = User.signUp(enterType, username, password);

            DatabaseManager.getInstance().addUser(newUser);

            JsonObject responsePayload = new JsonObject();
            responsePayload.addProperty("id", newUser.getId());
            responsePayload.addProperty("userId", newUser.getId());
            responsePayload.addProperty("username", newUser.getUsername());
            responsePayload.addProperty("rank", newUser.getRank().toString());
            responsePayload.addProperty("enterType", newUser.getEnterType().toString());

            return new Response(200, "Signup successful", responsePayload);

        } catch (IllegalArgumentException e) {
            return new Response(400, e.getMessage(), null);
        } catch (Exception e) {
            return new Response(500, "Server error: " + e.getMessage(), null);
        }
    }

    public static Response login(JsonObject payload) {
        try {
            if (payload == null || !payload.has("username") || !payload.has("password")) {
                return new Response(400, "Username and password are required", null);
            }

            String username = payload.get("username").getAsString();
            String password = payload.get("password").getAsString();

            User user = User.login(username, password);

            DatabaseManager.getInstance().saveDatabase();

            JsonObject responsePayload = new JsonObject();
            responsePayload.addProperty("id", user.getId());
            responsePayload.addProperty("userId", user.getId());
            responsePayload.addProperty("username", user.getUsername());
            responsePayload.addProperty("rank", user.getRank().toString());
            responsePayload.addProperty("isLoggedIn", user.isLoggedIn());

            return new Response(200, "Login successful", responsePayload);

        } catch (IllegalArgumentException e) {
            return new Response(401, "Invalid username or password", null);
        } catch (IllegalStateException e) {
            return new Response(403, "User account is banned", null);
        } catch (Exception e) {
            return new Response(500, "Server error: " + e.getMessage(), null);
        }
    }

    public static Response logout(JsonObject payload) {
        try {
            if (payload == null || (!payload.has("id") && !payload.has("userId"))) {
                return new Response(400, "User ID is required", null);
            }

            int userId = payload.has("userId") ? payload.get("userId").getAsInt() : payload.get("id").getAsInt();
            User user = DatabaseManager.getInstance().getUser(userId);

            if (user != null) {
                User.logout(user);
                DatabaseManager.getInstance().saveDatabase();

                return new Response(200, "Logged out successfully", null);
            } else {
                return new Response(404, "User not found", null);
            }
        } catch (Exception e) {
            return new Response(500, "Server error", null);
        }
    }

    public static Response getUserProfile(JsonObject payload) {
        try {
            if (payload == null) {
                return new Response(400, "Payload is required", null);
            }

            User user = null;
            if (payload.has("userId")) {
                user = DatabaseManager.getInstance().getUser(payload.get("userId").getAsInt());
            } else if (payload.has("targetUser")) {
                try {
                    user = DatabaseManager.getInstance().getUser(payload.get("targetUser").getAsInt());
                } catch (Exception ignored) {
                    String username = payload.get("targetUser").getAsString();
                    for (User u : DatabaseManager.getInstance().getAllUsers().values()) {
                        if (u.getUsername().equals(username)) {
                            user = u;
                            break;
                        }
                    }
                }
            } else if (payload.has("username")) {
                String username = payload.get("username").getAsString();
                for (User u : DatabaseManager.getInstance().getAllUsers().values()) {
                    if (u.getUsername().equals(username)) {
                        user = u;
                        break;
                    }
                }
            }

            if (user == null) {
                return new Response(404, "User not found", null);
            }

            JsonObject responsePayload = new JsonObject();
            responsePayload.addProperty("id", user.getId());
            responsePayload.addProperty("userId", user.getId());
            responsePayload.addProperty("username", user.getUsername());
            responsePayload.addProperty("rank", user.getRank() != null ? user.getRank().toString() : "");

            List<Photo> userPhotos = new ArrayList<>();
            for (int photoId : user.getPhotoIds()) {
                Photo p = DatabaseManager.getInstance().getPhoto(photoId);
                if (p != null) userPhotos.add(p);
            }

            List<Album> userAlbums = new ArrayList<>();
            for (int albumId : user.getAlbumIds()) {
                Album a = DatabaseManager.getInstance().getAlbum(albumId);
                if (a != null) userAlbums.add(a);
            }

            responsePayload.add("photos", gson.toJsonTree(userPhotos));
            responsePayload.add("albums", gson.toJsonTree(userAlbums));

            return new Response(200, "OK", responsePayload);

        } catch (Exception e) {
            return new Response(500, "Server error: " + e.getMessage(), null);
        }
    }
}