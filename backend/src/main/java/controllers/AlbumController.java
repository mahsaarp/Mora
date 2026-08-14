package controllers;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import database.DatabaseManager;
import server.Response;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import model.*;

import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class AlbumController {
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

    public static Response createAlbum(JsonObject payload) {
        try {
            int userId = 0;
            if (payload.has("userId") && !payload.get("userId").isJsonNull()) {
                try {
                    userId = payload.get("userId").getAsInt();
                } catch (Exception e) {
                    try {
                        userId = Integer.parseInt(payload.get("userId").getAsString());
                    } catch (Exception ignored) {}
                }
            }
            if (userId <= 0 && payload.has("ownerId") && !payload.get("ownerId").isJsonNull()) {
                try {
                    userId = payload.get("ownerId").getAsInt();
                } catch (Exception e) {
                    try {
                        userId = Integer.parseInt(payload.get("ownerId").getAsString());
                    } catch (Exception ignored) {}
                }
            }

            String name = payload.get("albumName").getAsString();

            User user = User.findUserById(userId);
            if (user == null) {
                return new Response(404, "User not found", null);
            }

            if (user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            Album album = Album.createAlbum(userId, name);

            if (payload.has("photoIds") && payload.get("photoIds").isJsonArray()) {
                JsonArray photoIds = payload.getAsJsonArray("photoIds");
                for (JsonElement el : photoIds) {
                    Photo p = DatabaseManager.getInstance().getPhoto(el.getAsInt());
                    if (p != null) {
                        album.addPhoto(p);
                    }
                }
            }

            DatabaseManager.getInstance().addAlbum(album);
            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("albumId", album.getId());
            data.addProperty("albumName", album.getName());

            return new Response(200, "Album created", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response getAlbums() {
        try {
            List<Album> allAlbums = new ArrayList<>(DatabaseManager.getInstance().getAllAlbums().values());
            JsonElement data = gson.toJsonTree(allAlbums);
            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response addPhotoToAlbum(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            Album album = DatabaseManager.getInstance().getAlbum(albumId);
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);

            if (album == null || photo == null) {
                return new Response(404, "Not found", null);
            }

            User user = DatabaseManager.getInstance().getUser(album.getOwnerId());
            if (user != null && user.isBanned()) {
                return new Response(403, "Your account has been banned", null);
            }

            if (!album.addPhoto(photo)) {
                return new Response(400, "Already in album", null);
            }

            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Added", null);
        } catch (Exception e) {
            return new Response(500, "Server error", null);
        }
    }

    public static Response removePhotoFromAlbum(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            Album album = DatabaseManager.getInstance().getAlbum(albumId);
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);

            if (album == null || photo == null || !album.removePhoto(photo)) {
                return new Response(400, "Error removing photo", null);
            }

            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Removed", null);
        } catch (Exception e) {
            return new Response(500, "Server error", null);
        }
    }

    public static Response getAlbumDetails(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            Album album = DatabaseManager.getInstance().getAlbum(albumId);
            if (album == null) {
                return new Response(404, "Album not found", null);
            }

            JsonObject data = new JsonObject();
            data.addProperty("albumId", album.getId());
            data.addProperty("albumName", album.getName());
            data.addProperty("ownerId", album.getOwnerId());

            JsonArray arr = new JsonArray();
            for (Photo p : album.getPhotos()) {
                arr.add(PhotoController.photoToJson(p));
            }
            data.add("photos", arr);

            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response deleteAlbum(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            Album album = DatabaseManager.getInstance().getAlbum(albumId);
            if (album == null) {
                return new Response(404, "Album not found", null);
            }
            Album.deleteAlbum(album);
            DatabaseManager.getInstance().saveDatabase();
            return new Response(200, "Album deleted", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }
}
