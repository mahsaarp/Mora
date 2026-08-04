package controllers;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import database.DatabaseManager;
import model.*;
import server.Response;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.*;

public class PhotoController {
    private static final Gson gson = new Gson();

    public static Response uploadPhoto(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            String name = payload.get("name").getAsString();
            String caption = payload.has("caption") ? payload.get("caption").getAsString() : "";
            boolean commentAllowed = payload.has("commentAllowed") ? payload.get("commentAllowed").getAsBoolean() : true;

            byte[] bytes = Base64.getDecoder().decode(payload.get("fileData").getAsString());
            Files.createDirectories(Paths.get("photos"));

            String path = "photos/" + System.currentTimeMillis() + "_" + name + ".jpg";
            Files.write(Paths.get(path), bytes);

            Photo photo = Photo.uploadPhoto(userId, name, LocalDateTime.now(), null, caption, commentAllowed, path);
            if (photo == null) {
                return new Response(400, "error", null);
            }

            DatabaseManager.getInstance().addPhoto(photo);

            JsonObject data = new JsonObject();
            data.addProperty("photoId", photo.getId());
            data.addProperty("name", photo.getName());
            data.addProperty("route", photo.getRoute());

            return new Response(200, "OK", data);
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
            int userId = payload.get("userId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            User user = DatabaseManager.getInstance().getUser(userId);
            Photo photo = DatabaseManager.getInstance().getPhoto(photoId);

            if (user == null || photo == null) {
                return new Response(404, "not found", null);
            }

            photo.like(user);
            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("likesCount", photo.getLikes());

            return new Response(200, "liked", data);
        } catch (Exception e) {
            return new Response(500, "error", null);
        }
    }

    public static Response addComment(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();
            String text = payload.get("text").getAsString();

            Comment c = Comment.createComment(userId, photoId, LocalDateTime.now(), text);
            if (c == null) {
                return new Response(400, "failed", null);
            }

            DatabaseManager.getInstance().saveDatabase();

            JsonObject data = new JsonObject();
            data.addProperty("commentId", c.getId());
            data.addProperty("text", c.getText());

            return new Response(200, "comment added", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response getHomePhotos() {
        try {
            List<Photo> allPhotos = new ArrayList<>(DatabaseManager.getInstance().getAllPhotos().values());
            allPhotos.sort((p1, p2) -> p2.getDate().compareTo(p1.getDate()));

            JsonElement data = gson.toJsonTree(allPhotos);
            return new Response(200, "OK", data);
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

            JsonElement data = gson.toJsonTree(combined);
            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }
}