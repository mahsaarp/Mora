package controllers;

import com.google.gson.*;
import database.DatabaseManager;
import model.*;
import server.Response;

import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class PhotoController {
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

    public static JsonObject photoToJson(Photo photo) {
        JsonObject json = gson.toJsonTree(photo).getAsJsonObject();

        User owner = DatabaseManager.getInstance().getUser(photo.getOwnerId());
        if (owner != null) {
            json.addProperty("username", owner.getUsername());
            json.addProperty("displayName", owner.getDisplayName());
            json.addProperty("avatarRoute", owner.getAvatarRoute() != null ? owner.getAvatarRoute() : "");
            json.addProperty("avatar_url", owner.getAvatarRoute() != null ? owner.getAvatarRoute() : "");
            json.addProperty("userAvatar", owner.getAvatarRoute() != null ? owner.getAvatarRoute() : "");
        } else {
            json.addProperty("username", "Unknown");
            json.addProperty("displayName", "Unknown");
            json.addProperty("avatarRoute", "");
            json.addProperty("avatar_url", "");
            json.addProperty("userAvatar", "");
        }

        JsonArray commentsArray = new JsonArray();
        List<Comment> comments = photo.getComments();
        if (comments != null) {
            for (Comment comment : comments) {
                JsonObject commentJson = gson.toJsonTree(comment).getAsJsonObject();
                User commenter = DatabaseManager.getInstance().getUser(comment.getOwnerId());
                if (commenter != null) {
                    commentJson.addProperty("username", commenter.getUsername());
                    commentJson.addProperty("displayName", commenter.getDisplayName());
                    commentJson.addProperty("avatarRoute", commenter.getAvatarRoute() != null ? commenter.getAvatarRoute() : "");
                    commentJson.addProperty("avatar_url", commenter.getAvatarRoute() != null ? commenter.getAvatarRoute() : "");
                } else {
                    commentJson.addProperty("username", "User");
                    commentJson.addProperty("displayName", "User");
                    commentJson.addProperty("avatarRoute", "");
                    commentJson.addProperty("avatar_url", "");
                }
                commentsArray.add(commentJson);
            }
        }
        json.add("comments", commentsArray);

        return json;
    }

    public static Response uploadPhoto(JsonObject payload) {
        try {
            User user = null;

            if (payload.has("username") && !payload.get("username").isJsonNull()) {
                String username = payload.get("username").getAsString();
                user = User.getUsers().values().stream()
                        .filter(u -> u.getUsername().equals(username))
                        .findFirst()
                        .orElse(null);
            }

            if (user == null && payload.has("userId") && !payload.get("userId").isJsonNull()) {
                try {
                    int userId = payload.get("userId").getAsInt();
                    user = User.findUserById(userId);
                } catch (Exception ignored) {}
            }

            if (user == null) {
                return new Response(404, "User not found", null);
            }

            if (user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            int userId = user.getId();
            String name = payload.get("name").getAsString();
            String caption = payload.has("caption") && !payload.get("caption").isJsonNull()
                    ? payload.get("caption").getAsString() : "";
            boolean commentAllowed = payload.has("commentAllowed") && !payload.get("commentAllowed").isJsonNull()
                    ? payload.get("commentAllowed").getAsBoolean() : true;

            List<String> tags = new ArrayList<>();
            if (payload.has("tags") && !payload.get("tags").isJsonNull() && payload.get("tags").isJsonArray()) {
                JsonArray tagsArray = payload.getAsJsonArray("tags");
                for (JsonElement el : tagsArray) {
                    tags.add(el.getAsString());
                }
            }

            byte[] bytes = Base64.getDecoder().decode(payload.get("fileData").getAsString());
            Files.createDirectories(Paths.get("photos"));

            String path = "photos/" + System.currentTimeMillis() + "_" + name + ".jpg";
            Files.write(Paths.get(path), bytes);

            Photo photo = Photo.uploadPhoto(userId, name, LocalDateTime.now(), tags, caption, commentAllowed, path);
            if (photo == null) {
                return new Response(400, "error", null);
            }

            user.updateRank();

            if (payload.has("albumIds") && payload.get("albumIds").isJsonArray()) {
                JsonArray albumIdsArray = payload.getAsJsonArray("albumIds");
                for (JsonElement el : albumIdsArray) {
                    int albumId = el.getAsInt();
                    Album album = DatabaseManager.getInstance().getAlbum(albumId);
                    if (album != null) {
                        album.addPhoto(photo);
                    }
                }
            }

            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("photoId", photo.getId());
            data.addProperty("name", photo.getName());
            data.addProperty("route", photo.getRoute());
            data.addProperty("rank", user.getRank().name());

            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response updatePhoto(JsonObject payload) {
        try {
            int photoId = payload.get("photoId").getAsInt();
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);
            if (photo == null) return new Response(404, "Photo not found", null);

            User user = DatabaseManager.getInstance().getUser(photo.getOwnerId());
            if (user != null && user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            if (payload.has("name")) photo.setName(payload.get("name").getAsString());
            if (payload.has("caption")) photo.setCaption(payload.get("caption").getAsString());
            if (payload.has("commentAllowed")) photo.setCommentAllowed(payload.get("commentAllowed").getAsBoolean());
            if (payload.has("tags")) {
                List<String> tags = new ArrayList<>();
                JsonArray arr = payload.getAsJsonArray("tags");
                for (JsonElement e : arr) tags.add(e.getAsString());
                photo.setTags(tags);
            }

            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Updated", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response deletePhoto(JsonObject payload) {
        try {
            int photoId = payload.get("photoId").getAsInt();
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);
            if (photo == null) {
                return new Response(404, "Photo not found", null);
            }

            String filePath = photo.getRoute();

            Photo.deletePhoto(photo);

            if (filePath != null) {
                try {
                    Files.deleteIfExists(Paths.get(filePath));
                } catch (Exception ignored) {}
            }

            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Photo permanently deleted", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response downloadPhoto(JsonObject payload) {
        try {
            int photoId = payload.get("photoId").getAsInt();
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);
            if (photo == null) {
                return new Response(404, "not found", null);
            }

            byte[] bytes = Files.readAllBytes(Paths.get(photo.getRoute()));
            JsonObject data = new JsonObject();
            data.addProperty("photoId", photo.getId());
            data.addProperty("name", photo.getName());
            data.addProperty("fileData", Base64.getEncoder().encodeToString(bytes));

            return new Response(200, "OK", data);
        } catch (IOException e) {
            return new Response(500, "io error", null);
        }
    }

    public static Response likePhoto(JsonObject payload) {
        try {
            User user = null;
            if (payload.has("userId")) {
                JsonElement userIdEl = payload.get("userId");
                if (userIdEl.isJsonPrimitive()) {
                    if (userIdEl.getAsJsonPrimitive().isNumber()) {
                        user = DatabaseManager.getInstance().getUser(userIdEl.getAsInt());
                    } else {
                        String username = userIdEl.getAsString();
                        user = User.getUsers().values().stream()
                                .filter(u -> u.getUsername().equals(username))
                                .findFirst().orElse(null);
                    }
                }
            }

            int photoId = payload.get("photoId").getAsInt();
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);

            if (user == null || photo == null) {
                return new Response(404, "not found", null);
            }

            if (user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            if (photo.getUserLikedIds().contains(user.getId())) {
                photo.unlike(user);
            } else {
                photo.like(user);
            }

            user.updateRank();
            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("likesCount", photo.getLikes());
            data.add("userLikedIds", gson.toJsonTree(photo.getUserLikedIds()));
            data.addProperty("userRank", user.getRank().name());

            return new Response(200, "Success", data);
        } catch (Exception e) {
            return new Response(500, "error: " + e.getMessage(), null);
        }
    }

    public static Response addComment(JsonObject payload) {
        try {
            User user = null;
            if (payload.has("userId")) {
                JsonElement userIdEl = payload.get("userId");
                if (userIdEl.isJsonPrimitive()) {
                    if (userIdEl.getAsJsonPrimitive().isNumber()) {
                        user = DatabaseManager.getInstance().getUser(userIdEl.getAsInt());
                    } else {
                        String username = userIdEl.getAsString();
                        user = User.getUsers().values().stream()
                                .filter(u -> u.getUsername().equals(username))
                                .findFirst().orElse(null);
                    }
                }
            }

            if (user == null) return new Response(404, "User not found", null);

            if (user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            int photoId = payload.get("photoId").getAsInt();
            String text = payload.get("text").getAsString();

            Comment c = Comment.createComment(user.getId(), photoId, LocalDateTime.now(), text);
            if (c == null) {
                return new Response(400, "failed", null);
            }

            user.updateRank();
            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("commentId", c.getId());
            data.addProperty("text", c.getText());
            data.addProperty("username", user.getUsername());
            data.addProperty("displayName", user.getDisplayName());
            data.addProperty("avatarRoute", user.getAvatarRoute() != null ? user.getAvatarRoute() : "");
            data.addProperty("avatar_url", user.getAvatarRoute() != null ? user.getAvatarRoute() : "");
            data.addProperty("userRank", user.getRank().name());

            return new Response(200, "comment added", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response getHomePhotos() {
        try {
            List<Photo> allPhotos = new ArrayList<>(DatabaseManager.getInstance().getAllPhotos().values());
            allPhotos.sort((p1, p2) -> p2.getDate().compareTo(p1.getDate()));

            JsonArray array = new JsonArray();
            for (Photo photo : allPhotos) {
                array.add(photoToJson(photo));
            }
            return new Response(200, "OK", array);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response search(JsonObject payload) {
        try {
            if (payload == null || !payload.has("query")) {
                return new Response(400, "Query is required", null);
            }
            String query = payload.get("query").getAsString();

            List<Photo> byName = Photo.searchByName(query);
            List<Photo> byTag = Photo.searchByTag(query);

            Set<Photo> combined = new LinkedHashSet<>();
            if (byName != null) combined.addAll(byName);
            if (byTag != null) combined.addAll(byTag);

            JsonArray array = new JsonArray();
            for (Photo photo : combined) {
                array.add(photoToJson(photo));
            }
            return new Response(200, "OK", array);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }
}
